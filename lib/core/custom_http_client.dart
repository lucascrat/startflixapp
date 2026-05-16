import 'package:http/http.dart' as http;

class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.url.path.startsWith('/rest/v1')) {
      final newPath = request.url.path.replaceFirst('/rest/v1', '');
      final newUrl = request.url.replace(path: newPath.isEmpty ? '/' : newPath);
      
      final newRequest = http.Request(request.method, newUrl)
        ..headers.addAll(request.headers);
        
      if (request is http.Request) {
        newRequest.bodyBytes = request.bodyBytes;
      }
      
      return _inner.send(newRequest);
    }
    return _inner.send(request);
  }
}
