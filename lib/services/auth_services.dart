import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../main.dart';
import '../model/user_data_model.dart';
import '../network/rest_apis.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import '../utils/custom_dialog_utils.dart';

class AuthService {
  //region Handle Firebase User Login and Sign Up for Chat module
  Future<UserCredential> getFirebaseUser() async {
    UserCredential? userCredential;
    try {
      /// login with Firebase
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: appStore.userEmail, password: DEFAULT_FIREBASE_PASSWORD);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        /// register user in Firebase
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: appStore.userEmail, password: DEFAULT_FIREBASE_PASSWORD);
      }
    }
    if (userCredential != null && userCredential.user == null) {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: appStore.userEmail, password: DEFAULT_FIREBASE_PASSWORD);
    }

    if (userCredential != null) {
      return userCredential;
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> verifyFirebaseUser() async {
    try {
      UserCredential userCredential = await getFirebaseUser();

      UserData userData = UserData();
      userData.id = appStore.userId;
      userData.email = appStore.userEmail;
      userData.firstName = appStore.userFirstName;
      userData.lastName = appStore.userLastName;
      userData.profileImage = appStore.userProfileImage;
      userData.updatedAt = Timestamp.now().toDate().toString();
      userData.uid = appStore.uid;
      /// Check email exists in Firebase
      /// If not exists, register user in Firebase,
      /// If exists, login with Firebase
      /// Redirect to Dashboard

      /// add user data in Firestore
      userData.uid = userCredential.user!.uid;

      bool isUserExistWithUid = await userService.isUserExistWithUid(userCredential.user!.uid);

      if (!isUserExistWithUid) {
        userData.createdAt = Timestamp.now().toDate().toString();
        await userService.addDocumentWithCustomId(userCredential.user!.uid, userData.toFirebaseJson());
      } else {
        /// Update user details in Firebase
        await userService.updateDocument(userData.toFirebaseJson(), userCredential.user!.uid);
      }

      /// Update UID & Profile Image in Laravel DB
      updateProfile({'uid': userCredential.user!.uid});

      await appStore.setUId(userCredential.user!.uid);
    } catch (e) {
      log('verifyFirebaseUser $e');
    }
  }

  //endregion

  //region Google Login
  /*Future<User> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,

      );
      if(kDebugMode){
        print("accessToken: $googleSignInAuthentication.accessToken");
        print("idToken: $googleSignInAuthentication.idToken");
      }

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);

      final User currentUser = FirebaseAuth.instance.currentUser!;
      assert(user.uid == currentUser.uid);

      try {
        AuthCredential emailAuthCredential = EmailAuthProvider.credential(email: user.email!, password: DEFAULT_FIREBASE_PASSWORD);
        user.linkWithCredential(emailAuthCredential);
      } catch (e) {
        log(e);
      }

      await googleSignIn.signOut();

      return user;
    } else {
      appStore.setLoading(false);
      throw USER_NOT_CREATED;
    }
  }*/

  // new function added scope here

  Future<User> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
     /* scopes: [
        'email',
        'https://www.googleapis.com/auth/user.addresses.read', // <-- Added scope
      ],*/
    );

    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      if (kDebugMode) {
        print("accessToken: ${googleSignInAuthentication.accessToken}");
        print("idToken: ${googleSignInAuthentication.idToken}");
      }

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);
      final User currentUser = FirebaseAuth.instance.currentUser!;
      assert(user.uid == currentUser.uid);

      try {
        AuthCredential emailAuthCredential = EmailAuthProvider.credential(
          email: user.email!,
          password: DEFAULT_FIREBASE_PASSWORD,
        );
        user.linkWithCredential(emailAuthCredential);
      } catch (e) {
        log(e.toString());
      }

      await googleSignIn.signOut();

      return user;
    } else {
      appStore.setLoading(false);
      throw USER_NOT_CREATED;
    }
  }

  //region Apple Sign In
  Future<Map<String, dynamic>> appleSignIn(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String? email = appleCredential.email;

      // 🔹 If Apple didn’t provide email, ask user manually
      if (email == null || email.isEmpty) {
        email = await askEmailWithCustomDialog(context);
        if (email == null || email.isEmpty) {
          // User didn’t provide email → stop here
          throw Exception("Email is required for Apple Sign-In");
        }
      }

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = authResult.user;

      if (user == null) {
        throw Exception("Firebase User is null");
      }

      String? idToken = await user.getIdToken(true);

      final Map<String, dynamic> userData = {
        "uid": user.uid,
        "email": email,
        "first_name": appleCredential.givenName ?? "",
        "last_name": appleCredential.familyName ?? "",
        "login_type": LOGIN_TYPE_APPLE,
        "username": email,
        "provider": "apple",
        "social_image": '',
        "idToken": appleCredential.identityToken,
        "accessToken": appleCredential.authorizationCode,
        "user_type": LOGIN_TYPE_USER,
        "fcm_token": appConfigurationStore.fcm_token,
      };

      return userData;
    } catch (error) {
      log("Apple Sign-In Error: $error");
      throw Exception("Apple Sign-In failed: $error");
    }
  }

  /// 🔹 Helper dialog to ask for email
  Future<String?> askEmailWithCustomDialog(BuildContext context) async {
    TextEditingController emailController = TextEditingController();

    String? result;
    await CustomDialogUtils.showConfirmDialogCustom(
      context,
      barrierDismissible: false,
      title: "Email Required",
      subTitle: "This app needs your email to work properly. Please provide your email to continue.",
      positiveText: "Submit",
      negativeText: "Cancel",
      primaryColor: primaryColor,
      onAccept: (ctx) {
        final email = emailController.text.trim();
        if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
          toast("Please enter a valid email"); // 🔹 nb_utils toast
          return;
        }
        result = email;
        finish(ctx, true);
      },
      onCancel: (ctx) {
        result = null;
        finish(ctx, false);
      },
      customCenterWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppTextField(
          controller: emailController,
          textFieldType: TextFieldType.EMAIL,
          decoration: inputDecoration(context, labelText: "Enter your email"),
        ),
      ),
    );

    return result;
  }



