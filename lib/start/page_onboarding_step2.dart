import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PageOnboardingStep2 extends StatefulWidget {
  const PageOnboardingStep2({super.key});

  @override
  State<PageOnboardingStep2> createState() => _PageOnboardingStep2State();
}

class _PageOnboardingStep2State extends State<PageOnboardingStep2> {
  // 初期値（例：2000年1月1日）
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _isLoading = false;

  // 生年月日をFirestoreに保存
  Future<void> _saveBirthDateAndNext() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Timestamp型で保存
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'birthDate': _selectedDate,
          'onboardingStep': 2,
        });

        if (mounted) {
          // 次のステップ（居住地選択など）へ遷移
          print("生年月日保存完了: $_selectedDate");
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const PageOnboardingStep3()));
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
      backgroundColor: const Color(0xFFF4F9F9), // 薄い水色の背景
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.5, // 進捗50%
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
              minHeight: 10,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            '生年月日',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'あなたの生年月日を教えてください。\n年齢は自動で計算されます。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 40),

          // --- 生年月日選択ピッカー ---
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    maximumDate: DateTime.now(),
                    minimumYear: 1940,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          // --- 「次へ」ボタン ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _saveBirthDateAndNext,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('次へ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}