import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchUsersScreen extends StatefulWidget {
  @override
  _SearchUsersScreenState createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  final currentUser = FirebaseAuth.instance.currentUser;

  void _searchUsers(String query) async {
    if (query.isEmpty) return;

    final result = await FirebaseFirestore.instance
        .collection('usernames')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: query)
        .where(FieldPath.documentId, isLessThan: query + 'z')
        .limit(10)
        .get();

    setState(() {
      _results = result.docs
          .where((doc) => doc.id != currentUser?.uid) // exclude self
          .map((doc) => {'uid': doc['uid'], 'username': doc.id})
          .toList();
    });
  }

  void _sendFriendRequest(String toUid) async {
    final fromUid = currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(toUid)
        .collection('friend_requests')
        .doc(fromUid)
        .set({
      'from': fromUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Users')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                labelText: 'Search by username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return ListTile(
                    title: Text(user['username']),
                    trailing: ElevatedButton(
                      onPressed: () => _sendFriendRequest(user['uid']),
                      child: Text('Add'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
