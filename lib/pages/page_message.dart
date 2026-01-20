import 'package:flutter/material.dart';

class PageMessage extends StatelessWidget {
  const PageMessage({super.key});

  @override
  Widget build(BuildContext context) {
    // デモ用のダミーデータ
    final List<Map<String, String>> dummyChatList = List.generate(
      10,
      (index) => {
        'name': '名前',
        'age': '年齢',
        'lastMessage': '応募いただきありがとうございます。',
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'メッセージ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: dummyChatList.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Color(0xFFEEEEEE), indent: 20, endIndent: 20),
        itemBuilder: (context, index) {
          final chat = dummyChatList[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.grey[400], size: 32),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Text(
                    chat['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    chat['age']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Text(
              chat['lastMessage']!,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            onTap: () {
              // チャットルーム詳細へ遷移（将来的に実装）
            },
          );
        },
      ),
    );
  }
}