/*
  Future<Map<String, dynamic>> appleSignIn() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print("apple email: ${appleCredential.email}");
      print("apple identityToken: ${appleCredential.identityToken}");
      print("apple authorizationCode: ${appleCredential.authorizationCode}");

      final appleIdCredential = appleCredential;
      final oAuthProvider = OAuthProvider('apple.com');

      // final credential = oAuthProvider.credential(
      //   idToken: appleIdCredential.identityToken,
      //   accessToken: appleIdCredential.authorizationCode,
      // );

      final credential = OAuthProvider('apple.com').credential(
  idToken: appleIdCredential.identityToken,
);

      log('accessToken:- ${appleIdCredential.authorizationCode}}');
      log('idToken:- ${appleIdCredential.identityToken}}');

      log('credential:- $credential');

      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = authResult.user!;

      log('User:- $user');
      print('Signed in as: ${user?.uid}');


      if (appleIdCredential.email.validate().isNotEmpty) {
        appStore.setLoading(true);

        await setValue(APPLE_EMAIL, appleIdCredential.email);
        await setValue(APPLE_GIVE_NAME, appleIdCredential.givenName);
        await setValue(APPLE_FAMILY_NAME, appleIdCredential.familyName);
      } else {
        await setValue(APPLE_EMAIL, user.email.validate());
      }
      await setValue(APPLE_UID, user.uid.validate());

      log('UID: ${getStringAsync(APPLE_UID)}');
      log('Email:- ${getStringAsync(APPLE_EMAIL)}');
      log('appleGivenName:- ${getStringAsync(APPLE_GIVE_NAME)}');
      log('appleFamilyName:- ${getStringAsync(APPLE_FAMILY_NAME)}');

      var req = {
        'email': getStringAsync(APPLE_EMAIL),
        'first_name': getStringAsync(APPLE_GIVE_NAME),
        'last_name': getStringAsync(APPLE_FAMILY_NAME),
        "username": getStringAsync(APPLE_EMAIL),
        "social_image": '',
        'accessToken': appleIdCredential.identityToken,
        'login_type': LOGIN_TYPE_APPLE,
        "user_type": LOGIN_TYPE_USER,
        'fcm_token': appConfigurationStore.fcm_token
      };

      log("Apple Login Json" + jsonEncode(req));

      return req;
    } catch (e) {
        throw language.lblAppleSignInNotAvailable;
    }
  }*/
//endregion
}
