import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'page_request_post.dart';
import 'page_request_detail.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({super.key});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  int _selectedDateIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 検索バーとフィルタリング
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'キーワードで検索',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // フィルタリングボタン
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // 2. 6日分の日付リスト (均等配置)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(6, (index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = _selectedDateIndex == index;
                  final isToday = index == 0;
                  final isSaturday = date.weekday == DateTime.saturday;
                  final isSunday = date.weekday == DateTime.sunday;

                  // 日本語の曜日リスト
                  final weekdayStr = [
                    '月',
                    '火',
                    '水',
                    '木',
                    '金',
                    '土',
                    '日',
                  ][date.weekday - 1];

                  Color getDayColor() {
                    if (isSelected) return Colors.white;
                    if (isSaturday) return Colors.blue;
                    if (isSunday) return Colors.red;
                    return Colors.black;
                  }

                  Color getWeekdayColor() {
                    if (isSelected) return Colors.white70;
                    if (isSaturday) return Colors.blue;
                    if (isSunday) return Colors.red;
                    return Colors.grey;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: Container(
                        height: 64,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00C2CB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withAlpha(25),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isToday ? '今日' : date.day.toString(),
                              style: TextStyle(
                                color: getDayColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: isToday ? 13 : 15,
                              ),
                            ),
                            Text(
                              weekdayStr,
                              style: TextStyle(
                                color: getWeekdayColor(),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // 3. 依頼リスト (StreamBuilderで取得)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('status', isEqualTo: 'open')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('エラー: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user = FirebaseAuth.instance.currentUser;
                  final docs =
                      snapshot.data?.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['requesterId'] != user?.uid;
                      }).toList() ??
                      [];

                  // クライアントサイドで日付順（降順）にソート
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        '依頼はまだありません',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      // ID をプロパティに追加
                      data['id'] = doc.id;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PageRequestDetail(requestData: data),
                            ),
                          );
                        },
                        child: _buildRequestCard(data),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PageRequestPost()),
          );
        },
        backgroundColor: const Color(0xFF00C2CB),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final dateStr = DateFormat('M/d HH:mm').format(createdAt);
    final imageUrl = data['imageUrl'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー (ユーザー情報)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFEEEEEE),
                  child: Icon(Icons.person, color: Colors.grey, size: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ユーザー', // ユーザー名は固定
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.grey, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite_border, color: Colors.grey, size: 18),
              ],
            ),
          ),

          // メイン画像 (4:3)
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[100],
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF00C2CB),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
          ),

          // コンテンツ
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  data['title'] ?? 'タイトルなし',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // 時間
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data['time'] ?? '未設定',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // 場所
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data['location'] ?? '未設定',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 予算 (ラベルなし、黒色)
                Text(
                  data['budget'] ?? '相談',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
