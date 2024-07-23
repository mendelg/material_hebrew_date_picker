import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:material_hebrew_date_picker/material_hebrew_date_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Date Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Hebrew Date Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;

  void _showSingleDatePicker() async {
    await showMaterialHebrewDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: JewishDate.initDate(
              jewishYear: 5783, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      lastDate: JewishDate.initDate(
              jewishYear: 5785, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      hebrewFormat: false,
      onDateChange: (date) {
        print('Date changed: $date');
      },
      onConfirmDate: (date) {
        print('Date confirmed: $date');
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showMaterialHebrewDateRangePicker(
      context: context,
      firstDate: JewishDate.initDate(
              jewishYear: 5783, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      lastDate: JewishDate.initDate(
              jewishYear: 5785, jewishMonth: 1, jewishDayOfMonth: 1)
          .getGregorianCalendar(),
      hebrewFormat: false,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showSingleDatePicker,
              child: const Text('Show Single Date Picker'),
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
              child: const Text('Show Date Range Picker'),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedDateRange == null
                  ? 'No date range selected'
                  : 'Selected range: ${_formatHebrewDate(_selectedDateRange!.start)} to ${_formatHebrewDate(_selectedDateRange!.end)}',
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
