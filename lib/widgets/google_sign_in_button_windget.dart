// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:self_finance/fonts/body_two_default_text.dart';

// class GoogleSignInButtonWidget extends StatelessWidget {
//   const GoogleSignInButtonWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       icon: const Icon(Icons.g_mobiledata_rounded),
//       onPressed: _signInWithGoogle,
//       label: const BodyTwoDefaultText(
//         text: 'Google',
//         bold: true,
//       ),
//     );
//   }

//   Future<UserCredential> _signInWithGoogle() async {
//     // Trigger the authentication flow
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

//     // Create a new credential
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth?.accessToken,
//       idToken: googleAuth?.idToken,
//     );

//     // Once signed in, return the UserCredential
//     return await FirebaseAuth.instance.signInWithCredential(credential);
//   }
// }
