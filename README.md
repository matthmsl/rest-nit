# Rest JSON module for NIT

Rest extension of standard NIT cURL library.

## Minimal use

```
import rest

class Person
	serialize

	var name : String
	var age : Int

end

# POST REQUEST
var my_request = new CurlRestRequest("http://example.com",method="POST")
my_request.json_src = new Person("Jean",12)
my_request.execute
```
