import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'page_onboarding_step2.dart'; // 次の画面をインポート

class PageOnboardingStep1 extends StatefulWidget {
  const PageOnboardingStep1({super.key});

  @override
  State<PageOnboardingStep1> createState() => _PageOnboardingStep1State();
}

class _PageOnboardingStep1State extends State<PageOnboardingStep1> {
  String? _selectedGender;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.25,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan), // シアンに変更
              minHeight: 8,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
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

            _buildCircularOption('男性', Icons.male),
            const SizedBox(height: 32),
            _buildCircularOption('女性', Icons.female),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGender != null ? Colors.cyan : Colors.grey[300], // シアンに変更
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: (_selectedGender == null || _isLoading)
                    ? null
                    : () async {
                  setState(() => _isLoading = true);
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'gender': _selectedGender,
                        'onboardingStep': 1,
                      });
                      if (mounted) {
                        // 年齢選択画面へ遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PageOnboardingStep2()),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
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
              color: isSelected ? Colors.cyan.withOpacity(0.1) : const Color(0xFFF7F7F7),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.cyan : Colors.transparent,
                width: 3,
              ),
            ),
            child: Icon(
              icon,
              size: 44,
              color: isSelected ? Colors.cyan : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.cyan : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}