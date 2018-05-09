# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2018 Matthieu Samuel Le Guellaut <leguellaut.matthieu@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Extension of the curl module for Restful JSON
#
# Sends and receives serializable objects
module rest

intrude import curl
import native_curl
import json
import json::dynamic
import json::serialization_write

# Restful JSON request builder over HTTP
#
class CurlRestRequest
	super CurlHTTPRequest

	# Set a serializable object to be sent as a JSON string to the server
	#
	# Object must subclass Serializable and implement its services
	# or being annotated with serialize. For further details :
	# https://github.com/nitlang/nit/tree/master/lib/json
	var json_src : nullable Serializable is writable

	# Execute HTTP request
	#
	# Returns a CurlRestResponseSuccess as CurlResponse
	redef fun execute : CurlResponse
	do
		# BASIC CURL STUFF (Reveiver, callback, user agent, URL, Address family)
		self.curl.native = new NativeCurl.easy_init
		var success_response = new CurlRestResponseSuccess

		if not self.curl.is_ok then return answer_failure(0, "Curl instance is not correctly initialized")

		var callback_receiver : CurlCallbacks = success_response
		if self.delegate != null then callback_receiver = self.delegate.as(not null)

		var err : CURLCode

		# Prepare request
		err = prepare_request(callback_receiver)
		if not err.is_ok then return answer_failure(err.to_i, err.to_s)

		# ON THE ROAD AGAIN
		var err_resp = perform
		if err_resp != null then return err_resp

		var st_code = self.curl.native.easy_getinfo_long(new CURLInfoLong.response_code)
		if not st_code == null then success_response.status_code = st_code

		self.curl.native.easy_clean

		return success_response
	end

	# Redefines body creation function.
	# A call to this method requires a valid object
	# in the attribute json_src otherwise it will raise an
	# error !
	redef private fun set_body : CURLCode
	do
		if json_src!=null then
			var wr = new StringWriter
			var serializer = new JsonSerializer(wr)
			serializer.plain_json=true
			serializer.pretty_json = true
			serializer.serialize(json_src)
			var body = wr.to_s
			assert body!=""
			return self.curl.native.easy_setopt(new CURLOption.postfields, body)
		else
			return new CURLCode.ok
		end
	end

end

# Success response class of a CurlRestRequest
class CurlRestResponseSuccess
	super CurlResponseSuccessIntern

	# Response code from the server
	var status_code = 0

	# Raw JSON string, as received from the server
	var json_string = ""

	redef fun body_callback(line) do self.json_string += line

	# `JsonValue` to access the data in `json_string`
	fun json_value: JsonValue do return new JsonValue(json_string)

	# Deserialized Nit object from `json_string`
	fun deserialize(type_name :String) : nullable Object
	do
		var deserializer = new JsonDeserializer(json_string)
		return deserializer.deserialize(type_name)
	end
end
