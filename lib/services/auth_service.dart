/*
 *     Copyright (C) 2025 Valeri Gokadze
 *
 *     Billie is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Billie is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:billie/services/data_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // حفظ معلومات المستخدم
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      // مسح بيانات المستخدم المحلية
      await _clearUserData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserData(User user) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'isGuest': false,
      'lastSignIn': DateTime.now().toIso8601String(),
    };
    
    await addOrUpdateData('user', 'authData', userData);
  }

  Future<void> _clearUserData() async {
    await addOrUpdateData('user', 'authData', null);
  }

  Future<void> setGuestMode() async {
    final guestData = {
      'uid': 'guest_${DateTime.now().millisecondsSinceEpoch}',
      'email': null,
      'displayName': 'ضيف',
      'photoURL': null,
      'isGuest': true,
      'lastSignIn': DateTime.now().toIso8601String(),
    };
    
    await addOrUpdateData('user', 'authData', guestData);
  }

  bool get isSignedIn => currentUser != null;
  
  bool get isGuest {
    final userData = getData('user', 'authData') as Map<String, dynamic>?;
    return userData?['isGuest'] == true;
  }
}