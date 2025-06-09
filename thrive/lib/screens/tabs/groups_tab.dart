import 'package:flutter/material.dart';

class GroupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder UI; in the future connect to Firestore to fetch user groups
    final groups = ['Running Buddies', 'Gym Crew', 'Nutrition Squad'];

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.group),
          title: Text(groups[index]),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            // Optionally: Navigate to group detail or group chat
          },
        );
      },
    );
  }
}
