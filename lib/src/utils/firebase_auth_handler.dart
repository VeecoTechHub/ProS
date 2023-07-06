import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pinput/pinput.dart';
import 'package:pro_z/pro_z.dart';

class FirebaseAuthHandler extends GetxController {
  static FirebaseAuthHandler get to => Get.find();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleAuth = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  String verificationId = '';

  Future<User?> loginWithEmailAndPassword(
      {required String email,
      String password = "Password123!",
      bool autoCreate = false}) async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        print(_firebaseAuth.currentUser.toString());
      });
      if (_firebaseAuth.currentUser != null && googleAuth.currentUser != null) {
        final GoogleSignInAccount? googleSignInAccount =
            await googleAuth.signInSilently();
        final GoogleSignInAuthentication? googleSignInAuthentication =
            await googleSignInAccount?.authentication;
        await _firebaseAuth.currentUser
            ?.linkWithCredential(GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication?.accessToken,
          idToken: googleSignInAuthentication?.idToken,
        ));
      }
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          if (autoCreate) {
            Loading.show('Creating Account');
            return await registerWithEmailAndPassword(email: email)
                .then((value) {
              Loading.dismiss();
              return value;
            });
          } else {
            Loading.error('No user found.');
          }
          break;
        case 'wrong-password':
          Loading.error('Wrong password provided.');
          break;
        default:
          Loading.error(e.message);
          break;
      }
    }
    return null;
  }

  Future<User?> registerWithEmailAndPassword(
      {required String email, String password = "Password123!"}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (_firebaseAuth.currentUser != null && googleAuth.currentUser != null) {
        final GoogleSignInAccount? googleSignInAccount =
            await googleAuth.signInSilently();
        final GoogleSignInAuthentication? googleSignInAuthentication =
            await googleSignInAccount?.authentication;
        await _firebaseAuth.currentUser
            ?.linkWithCredential(GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication?.accessToken,
          idToken: googleSignInAuthentication?.idToken,
        ));
      }
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          Loading.error('The password is too weak.');
          break;
        case 'email-already-in-use':
          Loading.error('The email already registered.');
          break;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<GoogleSignInAccount?> loginWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleAuth.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication?.accessToken,
      idToken: googleSignInAuthentication?.idToken,
    );
    final isAccountUsed = await isEmailUsed(googleSignInAccount?.email);
    if (!isAccountUsed && _firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser?.linkWithCredential(credential);
    } else if (isAccountUsed) {
      await _firebaseAuth.signInWithCredential(credential);
    }
    return googleAuth.currentUser;
  }

  Future<bool> isEmailUsed(String? email) async {
    if (email == null) return false;
    return (await _firebaseAuth.fetchSignInMethodsForEmail(email)).isNotEmpty;
  }

  Future<bool> updateEmail(String email) async {
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser?.updateEmail(email);
      return true;
    }
    return false;
  }

  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await googleAuth.signOut();
    await _facebookAuth.logOut();
    await _firebaseAuth.currentUser?.reload();
  }

  Future<void> signInWithPhone(
    String phoneNumber, {
    required Function onSuccess,
    required Function(FirebaseAuthException) onFailed,
    Map<String, String>? syncData,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 0),
        verificationCompleted:
            (PhoneAuthCredential phoneAuthCredential) async {},
        verificationFailed: onFailed,
        codeSent: (id, token) async {
          verificationId = id;
          await otpBottomSheet().then(
            (otpCode) async {
              Loading.show();
              if (otpCode != null) {
                await verifyOtp(
                  otpCode: otpCode,
                  onSuccess: onSuccess,
                  onFailed: onFailed,
                  syncData: syncData,
                );
              }
              Loading.dismiss();
            },
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      Loading.error(e.message);
    }
  }

  Future<void> verifyOtp({
    required String otpCode,
    required Function onSuccess,
    required Function(FirebaseAuthException e) onFailed,
    Map<String, String>? syncData,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpCode);
      if (syncData != null) {
        await loginWithEmailAndPassword(
                email: syncData['email']!, autoCreate: true)
            .then((value) async {
          if (_firebaseAuth.currentUser != null) {
            await _firebaseAuth.currentUser
                ?.updateDisplayName(syncData['name']!);
            await _firebaseAuth.currentUser?.linkWithCredential(credential);
            onSuccess();
          }
        });
      } else {
        await _firebaseAuth
            .signInWithCredential(credential)
            .then((value) => value.user != null ? onSuccess() : null);
      }
    } on FirebaseAuthException catch (e) {
      Loading.error(e.message);
      onFailed(e);
    }
  }

  Future<String?> otpBottomSheet() async => await Get.bottomSheet<String>(
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                "Verification",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Enter the OTP send to your phone number",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Pinput(
                  length: 6,
                  showCursor: true,
                  autofocus: true,
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  defaultPinTheme: PinTheme(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xffd3af37)),
                    ),
                    textStyle: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onCompleted: (value) => Get.back(result: value),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 150.w),
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd3af37),
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(40.h),
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(fontSize: 25.sp),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Didn't receive any code?",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                "Resend New Code",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffd3af37),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        enableDrag: false,
        isDismissible: false,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35.r),
            topRight: Radius.circular(35.r),
          ),
        ),
      );
}
