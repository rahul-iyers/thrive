import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  String? _resultMessage;
  bool _isLoading = false;

  void _sendRequest() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final result = await FriendService.sendFriendRequestByUsername(
      currentUser.uid,
      username,
    );

    setState(() {
      _resultMessage = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendRequest,
              child: _isLoading ? CircularProgressIndicator() : Text('Send Friend Request'),
            ),
            SizedBox(height: 24),
            if (_resultMessage != null)
              Text(
                _resultMessage!,
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
