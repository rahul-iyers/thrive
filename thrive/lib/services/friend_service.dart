import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  static Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    final toRef = FirebaseFirestore.instance
        .collection('users')
        .doc(toUserId)
        .collection('friend_requests')
        .doc(fromUserId);

    await toRef.set({
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> sendFriendRequestByUsername(String fromUserId, String toUsername) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final usernameDoc = await firestore.collection('usernames').doc(toUsername).get();
      if (!usernameDoc.exists) {
        return 'User not found';
      }

      final toUserId = usernameDoc['uid'];

      if (toUserId == fromUserId) {
        return 'You cannot send a request to yourself';
      }

      final existingRequest = await firestore
          .collection('users')
          .doc(toUserId)
          .collection('friend_requests')
          .doc(fromUserId)
          .get();

      if (existingRequest.exists) {
        return 'Request already sent';
      }

      await firestore
          .collection('users')
          .doc(toUserId)
          .collection('friend_requests')
          .doc(fromUserId)
          .set({'status': 'pending', 'timestamp': FieldValue.serverTimestamp()});

      return 'Friend request sent!';
    } catch (e) {
      print('Error sending friend request: $e');
      return 'An error occurred';
    }
  }

  static Future<void> acceptFriendRequest(String currentUserId, String fromUserId) async {
    final firestore = FirebaseFirestore.instance;

    // Mark request as accepted
    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(fromUserId)
        .update({'status': 'accepted'});

    // Add each other to friends list
    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(fromUserId)
        .set({});

    await firestore
        .collection('users')
        .doc(fromUserId)
        .collection('friends')
        .doc(currentUserId)
        .set({});
  }

  static Future<void> rejectFriendRequest(String currentUserId, String fromUserId) async {
    final firestore = FirebaseFirestore.instance;

    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(fromUserId)
        .update({'status': 'rejected'});
  }

  static Future<int> getPendingRequestCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.length;
  }

  static Future<List<String>> getFriendIds(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
