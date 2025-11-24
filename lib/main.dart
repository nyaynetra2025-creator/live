import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'otp_verification_page.dart';
import 'home_page.dart';
import 'chatbot_page.dart';
import 'lawyer_directory_page.dart';
import 'profile_page.dart';
import 'pages/advocate_welcome_step1.dart';
import 'pages/personal_details.dart';
import 'pages/practice_information_page.dart';
import 'pages/profile_preview_page.dart';
import 'pages/lawyer_dashboard_page.dart';
import 'pages/client_requests.dart';
import 'pages/lawyer_chats_page.dart';
import 'pages/lawyer_cases_page.dart';
import 'pages/lawyer_availability_page.dart';
import 'pages/lawyer_profile_page.dart';
import 'pages/coming_soon_page.dart';
import 'pages/document_scanner_page.dart';
import 'pages/case_law_search_page.dart';
import 'pages/legal_rights_module_page.dart';
import 'pages/bookmarks_page.dart';
import 'pages/my_cases_page.dart';
import 'pages/lawyer_signin_page.dart';
import 'pages/lawyer_signup_page.dart';
import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://laxyyckscgflsnbxpeso.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxheHl5Y2tzY2dmbHNuYnhwZXNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4ODcyMjQsImV4cCI6MjA3OTQ2MzIyNH0.jlFUxA1hop8bYSVVdJ6UuAPiIa0-C8tVd6zl0rmMeeU',
  );

  runApp(const NyaynetraApp());
}

class NyaynetraApp extends StatelessWidget {
  const NyaynetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nyaynetra',
      theme: ThemeData(
        primaryColor: const Color(0xFF253D7A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFF6B21D),
        ),
        fontFamily: 'Inter',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF253D7A),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        ).copyWith(secondary: const Color(0xFFF6B21D)),
        fontFamily: 'Inter',
        brightness: Brightness.dark,
      ),
      // Check if user is logged in
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashPage(),
        '/': (_) => const WelcomePage(),
        '/signin': (_) => const SignInPage(),
        '/signup': (_) => SignUpPage(),
        '/otp': (_) => const OtpVerificationPage(),
        '/home': (_) => const HomePage(),
        '/chatbot': (_) => const ChatBotPage(),
        '/lawyers': (_) => const LawyerDirectoryPage(),
        '/profile': (_) => const ProfilePage(),
        '/advocate_step1': (_) => const AdvocateWelcomeStep1(),
        '/personal_details': (_) => const PersonalDetailsPage(),
        '/practice_information': (_) => const PracticeInformationPage(),
        '/profile_preview': (_) => const ProfilePreviewPage(),
        '/lawyer_dashboard': (_) => const LawyerDashboardPage(),
        '/client_requests': (_) => const ClientRequestsPage(),
        '/lawyer_chats': (_) => const LawyerChatsPage(),
        '/lawyer_cases': (_) => const LawyerCasesPage(),
        '/lawyer_availability': (_) => const LawyerAvailabilityPage(),
        '/lawyer_profile': (_) => const LawyerProfilePage(),
        '/laws': (_) => const ComingSoonPage(title: 'Laws A-Z'),
        '/emergency': (_) => const ComingSoonPage(title: 'Emergency Help'),
        '/document-scanner': (_) => const DocumentScannerPage(),
        '/case-law': (_) => const CaseLawSearchPage(),
        '/legal-rights': (_) => const LegalRightsModulePage(),
        '/bookmarks': (_) => const BookmarksPage(),
        '/my-cases': (_) => const MyCasesPage(),
        '/lawyer_signin': (_) => const LawyerSignInPage(),
        '/lawyer_signup': (_) => const LawyerSignUpPage(),
      },
    );
  }
}
