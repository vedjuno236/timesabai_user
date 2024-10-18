// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart'; // Add this
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timesabai/views/screens/home_index.dart';
// import 'package:timesabai/views/screens/login_screens/login_screens.dart';
//
// import 'components/model/user_model/user_model.dart';
// import 'components/services/firebase_notification.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   await FirebaseNotification().initNotifitions();
//
//   await initializeDateFormatting('lo_LA', null);
//   Intl.defaultLocale = 'lo_LA';
//
//   runApp(ProviderScope(child: const MyApp()));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Time Sabai',
//       theme: ThemeData(
//
//         scaffoldBackgroundColor: const Color(0xFFF8F9FC),
//         useMaterial3: true,
//       ),
//       locale: const Locale('lo', 'LA'),
//       supportedLocales: const [
//         Locale('lo', 'LA'),
//         Locale('en', 'US'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       home: const AuthCheck(),
//     );
//   }
// }
//
// class AuthCheck extends StatefulWidget {
//   const AuthCheck({Key? key}) : super(key: key);
//
//   @override
//   _AuthCheckState createState() => _AuthCheckState();
// }
//
// class _AuthCheckState extends State<AuthCheck> {
//   bool userAvailable = false;
//   late SharedPreferences sharedPreferences; // Declare it here
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//   }
//
//   void _getCurrentUser() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//
//     try {
//       if (sharedPreferences.getString('token') != null) {
//         setState(() {
//           Employee.employeeId = sharedPreferences.getString('token')!;
//           userAvailable = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         userAvailable = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return userAvailable ? const HomeIndex() : const LoginScreens();
//   }
// }
//
//
//
//
//
//
//
//
//






// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timesabai/views/screens/home_index.dart';
// import 'package:timesabai/views/screens/login_screens/login_screens.dart';
//
// import 'components/model/user_model/user_model.dart';
// import 'components/services/firebase_notification.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   await FirebaseNotification().initNotifitions();
//
//   await initializeDateFormatting('lo_LA', null);
//   Intl.defaultLocale = 'lo_LA';
//
//   runApp(ProviderScope(child: const MyApp()));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Time Sabai',
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFFF8F9FC),
//         useMaterial3: true,
//       ),
//       locale: const Locale('lo', 'LA'),
//       supportedLocales: const [
//         Locale('lo', 'LA'),
//         Locale('en', 'US'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       home: const AuthCheck(),
//     );
//   }
// }
//
// class AuthCheck extends StatefulWidget {
//   const AuthCheck({Key? key}) : super(key: key);
//
//   @override
//   _AuthCheckState createState() => _AuthCheckState();
// }
//
// class _AuthCheckState extends State<AuthCheck> {
//   bool userAvailable = false;
//   late SharedPreferences sharedPreferences;
//   String locationMessage = 'Checking location...';
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//   }
//
//   void _getCurrentUser() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//
//     try {
//       if (sharedPreferences.getString('token') != null) {
//         setState(() {
//           Employee.employeeId = sharedPreferences.getString('token')!;
//           userAvailable = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         userAvailable = false;
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return userAvailable ? const HomeIndex() : const LoginScreens();
//   }
// }
//
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: buildAnimation(),
//         ),
//       ),
//     );
//   }
//
//   Widget buildAnimation() {
//     return Center(
//       child: Container(
//         child: Lottie.network(
//           "https://assets5.lottiefiles.com/packages/lf20_jcikwtux.json", // Use a valid Lottie JSON URL here
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesabai/views/screens/home_index.dart';
import 'package:timesabai/views/screens/login_screens/login_screens.dart';

import 'components/model/user_model/user_model.dart';
import 'components/services/firebase_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseNotification().initNotifitions();
  await initializeDateFormatting('lo_LA', null);
  Intl.defaultLocale = 'lo_LA';

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Sabai',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        useMaterial3: true,
      ),
      locale: const Locale('lo', 'LA'),
      supportedLocales: const [
        Locale('lo', 'LA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthCheck()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.network(
          "https://lottie.host/402b2330-0d9b-47e3-b998-73536ecd1af2/3yE7yI8AH9.json",
        ),
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;
  String locationMessage = 'Checking location...';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();

    try {
      if (sharedPreferences.getString('token') != null) {
        setState(() {
          Employee.employeeId = sharedPreferences.getString('token')!;
          userAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? const HomeIndex() : const LoginScreens();
  }
}
