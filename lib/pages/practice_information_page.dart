import 'package:flutter/material.dart';
import '../utils/registration_manager.dart';



class PracticeInformationPage extends StatefulWidget {

  const PracticeInformationPage({Key? key}) : super(key: key);

  @override

  State<PracticeInformationPage> createState() => _PracticeInformationPageState();

}

class _PracticeInformationPageState extends State<PracticeInformationPage> {

  final TextEditingController _locationCtrl = TextEditingController();

  final TextEditingController _feeCtrl = TextEditingController();

  // Weekday selection

  final List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  final Set<int> _selectedDays = {1, 2, 3}; // Defaults selected (M, T, W)

  // Toggles

  bool _onlineConsult = true;

  bool _inPersonConsult = false;

  // Colors

  final Color _primary = const Color(0xFF253D79);

  final Color _amber = const Color(0xFFF6B21D);

  final Color _royalBlue = const Color(0xFF4169E1);

  @override

  void dispose() {

    _locationCtrl.dispose();

    _feeCtrl.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F7F8),

      body: SafeArea(

        child: Column(

          children: [

            // Top App Bar

            Container(

              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),

              decoration: BoxDecoration(

                color: const Color(0xFFF6F7F8).withOpacity(0.8),

                border: Border(

                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),

                ),

              ),

              child: Row(

                children: [

                  IconButton(

                    icon: Icon(Icons.arrow_back, color: _primary),

                    onPressed: () => Navigator.pop(context),

                  ),

                  Expanded(

                    child: Text(

                      "Practice Information",

                      textAlign: TextAlign.center,

                      style: TextStyle(

                        fontSize: 18,

                        color: _primary,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                  const SizedBox(width: 48),

                ],

              ),

            ),

            // Main content

            Expanded(

              child: SingleChildScrollView(

                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Step Info + Progress Bar

                    Text(

                      "Step 2 of 4: Practice Details",

                      style: TextStyle(

                        fontSize: 14,

                        color: _primary,

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                    const SizedBox(height: 6),

                    Container(

                      height: 6,

                      decoration: BoxDecoration(

                        color: _primary.withOpacity(0.25),

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: FractionallySizedBox(

                        alignment: Alignment.centerLeft,

                        widthFactor: 0.50,

                        child: Container(

                          decoration: BoxDecoration(

                            color: _primary,

                            borderRadius: BorderRadius.circular(12),

                          ),

                        ),

                      ),

                    ),

                    const SizedBox(height: 28),

                    // Office Location

                    Text(

                      "Office / Practice Location",

                      style: TextStyle(

                        fontSize: 16,

                        color: _primary,

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                    const SizedBox(height: 8),

                    TextField(

                      controller: _locationCtrl,

                      decoration: InputDecoration(

                        hintText: "Enter your office address",

                        suffixIcon: Icon(Icons.location_on, color: _primary),

                        filled: true,

                        fillColor: Colors.white,

                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(12),

                        ),

                      ),

                    ),

                    const SizedBox(height: 24),

                    // Available Hours Card

                    Container(

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(color: Colors.grey.shade300),

                        boxShadow: [

                          BoxShadow(

                            blurRadius: 8,

                            color: Colors.black12,

                          ),

                        ],

                      ),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(

                            "Available Hours",

                            style: TextStyle(

                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: _primary,

                            ),

                          ),

                          const SizedBox(height: 4),

                          Text(

                            "Select the days and times you are available for consultation.",

                            style: TextStyle(

                              fontSize: 13,

                              color: Colors.grey.shade600,

                            ),

                          ),

                          const SizedBox(height: 16),

                          // Weekday selector

                          Row(

                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: List.generate(_days.length, (i) {

                              bool selected = _selectedDays.contains(i);

                              return GestureDetector(

                                onTap: () {

                                  setState(() {

                                    selected

                                        ? _selectedDays.remove(i)

                                        : _selectedDays.add(i);

                                  });

                                },

                                child: Container(

                                  width: 42,

                                  height: 42,

                                  alignment: Alignment.center,

                                  decoration: BoxDecoration(

                                    color: selected

                                        ? _royalBlue.withOpacity(0.15)

                                        : Colors.white,

                                    borderRadius: BorderRadius.circular(50),

                                    border: Border.all(

                                      color: selected

                                          ? _royalBlue

                                          : Colors.grey.shade400,

                                      width: selected ? 2 : 1,

                                    ),

                                  ),

                                  child: Text(

                                    _days[i],

                                    style: TextStyle(

                                      fontWeight: FontWeight.bold,

                                      color: selected

                                          ? _royalBlue

                                          : _primary,

                                    ),

                                  ),

                                ),

                              );

                            }),

                          ),

                          const SizedBox(height: 20),

                          // Time Range Row

                          Row(

                            children: [

                              Expanded(

                                child: Column(

                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [

                                    Text("From",

                                        style: TextStyle(

                                            color: Colors.grey.shade600,

                                            fontSize: 12)),

                                    const SizedBox(height: 6),

                                    TimeBox(

                                      time: "09:00 AM",

                                      iconColor: _primary,

                                    ),

                                  ],

                                ),

                              ),

                              const SizedBox(width: 16),

                              Expanded(

                                child: Column(

                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [

                                    Text("To",

                                        style: TextStyle(

                                            color: Colors.grey.shade600,

                                            fontSize: 12)),

                                    const SizedBox(height: 6),

                                    TimeBox(

                                      time: "05:00 PM",

                                      iconColor: _primary,

                                    ),

                                  ],

                                ),

                              ),

                            ],

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 28),

                    // Consultation Fee

                    Text(

                      "Consultation Fee (per hour)",

                      style: TextStyle(

                        fontSize: 16,

                        color: _primary,

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                    const SizedBox(height: 8),

                    TextField(

                      controller: _feeCtrl,

                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(

                        prefixText: "₹ ",

                        prefixStyle:

                            TextStyle(color: _primary, fontSize: 16),

                        hintText: "Enter amount",

                        filled: true,

                        fillColor: Colors.white,

                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(12),

                        ),

                      ),

                    ),

                    const SizedBox(height: 28),

                    // Consultation Method Card

                    Container(

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        border: Border.all(color: Colors.grey.shade300),

                        borderRadius: BorderRadius.circular(14),

                        boxShadow: [

                          BoxShadow(

                            blurRadius: 8,

                            color: Colors.black12,

                          )

                        ],

                      ),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(

                            "Consultation Method",

                            style: TextStyle(

                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: _primary,

                            ),

                          ),

                          const SizedBox(height: 16),

                          // Online toggle

                          Row(

                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [

                              Text("Online Consultation",

                                  style: TextStyle(

                                      fontSize: 16, color: _primary)),

                              Switch(

                                value: _onlineConsult,

                                activeColor: _royalBlue,

                                onChanged: (v) {

                                  setState(() => _onlineConsult = v);

                                },

                              ),

                            ],

                          ),

                          // In-person toggle

                          Row(

                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [

                              Text("In-person Consultation",

                                  style: TextStyle(

                                      fontSize: 16, color: _primary)),

                              Switch(

                                value: _inPersonConsult,

                                activeColor: _royalBlue,

                                onChanged: (v) {

                                  setState(() => _inPersonConsult = v);

                                },

                              ),

                            ],

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 60),

                  ],

                ),

              ),

            ),

            // Bottom CTA

            Container(

              padding: const EdgeInsets.all(16),

              color: const Color(0xFFF6F7F8),

              child: SizedBox(

                width: double.infinity,

                height: 56,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: _amber,

                    foregroundColor: _primary,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                    elevation: 2,

                  ),

                  onPressed: () {

                    // Save to manager
                    final manager = RegistrationManager();
                    manager.location = _locationCtrl.text.trim();
                    manager.fee = _feeCtrl.text.trim();
                    manager.availableDays = _selectedDays.map((i) => _days[i]).toList();
                    manager.onlineConsult = _onlineConsult;
                    manager.inPersonConsult = _inPersonConsult;
                    
                    Navigator.pushNamed(context, "/profile_preview");

                  },

                  child: const Text(

                    "Continue",

                    style: TextStyle(

                        fontSize: 16, fontWeight: FontWeight.bold),

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}

/// — Small Reusable Widget for Time Selector UI —

class TimeBox extends StatelessWidget {

  final String time;

  final Color iconColor;

  const TimeBox({

    Key? key,

    required this.time,

    required this.iconColor,

  }) : super(key: key);

  @override

  Widget build(BuildContext context) {

    return Container(

      padding:

          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(

        color: Colors.white,

        border: Border.all(color: Colors.grey.shade400),

        borderRadius: BorderRadius.circular(12),

      ),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(

            time,

            style: TextStyle(

                fontSize: 15,

                color: iconColor,

                fontWeight: FontWeight.w600),

          ),

          Icon(Icons.schedule, color: iconColor.withOpacity(0.7)),

        ],

      ),

    );

  }

}

