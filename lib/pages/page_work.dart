import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PageWork extends StatelessWidget {
  const PageWork({super.key});

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
            'はたらく',
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
              Tab(text: 'これまでの仕事'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWorkList(context, status: 'approved'),
            _buildWorkList(context, status: 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkList(BuildContext context, {required String status}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('ログインしてください'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('applicantId', isEqualTo: user.uid)
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
                Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('仕事はまだありません', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 1. 日付順にソート (降順)
        docs.sort((a, b) {
          final aTime =
              (a.data() as Map<String, dynamic>)['appliedAt'] as Timestamp?;
          final bTime =
              (b.data() as Map<String, dynamic>)['appliedAt'] as Timestamp?;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        // 2. 日付ごとにグループ化
        Map<String, List<Map<String, dynamic>>> groupedWorks = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date =
              (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dateKey = DateFormat('M月d日 (E)', 'ja_JP').format(date);
          if (groupedWorks[dateKey] == null) {
            groupedWorks[dateKey] = [];
          }
          groupedWorks[dateKey]!.add(data);
        }

        final sortedDateKeys = groupedWorks.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: sortedDateKeys.length,
          itemBuilder: (context, dateIndex) {
            final dateKey = sortedDateKeys[dateIndex];
            final worksInDate = groupedWorks[dateKey]!;

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
                ...worksInDate.map(
                  (data) => Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildWorkCard(data),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWorkCard(Map<String, dynamic> appData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('requests')
          .doc(appData['requestId'])
          .get(),
      builder: (context, snapshot) {
        // 読み込み中やエラー時のための暫定データ
        final requestData = snapshot.data?.data() as Map<String, dynamic>?;

        final title =
            requestData?['title'] ?? appData['requestTitle'] ?? 'タイトルなし';
        final imageUrl = requestData?['imageUrl'] ?? appData['imageUrl'];
        final time = requestData?['time'] ?? appData['time'] ?? '未設定';
        final location =
            requestData?['location'] ?? appData['location'] ?? '未設定';

        final appliedAt =
            (appData['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateStr = DateFormat('yyyy年M月d日 (E)', 'ja_JP').format(appliedAt);

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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
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
                      title,
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

                    // 日時
                    _buildIconText(Icons.access_time, '$dateStr  $time'),
                    const SizedBox(height: 10),

                    // 場所
                    _buildIconText(Icons.location_on_outlined, location),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      child: Icon(Icons.image, color: Colors.grey[300], size: 60),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, size: 18, color: Colors.grey[500]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ],
    );
  }
}
