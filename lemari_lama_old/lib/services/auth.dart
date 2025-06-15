import 'package:firebase_auth/firebase_auth.dart';
import '../models/users.dart';
import '../services/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signUp(UserModel userModel, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      final uid = result.user!.uid;
      final userToSave = UserModel(
        uid: uid,
        nama: userModel.nama,
        email: userModel.email,
        nohp: userModel.nohp,
        role: userModel.role,
        is_blocked: userModel.is_blocked,
      );

      await _userService.addUser(userToSave);

      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    return await _userService.getUser(uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
