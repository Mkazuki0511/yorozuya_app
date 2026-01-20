import 'package:flutter/material.dart';

class PageWork extends StatelessWidget {
  const PageWork({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
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
            indicatorColor: Colors.cyan,
            indicatorWeight: 3,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: '今後の予定'),
              Tab(text: 'これまでの仕事'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 今後の予定タブの中身
            _buildWorkList(),
            // これまでの仕事タブの中身
            _buildWorkList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 画像にあるような中身が空の角丸カード（モック）
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[400]!),
            ),
          ),
        ],
      ),
    );
  }
}
