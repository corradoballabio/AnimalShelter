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
}