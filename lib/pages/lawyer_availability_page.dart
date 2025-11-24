import 'package:flutter/material.dart';

class LawyerAvailabilityPage extends StatefulWidget {
  const LawyerAvailabilityPage({Key? key}) : super(key: key);

  @override
  State<LawyerAvailabilityPage> createState() => _LawyerAvailabilityPageState();
}

class _LawyerAvailabilityPageState extends State<LawyerAvailabilityPage> {
  final Color _primary = const Color(0xFF253D7A);
  final Color _bgLight = const Color(0xFFF6F7F8);
  final Color _bgDark = const Color(0xFF14141E);

  final List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final Set<int> _selectedDays = {1, 2, 3, 4}; // Mon-Thu selected by default

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? _bgDark : _bgLight,
      appBar: AppBar(
        backgroundColor: dark ? _bgDark.withOpacity(0.95) : _bgLight.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: dark ? Colors.white : _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Availability',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : _primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: dark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Weekly Schedule
            Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  // Day selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_days.length, (index) {
                      bool selected = _selectedDays.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selected
                                ? _selectedDays.remove(index)
                                : _selectedDays.add(index);
                          });
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? _primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: selected
                                  ? _primary
                                  : Colors.grey.shade400,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            _days[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selected ? _primary : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Time slots
                  _timeSlot(
                    label: 'Morning',
                    startTime: '09:00 AM',
                    endTime: '12:00 PM',
                    enabled: true,
                    dark: dark,
                  ),
                  const SizedBox(height: 12),
                  _timeSlot(
                    label: 'Afternoon',
                    startTime: '01:00 PM',
                    endTime: '05:00 PM',
                    enabled: true,
                    dark: dark,
                  ),
                  const SizedBox(height: 12),
                  _timeSlot(
                    label: 'Evening',
                    startTime: '06:00 PM',
                    endTime: '08:00 PM',
                    enabled: false,
                    dark: dark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upcoming Appointments
            Text(
              'Upcoming Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No Upcoming Appointments',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeSlot({
    required String label,
    required String startTime,
    required String endTime,
    required bool enabled,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled
            ? _primary.withOpacity(0.1)
            : Colors.grey.shade100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? _primary : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? _primary
                  : Colors.grey.shade600,
            ),
          ),
          Text(
            '$startTime - $endTime',
            style: TextStyle(
              fontSize: 14,
              color: enabled
                  ? Colors.black87
                  : Colors.grey.shade600,
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {
              setState(() {});
            },
            activeColor: _primary,
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard({
    required String clientName,
    required String date,
    required String time,
    required String type,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: dark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: type == 'Online'
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: type == 'Online' ? Colors.blue : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

