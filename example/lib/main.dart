import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:material_hebrew_date_picker/material_hebrew_date_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Date Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hebrew Date Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;

  void _showSingleDatePicker() async {
    // --- HOW TO USE NEW NAVIGATION FEATURES ---
    // 1. Tap the year in the header to open the year picker.
    // 2. Tap the month in the header to open the month picker.
    // 3. Use the "Today" button to jump to the current date.
    final DateTime? picked = await showMaterialHebrewDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: JewishDate.initDate(
              jewishYear: 5783, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      lastDate: JewishDate.initDate(
              jewishYear: 5786, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      hebrewFormat: false,
      selectableDayPredicate: (DateTime val) =>
          val.weekday != DateTime.friday && val.weekday != DateTime.saturday,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showDateRangePicker() async {
    // The same navigation features (year/month picker, "Today" button)
    // are also available in the date range picker.
    final DateTimeRange? picked = await showMaterialHebrewDateRangePicker(
      context: context,
      firstDate: JewishDate.initDate(
              jewishYear: 5783, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      lastDate: JewishDate.initDate(
              jewishYear: 5786, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),


      selectableDayPredicate: (DateTime val) {
        // disable friday and saturday (Shabbat)
        return val.weekday != DateTime.friday && val.weekday != DateTime.saturday;
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text("Embedded Single Date Picker:"),
            SizedBox(
              height: 300,
              width: 328,
              child: MaterialHebrewDatePicker(
                calendarDirection: HebrewCalendarDirection.rtl,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: JewishDate.initDate(
                        jewishYear: 5783, jewishMonth: 1, jewishDayOfMonth: 1)
                    .getGregorianCalendar(),
                lastDate: JewishDate.initDate(
                        jewishYear: 5786, jewishMonth: 1, jewishDayOfMonth: 1)
                    .getGregorianCalendar(),
                onDateChange: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showSingleDatePicker,
              child: const Text('Show Single Date Picker In Dialog'),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedDate == null
                  ? 'No date selected'
                  : 'Selected date: ${_formatHebrewDate(_selectedDate!)}',
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _showDateRangePicker,
              child: const Text('Show Date Range Picker In Dialog'),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedDateRange == null
                  ? 'No date range selected'
                  : 'Selected range: ${_formatHebrewDate(_selectedDateRange!.start)} to ${_formatHebrewDate(_selectedDateRange!.end)}',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showMaterialHebrewDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: JewishDate.initDate(
                          jewishYear: 5783,
                          jewishMonth: 1,
                          jewishDayOfMonth: 1)
                      .getGregorianCalendar(),
                  lastDate: JewishDate.initDate(
                          jewishYear: 5786,
                          jewishMonth: 1,
                          jewishDayOfMonth: 1)
                      .getGregorianCalendar(),
                  initialPickerMode: HebrewDatePickerMode.year,
                  calendarDirection: HebrewCalendarDirection.rtl,
                );
              },
              child: const Text('Show Picker Starting in Year View'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHebrewDate(DateTime dateTime) {
    final hebrewForamtter = HebrewDateFormatter()..hebrewFormat = true;
    final JewishDate jewishDate = JewishDate.fromDateTime(dateTime);
    return hebrewForamtter.format(jewishDate);
  }
}
