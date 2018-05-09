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

import rest

class Person
	serialize

	var name : String
	var age : Int

end

# POST REQUEST
var my_request = new CurlRestRequest("http://localhost:8080",method="POST")
my_request.json_src = new Person("Jean",12)
my_request.execute


# GET REQUEST
my_request = new CurlRestRequest("http://localhost:8080", method="GET")
var response = my_request.execute
assert response isa CurlRestResponseSuccess
var remote_person = response.deserialize("Person")
print remote_person.as(not null)

# DELETE REQUEST
my_request = new CurlRestRequest("http://localhost:8080",method="DELETE")
my_request.execute

# PUT REQUEST
my_request = new CurlRestRequest("http://localhost:8080",method="PUT")
my_request.json_src = new Person("Jean",12)
my_request.execute

# PATCH REQUEST
my_request = new CurlRestRequest("http://localhost:8080",method="PATCH")
my_request.json_src = new Person("Jean",12)
my_request.execute

# USE WITH SOCKET ADDRESS FAMILY
var my_unix_request = new CurlRestRequest("http:///tmp/",method="POST")
print my_unix_request.method.as(not null)
my_unix_request.json_src = new Person("Jean",12)
my_unix_request.unix_socket_path = "/tmp/test.sock"
my_unix_request.execute
