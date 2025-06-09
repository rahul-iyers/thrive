import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusMessage = '';

  Future<void> _sendRequest(String targetUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final requestRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('friend_requests')
          .doc(currentUser.uid);

      await requestRef.set({
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _statusMessage = 'Request sent!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to send request';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Friends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => setState(() {
                    _searchQuery = _searchController.text.trim();
                    _statusMessage = '';
                  }),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_searchQuery.isNotEmpty)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usernames')
                    .doc(_searchQuery)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('No user found');
                  }

                  final userId = snapshot.data!.get('uid');
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(_searchQuery),
                    trailing: ElevatedButton(
                      child: Text('Add'),
                      onPressed: () => _sendRequest(userId),
                    ),
                  );
                },
              ),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
