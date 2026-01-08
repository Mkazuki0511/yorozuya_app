import 'package:flutter/material.dart';

class PageSignup extends StatelessWidget {
  const PageSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text('新規登録画面（制作中）', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}