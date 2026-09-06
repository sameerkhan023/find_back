import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // =========================
  // SIGN UP
  // =========================
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cleanName = name.trim();
      final cleanEmail = email.trim();

      // 1. Create account in Firebase Authentication
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        return 'Auth account created, but user is null.';
      }

      // 2. Save user information in Realtime Database
      try {
        await _dbRef.child('users').child(user.uid).set({
          'uid': user.uid,
          'name': cleanName,
          'email': cleanEmail,
          'createdAt': ServerValue.timestamp,
        });

        // Save name in Firebase Authentication profile
        await user.updateDisplayName(cleanName);
        await user.reload();
      } catch (e) {
        return 'Realtime Database Error: ${e.toString()}';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use.';

        case 'invalid-email':
          return 'Invalid email address.';

        case 'weak-password':
          return 'Password is too weak.';

        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';

        default:
          return e.message ?? 'Authentication failed.';
      }
    } catch (e) {
      return 'Unexpected Error: ${e.toString()}';
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';

        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';

        case 'invalid-email':
          return 'Invalid email address.';

        case 'user-disabled':
          return 'This account has been disabled.';

        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';

        default:
          return e.message ?? 'Login failed.';
      }
    } catch (e) {
      return 'Login Error: ${e.toString()}';
    }
  }

  // =========================
  // GET USER DATA
  // =========================
  Future<DataSnapshot> getUserData() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in.');
    }

    final DataSnapshot snapshot =
    await _dbRef.child('users').child(user.uid).get();

    return snapshot;
  }

  // =========================
  // UPDATE USER DATA
  // =========================
  Future<String?> updateUserData({
    required String name,
    String? phone,
  }) async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return 'No user logged in.';
      }

      final Map<String, dynamic> data = {
        'name': name.trim(),
      };

      if (phone != null) {
        data['phone'] = phone.trim();
      }

      await _dbRef.child('users').child(user.uid).update(data);

      await user.updateDisplayName(name.trim());

      return null;
    } catch (e) {
      return 'Unable to update profile: ${e.toString()}';
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =========================
  // CURRENT USER
  // =========================
  User? get currentUser => _auth.currentUser;

  // =========================
  // AUTH STATE
  // =========================
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}