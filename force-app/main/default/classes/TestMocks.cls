public class TestMocks {
	public class getImagesSuccess implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			Map<String,String> responseBody = new Map<String,String>();
			responseBody.put('message', 'response message');
			responseBody.put('status', 'success');

			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(JSON.serialize(responseBody));
			response.setStatusCode(200);
			return response;
		}
	}

	public class getBreedsSuccess implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			Map<String,Object> responseBody = new Map<String,Object>();

			Map<String,Object> pairs = new Map<String,Object>();
			pairs.put('key1', new List<String>{'value1'});
			pairs.put('key2', new List<String>{'value2'});

			responseBody.put('message', pairs);
			responseBody.put('status', 'success');

			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(JSON.serialize(responseBody));
			response.setStatusCode(200);
			return response;
		}
	}

	public class getBreedsFail implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			Map<String,Object> responseBody = new Map<String,Object>();

			responseBody.put('message', 'something went wrong');
			responseBody.put('status', 'error');

			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(JSON.serialize(responseBody));
			response.setStatusCode(500);
			return response;
		}
	}
}