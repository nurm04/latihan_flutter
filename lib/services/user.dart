import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(UserModel userModel) async {
    try {
      await _users.doc(userModel.uid).set(userModel.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot snapshot = await _users.doc(uid).get();

      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUser() async {
    try {
      QuerySnapshot snapshot = await _users.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _users.doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }
}