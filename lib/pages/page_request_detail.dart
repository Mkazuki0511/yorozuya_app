import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PageRequestDetail extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const PageRequestDetail({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final createdAt =
        (requestData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final dateStr = DateFormat('yyyy/MM/dd HH:mm').format(createdAt);
    final imageUrl = requestData['imageUrl'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '依頼詳細',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. メイン画像 (4:3)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 60,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. タイトル
                  Text(
                    requestData['title'] ?? 'タイトルなし',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. 投稿日時
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '投稿: $dateStr',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48, thickness: 1),

                  // 4. 基本情報セクション
                  _buildInfoRow('カテゴリー', requestData['category'] ?? '未設定'),
                  const SizedBox(height: 16),
                  _buildInfoRow('希望時間', requestData['time'] ?? '未設定'),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    '予算',
                    requestData['budget'] ?? '相談',
                    isPrice: true,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('場所', requestData['location'] ?? '未設定'),

                  const Divider(height: 48, thickness: 1),

                  // 5. 内容説明
                  const Text(
                    '内容説明',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    requestData['description'] ?? '説明はありません。',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ログインしてください')),
                          );
                          return;
                        }

                        try {
                          // 応募情報を保存
                          await FirebaseFirestore.instance
                              .collection('applications')
                              .add({
                                'requestId': requestData['id'],
                                'requestTitle': requestData['title'],
                                'requesterId': requestData['requesterId'],
                                'applicantId': user.uid,
                                'imageUrl': requestData['imageUrl'],
                                'time': requestData['time'],
                                'location': requestData['location'],
                                'appliedAt': FieldValue.serverTimestamp(),
                                'status': 'pending',
                              });

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('応募が完了しました！')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('エラーが発生しました: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2CB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'この依頼に応募する',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
              color: isPrice ? const Color(0xFF00C2CB) : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
