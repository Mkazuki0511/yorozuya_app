import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../main.dart'; //

class PageOnboardingStep4 extends StatefulWidget {
  const PageOnboardingStep4({super.key});

  @override
  State<PageOnboardingStep4> createState() => _PageOnboardingStep4State();
}

class _PageOnboardingStep4State extends State<PageOnboardingStep4> {
  File? _image;
  final _picker = ImagePicker();
  bool _isLoading = false;

  // ギャラリーから画像を選択
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // 画像をアップロードしてオンボーディングを完了する
  Future<void> _uploadAndFinish() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? downloadUrl;

      // 画像が選択されている場合のみStorageにアップロード
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_icons')
            .child('${user.uid}.jpg');
        await storageRef.putFile(_image!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      // Firestoreの情報を更新
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'onboardingStep': 4,
        'onboardingCompleted': true,
      });

      if (mounted) {
        // メイン画面へ遷移（戻れないようにする）
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1.0, // 進捗100%
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
              minHeight: 10,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'プロフィール写真',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'あなたらしい写真を設定しましょう。\n後からいつでも変更できます。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 60),

          // --- 正方形の選択エリア ---
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 200, // サイズを少し調整
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // 円形から角丸の正方形に変更
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                      // 画像があれば表示
                      image: _image != null
                          ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover, // 正方形にきれいに収める
                      )
                          : null,
                    ),
                    // 画像がない時は「＋」アイコンを表示
                    child: _image == null
                        ? const Icon(Icons.add, size: 60, color: Colors.cyan)
                        : null,
                  ),
                  // 画像がある時の「編集」バッジ
                  if (_image != null)
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.cyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 24),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // --- ボタンセクション ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _uploadAndFinish,
                    child: _isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text('はじめる', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading ? null : _uploadAndFinish,
                  child: const Text('あとで設定する', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}