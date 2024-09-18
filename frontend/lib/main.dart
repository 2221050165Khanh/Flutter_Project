import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng full-stack-flutter đơn giản',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();

  String responseMessage = '';
  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  Future<void> sendName() async {
    final name = controller.text;
     controller.clear();
    final backendUrl = getBackendUrl();
    final url = Uri.parse('$backendUrl/api/v1/submit');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.body.isNotEmpty) {
        final data = json.decode(response.body);
        setState(() {
          responseMessage = data['message'];
        });
      } else {
        setState(() {
          responseMessage = 'Không nhận được phản hồi từ server';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = ' Lôi :${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text('Ung dung full-stack flutter don gian')),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'Tên'),
              ),
              SizedBox(height: 20),
              FilledButton(
                onPressed: sendName,
                child: Text('Gửi'),
              ),
              Text(
                responseMessage,
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        ));
  }
}
