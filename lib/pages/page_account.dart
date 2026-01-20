import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PageAccount extends StatelessWidget {
  const PageAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('ログイン情報が見つかりません')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final nickname = data?['nickname'] ?? 'ユーザー';
        final profileImageUrl = data?['profileImageUrl'];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'アカウント',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // --- プロフィールセクション ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                // プロフィール編集画面へ
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('プロフィールを確認・編集'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- ウォレット残高カード ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00DB8F), // 鮮やかなグリーン
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ウォレット残高',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '¥ 0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            '引き出す',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- ゴールドランクカード ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC4D), // ゴールド
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ゴールドランク',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('提供回数', '10'),
                            _buildStatItem('平均満足度', '4.5', subValue: '/5.0'),
                            _buildStatItem('利用回数', '10'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              height: 24,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 0.6, // 進捗デモ
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(
                                    0.2,
                                  ), // 進捗部分の影
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const Positioned.fill(
                              child: Center(
                                child: Text(
                                  'あと 1000exでプラチナランク',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 設定リスト ---
                  _buildMenuItem(Icons.person_outline, 'アカウント設定'),
                  _buildMenuItem(Icons.notifications_none, '通知設定'),
                  _buildMenuItem(Icons.payment_outlined, '獲得マネー'),
                  _buildMenuItem(Icons.help_outline, 'ヘルプ・サポート'),
                  _buildMenuItem(Icons.description_outlined, '利用規約 / プライバシー'),
                  _buildMenuItem(
                    Icons.logout,
                    'ログアウト',
                    titleColor: Colors.redAccent,
                    onTap: () => FirebaseAuth.instance.signOut(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, {String? subValue}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subValue != null)
                TextSpan(
                  text: subValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: titleColor ?? Colors.black87),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: titleColor ?? Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap ?? () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
