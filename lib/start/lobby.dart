import 'package:flutter/material.dart';
import 'page_login.dart';
import 'page_signup.dart';

class PageLobby extends StatelessWidget {
  const PageLobby({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 背景は白
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ロゴをなくした分、上部に適切な余白を配置
              const Spacer(flex: 3),

              const Text(
                'よろずやアプリへ\nようこそ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const Spacer(flex: 3),

              // --- ボタンセクション ---
              // 1. 新規登録ボタン（塗りつぶしスタイル）
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 今回のテーマカラー
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  // 新規登録画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PageSignup()),
                  );
                },
                child: const Text(
                  '新規登録の方はこちら',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // 2. ログインボタン（枠線スタイル）
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  // ログイン画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PageLogin()),
                  );
                },
                child: const Text(
                  'ログイン',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}