import 'package:flutter/material.dart';
import 'page_onboarding_step1.dart';
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
    // --- 1. 入力バリデーション ---
    // trim() を使うことで、スペースのみの入力も防ぎます
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべての項目を正しく入力してください'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // ここで処理を中断
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードは6文字以上で入力してください')),
      );
      return;
    }

    // --- 2. 登録処理の開始 ---
    setState(() => _isLoading = true);

    try {
      // Firebase Auth でユーザー作成
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore にユーザー基本情報を保存
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nickname': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false, // オンボーディングが終わったかどうかのフラグ
      });

      // --- 3. 画面遷移 ---
      // 全ての非同期処理（await）が正常に終わった場合のみ実行されます
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PageOnboardingStep1()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebaseのエラー（既にメアドが使われている等）を表示
      String message = 'エラーが発生しました';
      if (e.code == 'email-already-in-use') message = 'このメールアドレスは既に登録されています';
      if (e.code == 'invalid-email') message = 'メールアドレスの形式が正しくありません';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print(e); // 予期せぬエラーのログ
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