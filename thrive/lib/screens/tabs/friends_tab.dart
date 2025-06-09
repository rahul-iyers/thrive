import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsTab extends StatefulWidget {
  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  List<Map<String, dynamic>> _allFriends = [];
  List<Map<String, dynamic>> _filteredFriends = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .get();

    final friendIds = snapshot.docs.map((doc) => doc.id).toList();
    final List<Map<String, dynamic>> friends = [];

    for (final id in friendIds) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        friends.add({
          'uid': id,
          'username': data['username'] ?? 'Unknown',
          'displayName': data['displayName'] ?? '',
        });
      }
    }

    setState(() {
      _allFriends = friends;
      _filteredFriends = friends;
    });
  }

  void _filterFriends(String query) {
    final filtered = _allFriends.where((friend) {
      final username = friend['username']?.toLowerCase() ?? '';
      final displayName = friend['displayName']?.toLowerCase() ?? '';
      final q = query.toLowerCase();
      return username.contains(q) || displayName.contains(q);
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredFriends = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: _filterFriends,
            decoration: InputDecoration(
              hintText: 'Search friends...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: _filteredFriends.isEmpty
              ? Center(child: Text('No friends found'))
              : ListView.builder(
            itemCount: _filteredFriends.length,
            itemBuilder: (context, index) {
              final friend = _filteredFriends[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(friend['username']),
                subtitle: friend['displayName'].isNotEmpty
                    ? Text(friend['displayName'])
                    : null,
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to friend's profile or shared progress screen
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
