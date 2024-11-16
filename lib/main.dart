import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app_3/firebase_options.dart';
import 'package:loan_app_3/screens/about_screen.dart';
import 'package:loan_app_3/screens/board_screen.dart';
import 'package:loan_app_3/screens/faqs_screen.dart';
import 'package:loan_app_3/screens/forgot_password_screen.dart';
import 'package:loan_app_3/screens/loan_application_screen.dart';
import 'package:loan_app_3/screens/loan_status_screen.dart';
import 'package:loan_app_3/screens/login_screen.dart';
import 'package:loan_app_3/screens/main_page.dart';
import 'package:loan_app_3/screens/otp_verification_screen.dart';
import 'package:loan_app_3/screens/personal_info_screen.dart';
import 'package:loan_app_3/screens/personal_information_screen.dart';
import 'package:loan_app_3/screens/phone_verification_screen.dart';
import 'package:loan_app_3/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before anything else
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// Initialize App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
    // Use AndroidProvider.debug for development
    androidProvider: AndroidProvider.debug,
    // Use AppleProvider.appAttest for production, debug for development
    appleProvider: AppleProvider.debug,
  );
  // Configure Firebase Auth settings
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
      phoneNumber: '+923333333333',
      smsCode: '123456',
    );
  } else {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: false,
      phoneNumber: null,
      smsCode: null,
    );
  }
  // if (kDebugMode) {
  //   await FirebaseAuth.instance.setSettings(
  //     appVerificationDisabledForTesting: true,
  //   );
  // }
  // Set default error handler
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontFamily: 'Roboto', // Using system font as fallback
              ),
            ),
          ],
        ),
      ),
    );
  };

  // Configure Google Fonts to use local fonts as fallback
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use try-catch for font loading
    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.poppinsTextTheme();
    } catch (e) {
      // Fallback to system default font if Google Fonts fails
      textTheme = Theme.of(context).textTheme;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LendMingle',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffD9FF7E),
          primary: const Color(0xffD9FF7E),
          secondary: const Color(0xff83A43F),
        ),
        scaffoldBackgroundColor: const Color(0xffD9FF7E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: textTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: const Color(0xff83A43F),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xff83A43F),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xff83A43F),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          hintStyle: const TextStyle(
            color: Colors.black38,
            fontSize: 15,
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xff83A43F),
        ),
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/boardingScreen': (context) => const BoardingScreen(),
        '/mainPage': (context) => const MainPage(),
        '/loginPage': (context) => const LoginScreen(),
        '/phoneVerification': (context) => const PhoneVerificationScreen(),
        '/otpVerification': (context) => const OTPVerificationScreen(),
        '/personalInfo': (context) => const PersonalInfoScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/editProfile': (context) => const PersonalInformationScreen(),
        '/helpsupport': (context) => const HelpAndSupportScreen(),
        '/about': (context) => const AboutScreen(),
        '/loanApplicationform': (context) => const LoanApplicationScreen(),
        '/loanStatus': (context) => LoanStatusScreen(),
      },
      initialRoute: '/',
    );
  }
}
