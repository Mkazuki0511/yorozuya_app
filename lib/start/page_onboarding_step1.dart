import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PageOnboardingStep1 extends StatefulWidget {
  const PageOnboardingStep1({super.key});

  @override
  State<PageOnboardingStep1> createState() => _PageOnboardingStep1State();
}

class _PageOnboardingStep1State extends State<PageOnboardingStep1> {
  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _saveGenderAndNext() async {
    if (_selectedGender == null) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestoreのユーザードキュメントを更新
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'gender': _selectedGender,
          'onboardingStep': 1,
        });

        if (mounted) {
          // 次のステップ (PageOnboardingStep2 など) への遷移をここに記述
          print("性別保存完了: $_selectedGender");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
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
        automaticallyImplyLeading: false,
        // --- 進捗バー (Progress Bar) ---
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.25, // 全4ステップの1つ目
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 中央揃え
          children: [
            const SizedBox(height: 40),
            const Text(
              '性別を選択してください',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'あなたに最適な情報を表示するために利用します',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 60),

            // --- 円形の選択UI (縦配置) ---
            _buildCircularOption('男性', Icons.male),
            const SizedBox(height: 32),
            _buildCircularOption('女性', Icons.female),

            const Spacer(),

            // 次へ進むボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGender != null ? Colors.blue : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: (_selectedGender == null || _isLoading) ? null : _saveGenderAndNext,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('次へ進む', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 円形の選択肢を作成するメソッド
  Widget _buildCircularOption(String label, IconData icon) {
    bool isSelected = _selectedGender == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              // 未選択時は以前の背景色 #F7F7F7 を使用
              color: isSelected ? Colors.blue.withOpacity(0.1) : const Color(0xFFF7F7F7),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Icon(
              icon,
              size: 44,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}