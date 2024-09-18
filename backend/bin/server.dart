import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router(notFoundHandler: _notFoundHandler)
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandler)
  ..get('/api/v1/echo/<message>', _echoHandler)
  ..post('/api/v1/submit', _submitHandler);

final _headers = {'Content-Type': 'application/json'};

Future<Response> _submitHandler(Request req) async {
  try {
    final payload = await req.readAsString();

    final data = json.decode(payload);

    final name = data['name'] as String?;

    if (name != null && name.isNotEmpty) {
      final response = {'message': 'Chao mung ${name}'};
      return Response.ok(
        json.encode(response),
        headers: _headers,
      );
    } else {
      final response = {'message': 'Ko nhan dc ten ban'};
      return Response.badRequest(
        body: json.encode(response),
        headers: _headers,
      );
    }
  } catch (e) {
    final response = {'message': 'yeu cau khong hop le . Loi ${e.toString()}'};
    return Response.badRequest(
      body: json.encode(response),
      headers: _headers,
    );
  }
}

Response _rootHandler(Request req) {
  return Response.ok(json.encode({'message': 'Hello world'}),
      headers: _headers);
}

Response _checkHandler(Request req) {
  return Response.ok(
      json.encode({'message': 'Chào mừng bạn đến với ứng dụng Web động '}),
      headers: _headers);
}

Response _notFoundHandler(Request req) {
  return Response.notFound('Không tìm thấy đường dẫn "${req.url}" trên server');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  final corsHeader = createMiddleware(
    requestHandler: (req) {
      if (req.method == 'OPTION') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUSH, DELETE,PATCH, HEAD',
          'Access-Control-Allow-Headers': 'Content-Type , Authorization',
        });
      }
      return null;
    },
    responseHandler: (res) {
      return res.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUSH, DELETE,PATCH, HEAD',
        'Access-Control-Allow-Headers': 'Content-Type , Authorization',
      });
    },
  );

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(corsHeader)
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server đang chạy tại  http://${server.address}:${server.port}');
}
