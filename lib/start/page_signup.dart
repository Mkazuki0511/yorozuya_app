import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PageSignup extends StatefulWidget {
  const PageSignup({super.key});

  @override
  State<PageSignup> createState() => _PageSignupState();
}

class _PageSignupState extends State<PageSignup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false; // 通信中の状態管理

  // 新規登録ロジック
  Future<void> _handleSignUp() async {
    // 1. 入力チェック
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての項目を入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Firebase Authでユーザー作成
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Firestoreにユーザー情報を保存
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'nickname': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // 登録成功後、前の画面へ戻る
      }
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      String message = 'エラーが発生しました';
      if (e.code == 'weak-password') message = 'パスワードが短すぎます';
      if (e.code == 'email-already-in-use') message = 'このメールアドレスは既に登録されています';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '新規登録',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'アカウントを作成して始めましょう',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // 各入力欄（UIはそのまま）
            _buildLabel('ニックネーム'),
            _buildTextField(_nameController, '例：よろずや太郎', false),

            const SizedBox(height: 20),
            _buildLabel('メールアドレス'),
            _buildTextField(_emailController, 'example@mail.com', false),

            const SizedBox(height: 20),
            _buildLabel('パスワード'),
            _buildTextField(_passwordController, '6文字以上の英数字', true),

            const SizedBox(height: 40),

            // 登録ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, //
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isLoading ? null : _handleSignUp, // 通信中は無効化
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('新規登録', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 補助Widget: ラベル
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  // 補助Widget: 入力欄
  Widget _buildTextField(TextEditingController controller, String hint, bool obscure) => TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F7F7), //
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}