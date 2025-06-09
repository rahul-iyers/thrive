import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _respondToRequest(String fromUserId, String action) async {
    if (action == 'accept') {
      await FriendService.acceptFriendRequest(userId, fromUserId);
    } else {
      await FriendService.rejectFriendRequest(userId, fromUserId);
    }
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('friend_requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final fromUserId = request.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(title: Text('Loading...'));
                  }

                  final username = userSnapshot.data!['username'] ?? 'Unknown';

                  return ListTile(
                    title: Text(username),
                    subtitle: Text('wants to follow you'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _respondToRequest(fromUserId, 'accept'),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _respondToRequest(fromUserId, 'reject'),
                        ),
                      ],
                    ),
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
