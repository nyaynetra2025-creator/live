import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model class representing a language
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String script;
  final IconData? icon;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.script,
    this.icon,
  });
}

/// Service class for managing language preferences
class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static LanguageService? _instance;
  
  String _currentLanguageCode = 'en';
  
  // Singleton pattern
  static LanguageService get instance {
    _instance ??= LanguageService._();
    return _instance!;
  }
  
  LanguageService._();
  
  String get currentLanguageCode => _currentLanguageCode;
  
  AppLanguage get currentLanguage {
    return allLanguages.firstWhere(
      (lang) => lang.code == _currentLanguageCode,
      orElse: () => allLanguages.first,
    );
  }

  /// List of all Indian languages supported by the app
  static const List<AppLanguage> allLanguages = [
    // Official Languages of India (22 Scheduled Languages + English)
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      script: 'Latin',
    ),
    AppLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      script: 'Bengali',
    ),
    AppLanguage(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      script: 'Telugu',
    ),
    AppLanguage(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      script: 'Tamil',
    ),
    AppLanguage(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      script: 'Gujarati',
    ),
    AppLanguage(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      script: 'Perso-Arabic',
    ),
    AppLanguage(
      code: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      script: 'Kannada',
    ),
    AppLanguage(
      code: 'or',
      name: 'Odia',
      nativeName: 'ଓଡ଼ିଆ',
      script: 'Odia',
    ),
    AppLanguage(
      code: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      script: 'Malayalam',
    ),
    AppLanguage(
      code: 'pa',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      script: 'Gurmukhi',
    ),
    AppLanguage(
      code: 'as',
      name: 'Assamese',
      nativeName: 'অসমীয়া',
      script: 'Assamese',
    ),
    AppLanguage(
      code: 'mai',
      name: 'Maithili',
      nativeName: 'मैथिली',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'sat',
      name: 'Santali',
      nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
      script: 'Ol Chiki',
    ),
    AppLanguage(
      code: 'ks',
      name: 'Kashmiri',
      nativeName: 'कॉशुर',
      script: 'Devanagari/Perso-Arabic',
    ),
    AppLanguage(
      code: 'ne',
      name: 'Nepali',
      nativeName: 'नेपाली',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'sd',
      name: 'Sindhi',
      nativeName: 'سنڌي',
      script: 'Perso-Arabic/Devanagari',
    ),
    AppLanguage(
      code: 'kok',
      name: 'Konkani',
      nativeName: 'कोंकणी',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'doi',
      name: 'Dogri',
      nativeName: 'डोगरी',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'mni',
      name: 'Manipuri',
      nativeName: 'মৈতৈলোন্',
      script: 'Meitei/Bengali',
    ),
    AppLanguage(
      code: 'sa',
      name: 'Sanskrit',
      nativeName: 'संस्कृतम्',
      script: 'Devanagari',
    ),
    AppLanguage(
      code: 'bo',
      name: 'Bodo',
      nativeName: 'बड़ो',
      script: 'Devanagari',
    ),
  ];

  /// Initialize the service and load saved preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString(_languageKey) ?? 'en';
    notifyListeners();
  }

  /// Set the current language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguageCode != languageCode) {
      _currentLanguageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  /// Get all languages grouped by region
  static Map<String, List<AppLanguage>> get languagesByRegion {
    return {
      'Popular': allLanguages.where((l) => 
        ['en', 'hi', 'bn', 'te', 'mr', 'ta'].contains(l.code)
      ).toList(),
      'North India': allLanguages.where((l) => 
        ['hi', 'pa', 'ur', 'ks', 'doi', 'ne'].contains(l.code)
      ).toList(),
      'South India': allLanguages.where((l) => 
        ['ta', 'te', 'kn', 'ml'].contains(l.code)
      ).toList(),
      'East India': allLanguages.where((l) => 
        ['bn', 'or', 'as', 'mai', 'mni'].contains(l.code)
      ).toList(),
      'West India': allLanguages.where((l) => 
        ['mr', 'gu', 'sd', 'kok'].contains(l.code)
      ).toList(),
      'Classical Languages': allLanguages.where((l) => 
        ['sa', 'ta'].contains(l.code)
      ).toList(),
      'Tribal Languages': allLanguages.where((l) => 
        ['sat', 'bo'].contains(l.code)
      ).toList(),
    };
  }

  /// Get translations for common UI strings
  /// Note: In a production app, you would use proper i18n with .arb files
  /// This is a simplified implementation for demo purposes
  static Map<String, Map<String, String>> get translations {
    return {
      // Welcome Page
      'welcome': {
        'en': 'Welcome to Nyaynetra',
        'hi': 'न्यायनेत्र में आपका स्वागत है',
        'bn': 'ন্যায়নেত্রায় স্বাগতম',
        'te': 'న్యాయనేత్రకు స్వాగతం',
        'mr': 'न्यायनेत्रामध्ये आपले स्वागत आहे',
        'ta': 'நீதிநேத்ராவிற்கு வரவேற்கிறோம்',
        'gu': 'ન્યાયનેત્રામાં આપનું સ્વાગત છે',
        'kn': 'ನ್ಯಾಯನೇತ್ರಕ್ಕೆ ಸ್ವಾಗತ',
        'ml': 'ന്യായനേത്രയിലേക്ക് സ്വാഗതം',
        'pa': 'ਨਿਆਯਨੇਤਰਾ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ',
        'ur': 'نیائے نیترا میں خوش آمدید',
        'or': 'ନ୍ୟାୟନେତ୍ରାକୁ ସ୍ୱାଗତ',
        'as': 'ন্যায়নেত্ৰলৈ স্বাগতম',
      },
      'welcome_subtitle': {
        'en': 'Your Legal Companion',
        'hi': 'आपका कानूनी साथी',
        'bn': 'আপনার আইনি সহচর',
        'te': 'మీ చట్టపరమైన సహచరుడు',
        'mr': 'तुमचा कायदेशीर साथीदार',
        'ta': 'உங்கள் சட்ட துணை',
        'gu': 'તમારો કાનૂની સાથી',
        'kn': 'ನಿಮ್ಮ ಕಾನೂನು ಒಡನಾಡಿ',
        'ml': 'നിങ്ങളുടെ നിയമ സഹായി',
        'pa': 'ਤੁਹਾਡਾ ਕਾਨੂੰਨੀ ਸਾਥੀ',
      },
      'i_am_client': {
        'en': "I'm a Client",
        'hi': 'मैं एक ग्राहक हूं',
        'bn': 'আমি একজন ক্লায়েন্ট',
        'te': 'నేను క్లయింట్‌ని',
        'mr': 'मी एक ग्राहक आहे',
        'ta': 'நான் ஒரு வாடிக்கையாளர்',
        'gu': 'હું એક ક્લાયન્ટ છું',
        'kn': 'ನಾನು ಗ್ರಾಹಕ',
        'ml': 'ഞാൻ ഒരു ക്ലയന്റാണ്',
        'pa': 'ਮੈਂ ਇੱਕ ਗਾਹਕ ਹਾਂ',
      },
      'i_am_advocate': {
        'en': "I'm an Advocate",
        'hi': 'मैं एक वकील हूं',
        'bn': 'আমি একজন অ্যাডভোকেট',
        'te': 'నేను అడ్వకేట్‌ని',
        'mr': 'मी एक वकील आहे',
        'ta': 'நான் ஒரு வழக்கறிஞர்',
        'gu': 'હું એક વકીલ છું',
        'kn': 'ನಾನು ವಕೀಲ',
        'ml': 'ഞാൻ ഒരു അഭിഭാഷകൻ',
        'pa': 'ਮੈਂ ਇੱਕ ਵਕੀਲ ਹਾਂ',
      },
      // Navigation
      'home': {
        'en': 'Home',
        'hi': 'होम',
        'bn': 'হোম',
        'te': 'హోమ్',
        'mr': 'होम',
        'ta': 'முகப்பு',
        'gu': 'હોમ',
        'kn': 'ಮುಖಪುಟ',
        'ml': 'ഹോം',
        'pa': 'ਘਰ',
      },
      'profile': {
        'en': 'Profile',
        'hi': 'प्रोफाइल',
        'bn': 'প্রোফাইল',
        'te': 'ప్రొఫైల్',
        'mr': 'प्रोफाइल',
        'ta': 'சுயவிவரம்',
        'gu': 'પ્રોફાઇલ',
        'kn': 'ಪ್ರೊಫೈಲ್',
        'ml': 'പ്രൊഫൈൽ',
        'pa': 'ਪ੍ਰੋਫਾਈਲ',
      },
      'settings': {
        'en': 'Settings',
        'hi': 'सेटिंग्स',
        'bn': 'সেটিংস',
        'te': 'సెట్టింగ్స్',
        'mr': 'सेटिंग्ज',
        'ta': 'அமைப்புகள்',
        'gu': 'સેટિંગ્સ',
        'kn': 'ಸೆಟ್ಟಿಂಗ್ಸ್',
        'ml': 'ക്രമീകരണങ്ങൾ',
        'pa': 'ਸੈਟਿੰਗਾਂ',
      },
      'language': {
        'en': 'Language',
        'hi': 'भाषा',
        'bn': 'ভাষা',
        'te': 'భాష',
        'mr': 'भाषा',
        'ta': 'மொழி',
        'gu': 'ભાષા',
        'kn': 'ಭಾಷೆ',
        'ml': 'ഭാഷ',
        'pa': 'ਭਾਸ਼ਾ',
      },
      'select_language': {
        'en': 'Select Language',
        'hi': 'भाषा चुनें',
        'bn': 'ভাষা নির্বাচন করুন',
        'te': 'భాష ఎంచుకోండి',
        'mr': 'भाषा निवडा',
        'ta': 'மொழியைத் தேர்ந்தெடுக்கவும்',
        'gu': 'ભાષા પસંદ કરો',
        'kn': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
        'ml': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
        'pa': 'ਭਾਸ਼ਾ ਚੁਣੋ',
      },
      // Features
      'chat': {
        'en': 'Chat',
        'hi': 'चैट',
        'bn': 'চ্যাট',
        'te': 'చాట్',
        'mr': 'चॅट',
        'ta': 'அரட்டை',
        'gu': 'ચેટ',
        'kn': 'ಚಾಟ್',
        'ml': 'ചാറ്റ്',
        'pa': 'ਚੈਟ',
      },
      'lawyers': {
        'en': 'Lawyers',
        'hi': 'वकील',
        'bn': 'আইনজীবী',
        'te': 'లాయర్లు',
        'mr': 'वकील',
        'ta': 'வழக்கறிஞர்கள்',
        'gu': 'વકીલો',
        'kn': 'ವಕೀಲರು',
        'ml': 'അഭിഭാഷകർ',
        'pa': 'ਵਕੀਲ',
      },
      'find_lawyers': {
        'en': 'Find Lawyers',
        'hi': 'वकील खोजें',
        'bn': 'আইনজীবী খুঁজুন',
        'te': 'లాయర్లను కనుగొనండి',
        'mr': 'वकील शोधा',
        'ta': 'வழக்கறிஞர்களைக் கண்டறியுங்கள்',
        'gu': 'વકીલો શોધો',
        'kn': 'ವಕೀಲರನ್ನು ಹುಡುಕಿ',
        'ml': 'അഭിഭാഷകരെ കണ്ടെത്തുക',
        'pa': 'ਵਕੀਲ ਲੱਭੋ',
      },
      'legal_rights': {
        'en': 'Legal Rights',
        'hi': 'कानूनी अधिकार',
        'bn': 'আইনি অধিকার',
        'te': 'చట్టపరమైన హక్కులు',
        'mr': 'कायदेशीर हक्क',
        'ta': 'சட்ட உரிமைகள்',
        'gu': 'કાનૂની અધિકાર',
        'kn': 'ಕಾನೂನು ಹಕ್ಕುಗಳು',
        'ml': 'നിയമ അവകാശങ്ങൾ',
        'pa': 'ਕਾਨੂੰਨੀ ਅਧਿਕਾਰ',
      },
      'know_rights': {
        'en': 'Know Your Rights',
        'hi': 'अपने अधिकार जानें',
        'bn': 'আপনার অধিকার জানুন',
        'te': 'మీ హక్కులను తెలుసుకోండి',
        'mr': 'तुमचे हक्क जाणून घ्या',
        'ta': 'உங்கள் உரிமைகளை அறியுங்கள்',
        'gu': 'તમારા અધિકાર જાણો',
        'kn': 'ನಿಮ್ಮ ಹಕ್ಕುಗಳನ್ನು ತಿಳಿಯಿರಿ',
        'ml': 'നിങ്ങളുടെ അവകാശങ്ങൾ അറിയുക',
        'pa': 'ਆਪਣੇ ਅਧਿਕਾਰ ਜਾਣੋ',
      },
      'document_scanner': {
        'en': 'Document Scanner',
        'hi': 'दस्तावेज़ स्कैनर',
        'bn': 'নথি স্ক্যানার',
        'te': 'డాక్యుమెంట్ స్కానర్',
        'mr': 'दस्तऐवज स्कॅनर',
        'ta': 'ஆவண ஸ்கேனர்',
        'gu': 'દસ્તાવેજ સ્કેનર',
        'kn': 'ಡಾಕ್ಯುಮೆಂಟ್ ಸ್ಕ್ಯಾನರ್',
        'ml': 'ഡോക്യുമെന്റ് സ്കാനർ',
        'pa': 'ਦਸਤਾਵੇਜ਼ ਸਕੈਨਰ',
      },
      'ai_chatbot': {
        'en': 'AI Legal Assistant',
        'hi': 'AI कानूनी सहायक',
        'bn': 'AI আইনি সহায়ক',
        'te': 'AI చట్ట సహాయకుడు',
        'mr': 'AI कायदेशीर सहाय्यक',
        'ta': 'AI சட்ட உதவியாளர்',
        'gu': 'AI કાનૂની સહાયક',
        'kn': 'AI ಕಾನೂನು ಸಹಾಯಕ',
        'ml': 'AI നിയമ സഹായി',
        'pa': 'AI ਕਾਨੂੰਨੀ ਸਹਾਇਕ',
      },
      'laws_acts': {
        'en': 'Laws & Acts',
        'hi': 'कानून और अधिनियम',
        'bn': 'আইন ও অধিনিয়ম',
        'te': 'చట్టాలు & చట్టాలు',
        'mr': 'कायदे आणि कायदे',
        'ta': 'சட்டங்கள் & சட்டங்கள்',
        'gu': 'કાયદાઓ અને અધિનિયમો',
        'kn': 'ಕಾನೂನುಗಳು ಮತ್ತು ಕಾಯಿದೆಗಳು',
        'ml': 'നിയമങ്ങളും ആക്ടുകളും',
        'pa': 'ਕਾਨੂੰਨ ਅਤੇ ਐਕਟ',
      },
      'legal_news': {
        'en': 'Legal News',
        'hi': 'कानूनी समाचार',
        'bn': 'আইনি সংবাদ',
        'te': 'చట్ట వార్తలు',
        'mr': 'कायदेशीर बातम्या',
        'ta': 'சட்ட செய்திகள்',
        'gu': 'કાનૂની સમાચાર',
        'kn': 'ಕಾನೂನು ಸುದ್ದಿ',
        'ml': 'നിയമ വാർത്തകൾ',
        'pa': 'ਕਾਨੂੰਨੀ ਖ਼ਬਰਾਂ',
      },
      'quick_actions': {
        'en': 'Quick Actions',
        'hi': 'त्वरित कार्य',
        'bn': 'দ্রুত কাজ',
        'te': 'త్వరిత చర్యలు',
        'mr': 'द्रुत क्रिया',
        'ta': 'விரைவு செயல்கள்',
        'gu': 'ઝડપી ક્રિયાઓ',
        'kn': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
        'ml': 'വേഗത്തിലുള്ള പ്രവർത്തനങ്ങൾ',
        'pa': 'ਤੇਜ਼ ਕਾਰਵਾਈਆਂ',
      },
      // Common Actions
      'search': {
        'en': 'Search',
        'hi': 'खोजें',
        'bn': 'অনুসন্ধান',
        'te': 'వెతకండి',
        'mr': 'शोधा',
        'ta': 'தேடு',
        'gu': 'શોધો',
        'kn': 'ಹುಡುಕು',
        'ml': 'തിരയുക',
        'pa': 'ਖੋਜੋ',
      },
      'logout': {
        'en': 'Logout',
        'hi': 'लॉग आउट',
        'bn': 'লগ আউট',
        'te': 'లాగ్ అవుట్',
        'mr': 'लॉग आउट',
        'ta': 'வெளியேறு',
        'gu': 'લૉગ આઉટ',
        'kn': 'ಲಾಗ್ ಔಟ್',
        'ml': 'ലോഗൗട്ട്',
        'pa': 'ਲੌਗ ਆਊਟ',
      },
      'dark_mode': {
        'en': 'Dark Mode',
        'hi': 'डार्क मोड',
        'bn': 'ডার্ক মোড',
        'te': 'డార్క్ మోడ్',
        'mr': 'डार्क मोड',
        'ta': 'இருள் பயன்முறை',
        'gu': 'ડાર્ક મોડ',
        'kn': 'ಡಾರ್ಕ್ ಮೋಡ್',
        'ml': 'ഡാർക്ക് മോഡ്',
        'pa': 'ਡਾਰਕ ਮੋਡ',
      },
      'notifications': {
        'en': 'Notifications',
        'hi': 'सूचनाएं',
        'bn': 'বিজ্ঞপ্তি',
        'te': 'నోటిఫికేషన్లు',
        'mr': 'सूचना',
        'ta': 'அறிவிப்புகள்',
        'gu': 'સૂચનાઓ',
        'kn': 'ಅಧಿಸೂಚನೆಗಳು',
        'ml': 'അറിയിപ്പുകൾ',
        'pa': 'ਸੂਚਨਾਵਾਂ',
      },
      'bookmarks': {
        'en': 'Bookmarks',
        'hi': 'बुकमार्क',
        'bn': 'বুকমার্ক',
        'te': 'బుక్‌మార్క్‌లు',
        'mr': 'बुकमार्क',
        'ta': 'புக்மார்க்குகள்',
        'gu': 'બુકમાર્ક્સ',
        'kn': 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು',
        'ml': 'ബുക്ക്മാർക്കുകൾ',
        'pa': 'ਬੁੱਕਮਾਰਕ',
      },
      'my_cases': {
        'en': 'My Cases',
        'hi': 'मेरे मामले',
        'bn': 'আমার মামলা',
        'te': 'నా కేసులు',
        'mr': 'माझे खटले',
        'ta': 'என் வழக்குகள்',
        'gu': 'મારા કેસો',
        'kn': 'ನನ್ನ ಪ್ರಕರಣಗಳು',
        'ml': 'എന്റെ കേസുകൾ',
        'pa': 'ਮੇਰੇ ਕੇਸ',
      },
      'about': {
        'en': 'About',
        'hi': 'के बारे में',
        'bn': 'সম্পর্কে',
        'te': 'గురించి',
        'mr': 'बद्दल',
        'ta': 'பற்றி',
        'gu': 'વિશે',
        'kn': 'ಬಗ್ಗೆ',
        'ml': 'കുറിച്ച്',
        'pa': 'ਬਾਰੇ',
      },
      'help_support': {
        'en': 'Help & Support',
        'hi': 'सहायता और समर्थन',
        'bn': 'সাহায্য ও সহায়তা',
        'te': 'సహాయం & మద్దతు',
        'mr': 'मदत आणि समर्थन',
        'ta': 'உதவி & ஆதரவு',
        'gu': 'મદદ અને સપોર્ટ',
        'kn': 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ',
        'ml': 'സഹായവും പിന്തുണയും',
        'pa': 'ਮਦਦ ਅਤੇ ਸਹਾਇਤਾ',
      },
      'privacy_policy': {
        'en': 'Privacy Policy',
        'hi': 'गोपनीयता नीति',
        'bn': 'গোপনীয়তা নীতি',
        'te': 'గోప్యతా విధానం',
        'mr': 'गोपनीयता धोरण',
        'ta': 'தனியுரிமைக் கொள்கை',
        'gu': 'ગોપનીયતા નીતિ',
        'kn': 'ಗೋಪ್ಯತಾ ನೀತಿ',
        'ml': 'സ്വകാര്യതാ നയം',
        'pa': 'ਪ੍ਰਾਈਵੇਸੀ ਪਾਲਿਸੀ',
      },
      'terms_of_service': {
        'en': 'Terms of Service',
        'hi': 'सेवा की शर्तें',
        'bn': 'পরিষেবার শর্তাবলী',
        'te': 'సేవా నిబంధనలు',
        'mr': 'सेवेच्या अटी',
        'ta': 'சேவை விதிமுறைகள்',
        'gu': 'સેવાની શરતો',
        'kn': 'ಸೇವಾ ನಿಯಮಗಳು',
        'ml': 'സേവന നിബന്ധനകൾ',
        'pa': 'ਸੇਵਾ ਦੀਆਂ ਸ਼ਰਤਾਂ',
      },
      // Messages
      'no_internet': {
        'en': 'No Internet Connection',
        'hi': 'इंटरनेट कनेक्शन नहीं है',
        'bn': 'ইন্টারনেট সংযোগ নেই',
        'te': 'ఇంటర్నెట్ కనెక్షన్ లేదు',
        'mr': 'इंटरनेट कनेक्शन नाही',
        'ta': 'இணைய இணைப்பு இல்லை',
        'gu': 'ઇન્ટરનેટ કનેક્શન નથી',
        'kn': 'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವಿಲ್ಲ',
        'ml': 'ഇന്റർനെറ്റ് കണക്ഷൻ ഇല്ല',
        'pa': 'ਇੰਟਰਨੈੱਟ ਕਨੈਕਸ਼ਨ ਨਹੀਂ',
      },
      'loading': {
        'en': 'Loading...',
        'hi': 'लोड हो रहा है...',
        'bn': 'লোড হচ্ছে...',
        'te': 'లోడ్ అవుతోంది...',
        'mr': 'लोड होत आहे...',
        'ta': 'ஏற்றுகிறது...',
        'gu': 'લોડ થઈ રહ્યું છે...',
        'kn': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
        'ml': 'ലോഡ് ചെയ്യുന്നു...',
        'pa': 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...',
      },
      'error': {
        'en': 'Error',
        'hi': 'त्रुटि',
        'bn': 'ত্রুটি',
        'te': 'లోపం',
        'mr': 'त्रुटी',
        'ta': 'பிழை',
        'gu': 'ભૂલ',
        'kn': 'ದೋಷ',
        'ml': 'പിശക്',
        'pa': 'ਗਲਤੀ',
      },
      'success': {
        'en': 'Success',
        'hi': 'सफलता',
        'bn': 'সফলতা',
        'te': 'విజయం',
        'mr': 'यश',
        'ta': 'வெற்றி',
        'gu': 'સફળતા',
        'kn': 'ಯಶಸ್ಸು',
        'ml': 'വിജയം',
        'pa': 'ਸਫਲਤਾ',
      },
      'saved': {
        'en': 'Saved',
        'hi': 'सहेजा गया',
        'bn': 'সংরক্ষিত',
        'te': 'సేవ్ చేయబడింది',
        'mr': 'जतन केले',
        'ta': 'சேமிக்கப்பட்டது',
        'gu': 'સાચવ્યું',
        'kn': 'ಉಳಿಸಲಾಗಿದೆ',
        'ml': 'സേവ് ചെയ്തു',
        'pa': 'ਸੇਵ ਕੀਤਾ',
      },
      'downloads': {
        'en': 'Downloads',
        'hi': 'डाउनलोड',
        'bn': 'ডাউনলোড',
        'te': 'డౌన్‌లోడ్‌లు',
        'mr': 'डाउनलोड्स',
        'ta': 'பதிவிறக்கங்கள்',
        'gu': 'ડાઉનલોડ્સ',
        'kn': 'ಡೌನ್‌ಲೋಡ್‌ಗಳು',
        'ml': 'ഡൗൺലോഡുകൾ',
        'pa': 'ਡਾਊਨਲੋਡ',
      },
    };
  }

  /// Get a translated string
  String translate(String key) {
    final langTranslations = translations[key];
    if (langTranslations == null) return key;
    return langTranslations[_currentLanguageCode] ?? langTranslations['en'] ?? key;
  }
  
  /// Shorthand method for translation
  String tr(String key) => translate(key);
}

