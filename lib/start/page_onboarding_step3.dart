import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'page_onboarding_step4.dart';

class PageOnboardingStep3 extends StatefulWidget {
  const PageOnboardingStep3({super.key});

  @override
  State<PageOnboardingStep3> createState() => _PageOnboardingStep3State();
}

class _PageOnboardingStep3State extends State<PageOnboardingStep3> {
  // 都道府県リスト（一部抜粋。必要に応じて全県追加してください）
  final List<String> _regions = [
    '東京', '神奈川', '埼玉', '千葉', '茨城', '栃木', '群馬',
    '山梨', '長野', '新潟', '富山', '石川', '福井', '岐阜', '静岡', '愛知', '三重',
    '滋賀', '京都', '大阪', '兵庫', '奈良', '和歌山',
  ];

  String _selectedRegion = '愛知'; // 初期値
  bool _isLoading = false;

  Future<void> _saveRegionAndNext() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestoreの地域情報を更新
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'region': _selectedRegion,
          'onboardingStep': 3,
        });

        if (mounted) {
          // 次のステップ（例：プロフィール写真登録など）へ遷移
          print("地域保存完了: $_selectedRegion");
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PageOnboardingStep4()));
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
      backgroundColor: const Color(0xFFF4F9F9), // 背景色
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.75, // 進捗75%
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
            '地域',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '地域を教えてください。プロフィールに表示されます。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 40),

          // --- 地域選択ピッカー ---
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 350,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 選択箇所の上下の境界線
                    Positioned(
                      top: 145,
                      child: Container(
                        width: 200,
                        height: 2,
                        color: Colors.cyan,
                      ),
                    ),
                    Positioned(
                      bottom: 145,
                      child: Container(
                        width: 200,
                        height: 2,
                        color: Colors.cyan,
                      ),
                    ),
                    CupertinoPicker(
                      itemExtent: 60,
                      scrollController: FixedExtentScrollController(
                        initialItem: _regions.indexOf(_selectedRegion),
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedRegion = _regions[index]);
                      },
                      children: _regions.map((region) {
                        final isSelected = region == _selectedRegion;
                        return Center(
                          child: Text(
                            region,
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 24,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.cyan : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                onPressed: _isLoading ? null : _saveRegionAndNext,
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