import 'package:firebase_auth/firebase_auth.dart';

//helps in authenticating
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //Email & Password Sign up
  Future<String> createdUserWithEmailAndPassword(
      String email, String password, String role) async {
    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return currentUser.user.uid;
  }

  //Email and Password SignIN
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    final currentUser = (await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password));
    return currentUser.user.uid;
  }

  //Sign Out
  signOut() {
    return _firebaseAuth.signOut();
  }
}
