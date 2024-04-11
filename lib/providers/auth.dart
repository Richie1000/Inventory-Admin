import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './connection.dart';

final AuthProvider authService = AuthProvider();

class AuthProvider {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> checkEmail(String email) async {
    try {
      DocumentSnapshot employee =
          await _db.collection('users').doc(email).get();
      return employee.exists;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> handleSignIn({String? email, String? password}) async {
    if (connectionService.connected.value) {
      bool emailexists = await checkEmail(email!);

      if (emailexists) {
        try {
          return (await auth.signInWithEmailAndPassword(
            email: email,
            password: password!,
          ))
              .user;
        } catch (e) {
          throw e;
        }
      } else {
        throw Exception("NOTREGISTERED");
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<User> handleRegister(
      {String? email, String? password, String? username}) async {
    if (connectionService.connected.value) {
      try {
        final User? user = (await auth.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        ))
            .user;

        // UserUpdateInfo info = UserUpdateInfo();
        // info.displayName = username;

        // user?.updateProfile(info);
        user?.updateProfile();

        await _db.collection('users').doc(email).set({
          "uid": user!.uid,
          "email": email,
          "username": username,
          "roles": {"admin": true, "editor": true},
          "active": true
        });

        return user;
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> logout() async {
    if (connectionService.connected.value) {
      try {
        return await auth.signOut();
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }
}
