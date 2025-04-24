import 'package:farmcast/firebase_options.dart';
import 'package:farmcast/pages/crop_details_page.dart';
import 'package:farmcast/pages/overview_page.dart';
import 'package:farmcast/pages/signin_page.dart';
import 'package:farmcast/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Cast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routes: {
        '/login': (context) => SigninPage(),
        '/signup': (context) => SignupPage(),
        '/overview': (context) => const OverviewPage(),
        '/cropDetails': (context) => const CropDetailsPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data != null) {
            return const OverviewPage();
          }
          return const SignupPage();
        },
      ),
    );
  }
}
