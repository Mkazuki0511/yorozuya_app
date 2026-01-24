import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'page_chat_room.dart';

class PageMessage extends StatelessWidget {
  const PageMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text('ログインしてください')));
    }

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('status', whereIn: ['pending', 'approved'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data?.docs ?? [];

          // 自分が「依頼者」または「応募者」であるものに限定
          final myApplications = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['requesterId'] == currentUserId ||
                data['applicantId'] == currentUserId;
          }).toList();

          if (myApplications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'メッセージはまだありません',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: myApplications.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFFEEEEEE),
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final data = myApplications[index].data() as Map<String, dynamic>;
              final isRequester = data['requesterId'] == currentUserId;
              final otherUserId = isRequester
                  ? data['applicantId']
                  : data['requesterId'];
              final requestId = data['requestId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;
                  final otherUserName = userData?['nickname'] ?? 'ユーザー';
                  final otherUserImg = userData?['profileImageUrl'];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: otherUserImg != null
                          ? NetworkImage(otherUserImg)
                          : null,
                      child: otherUserImg == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      otherUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '依頼: ${data['requestTitle']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: data['status'] == 'approved'
                            ? const Color(0xFFE0F7F9)
                            : const Color(0xFFFFEFEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['status'] == 'approved' ? '契約済み' : '未契約',
                        style: TextStyle(
                          color: data['status'] == 'approved'
                              ? const Color(0xFF00C2CB)
                              : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageChatRoom(
                            requestId: requestId,
                            otherUserId: otherUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
