import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/main.dart';
import 'package:intl/intl.dart';

class AppointmentBottomSheet extends StatefulWidget {
  final Function(int selectedMillis,DateTime selectedDate,TimeOfDay? selectedTime) onDateTimeSelected;

  AppointmentBottomSheet({required this.onDateTimeSelected});

  @override
  State<AppointmentBottomSheet> createState() => _AppointmentBottomSheetState();
}

class _AppointmentBottomSheetState extends State<AppointmentBottomSheet> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;

  List<DateTime> get next30Days {
    return List.generate(30, (i) => DateTime.now().add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day, 16, 30);
    if (now.isAfter(cutoff)) {
      selectedDate = DateTime.now().add(Duration(days: 1));
    }
  }

  List<TimeOfDay> get timeSlots {
    final start = TimeOfDay(hour: 8, minute: 0);
    final end = TimeOfDay(hour: 17, minute: 0);
    List<TimeOfDay> slots = [];
    TimeOfDay current = start;

    while (current.hour < end.hour || (current.hour == end.hour && current.minute < end.minute)) {
      slots.add(current);
      final nextMinute = current.minute + 30;
      final nextHour = current.hour + (nextMinute ~/ 60);
      current = TimeOfDay(hour: nextHour, minute: nextMinute % 60);
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: next30Days.length,
              itemBuilder: (_, index) {
                final day = next30Days[index];
                final isSelected = selectedDate.day == day.day &&
                    selectedDate.month == day.month &&
                    selectedDate.year == day.year;

                final now = DateTime.now();
                final isToday = day.day == now.day &&
                    day.month == now.month &&
                    day.year == now.year;

                final afterCutoff = now.hour >= 16 && now.minute >= 30;
                final isDisabled = isToday && afterCutoff;

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => setState(() {
                    selectedDate = day;

                    // Check if selected time is still valid for new date
                    final now = DateTime.now();

                    final selectedDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime?.hour ?? 0,
                      selectedTime?.minute ?? 0,
                    );

                    final isToday = selectedDate.year == now.year &&
                        selectedDate.month == now.month &&
                        selectedDate.day == now.day;

                    final isTimeValid = selectedTime != null &&
                        (!isToday || selectedDateTime.isAfter(now.add(Duration(minutes: 30))));

                    if (!isTimeValid) {
                      selectedTime = null; // Clear selection
                    }
                  }),
                  child: Opacity(
                    opacity: isDisabled ? 0.4 : 1.0,
                    child: Container(
                      width: 70,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected ? Colors.teal : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? Colors.teal.shade50 : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('E').format(day), style: TextStyle(fontSize: 12)),
                          Text(
                            "${day.day} ${DateFormat('MMM').format(day)}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text("Select Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 12),
         /* Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeSlots.map((time) {
              final isSelected = selectedTime == time;
              return GestureDetector(
                onTap: () => setState(() => selectedTime = time),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? Colors.teal.shade50 : Colors.transparent,
                  ),
                  child: Text(
                    time.format(context),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              );
            }).toList(),
          ),*/
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeSlots.map((time) {
              final now = DateTime.now();
              final selectedDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                time.hour,
                time.minute,
              );

              // Add a 30-minute buffer
              final isDisabled = selectedDate.day == now.day &&
                  selectedDate.month == now.month &&
                  selectedDate.year == now.year &&
                  selectedDateTime.isBefore(now.add(Duration(minutes: 30)));

              final isSelected = selectedTime == time;

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () => setState(() => selectedTime = time),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Colors.teal
                          : isDisabled
                          ? Colors.grey.shade300
                          : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? Colors.teal.shade50
                        : isDisabled
                        ? Colors.grey.shade100
                        : Colors.transparent,
                  ),
                  child: Text(
                    time.format(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDisabled ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: selectedTime == null
                ? null
                : () {
              final combined = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              final millis = combined.millisecondsSinceEpoch;
              widget.onDateTimeSelected(millis,selectedDate,selectedTime);
              Navigator.pop(context);
            },
            child: Text(language.proceedToCheckout,style: GoogleFonts.mulish(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),),
          ),
        ],
      ),
    );
  }
}
