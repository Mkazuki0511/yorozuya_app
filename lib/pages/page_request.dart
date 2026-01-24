import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'page_application_list.dart';

class PageRequest extends StatelessWidget {
  const PageRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'いらい',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFF00C2CB),
            indicatorWeight: 3,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: '今後の予定'),
              Tab(text: 'これまでの依頼'),
            ],
          ),
        ),
        body: Column(
          children: [
            // 申請通知バナー
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .where(
                    'requesterId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                final count = snapshot.data!.docs.length;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PageApplicationList(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFEF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'あなたの依頼に $count 件の申請があります',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRequestList(context, status: 'open'),
                  _buildRequestList(context, status: 'closed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(BuildContext context, {required String status}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('ログインしてください'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('requesterId', isEqualTo: user.uid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text('依頼はまだありません', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 1. 日付順にソート (降順)
        docs.sort((a, b) {
          final aTime =
              (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTime =
              (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        // 2. 日付ごとにグループ化
        Map<String, List<Map<String, dynamic>>> groupedRequests = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date =
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          // 日本語の曜日を含むフォーマット
          final dateKey = DateFormat('M月d日 (E)', 'ja_JP').format(date);
          if (groupedRequests[dateKey] == null) {
            groupedRequests[dateKey] = [];
          }
          groupedRequests[dateKey]!.add(data);
        }

        final sortedDateKeys = groupedRequests.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: sortedDateKeys.length,
          itemBuilder: (context, dateIndex) {
            final dateKey = sortedDateKeys[dateIndex];
            final requestsInDate = groupedRequests[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                  child: Text(
                    dateKey,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ...requestsInDate.map(
                  (data) => Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildRequestCard(data),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] as String?;
    final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final dateStr = DateFormat('yyyy年M月d日 (E)', 'ja_JP').format(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. メイン画像 (上部)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[300],
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[300],
                        size: 60,
                      ),
                    ),
            ),
          ),

          // 2. コンテンツ部分
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'タイトルなし',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.4,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // 日時 (日付 + 時間)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$dateStr  ${data['time'] ?? '未設定'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 場所
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data['location'] ?? '未設定',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
