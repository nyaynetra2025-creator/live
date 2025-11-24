class RegistrationManager {
  static final RegistrationManager _instance = RegistrationManager._internal();

  factory RegistrationManager() {
    return _instance;
  }

  RegistrationManager._internal();

  String name = '';
  String email = '';
  String gender = '';
  List<String> languages = [];
  
  String location = '';
  String fee = '';
  List<String> availableDays = [];
  String availableTimeStart = '09:00 AM';
  String availableTimeEnd = '05:00 PM';
  bool onlineConsult = true;
  bool inPersonConsult = false;

  void clear() {
    name = '';
    email = '';
    gender = '';
    languages = [];
    location = '';
    fee = '';
    availableDays = [];
    availableTimeStart = '09:00 AM';
    availableTimeEnd = '05:00 PM';
    onlineConsult = true;
    inPersonConsult = false;
  }
}
