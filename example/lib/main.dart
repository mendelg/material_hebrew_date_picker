import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:material_hebrew_date_picker/material_hebrew_date_picker.dart';
import 'package:material_hebrew_date_picker/src/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Date Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
  DateTime? _dialogSelectedDate;
  DateTimeRange? _dialogSelectedDateRange;
  DateTime? _embeddedSelectedDate;

  /// Shows a single date picker dialog.
  void _showSingleDatePicker() async {
    final DateTime? picked = await showMaterialHebrewDatePicker(
      context: context,
      initialDate: _dialogSelectedDate ?? DateTime.now(),
      firstDate: (JewishDate()
            ..setJewishDate(5780, JewishDate.TISHREI, 1))
          .getGregorianCalendar(),
      lastDate: (JewishDate()..setJewishDate(5790, JewishDate.ELUL, 29))
          .getGregorianCalendar(),
      // selectableDayPredicate: (DateTime val) {

      // Disable weekends
      //   return val.weekday != DateTime.sunday && val.weekday != DateTime.saturday;
      //   // return true;
      // },
    );
    if (picked != null && picked != _dialogSelectedDate) {
      setState(() {
        _dialogSelectedDate = picked;
      });
    }
  }

  /// Shows a date range picker dialog.
  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showMaterialHebrewDateRangePicker(
      context: context,
      firstDate: (JewishDate()
            ..setJewishDate(5780, JewishDate.TISHREI, 1))
          .getGregorianCalendar(),
      lastDate: (JewishDate()..setJewishDate(5790, JewishDate.ELUL, 29))
          .getGregorianCalendar(),
    );
    if (picked != null && picked != _dialogSelectedDateRange) {
      setState(() {
        _dialogSelectedDateRange = picked;
      });
    }
  }

  /// Shows a date picker dialog starting in year view.
  void _showYearPicker() async {
    await showMaterialHebrewDatePicker(
      context: context,
      initialDate: _dialogSelectedDate ?? DateTime.now(),
      firstDate: (JewishDate()
            ..setJewishDate(5780, JewishDate.TISHREI, 1))
          .getGregorianCalendar(),
      lastDate: (JewishDate()..setJewishDate(5790, JewishDate.ELUL, 29))
          .getGregorianCalendar(),
      initialPickerMode: HebrewDatePickerMode.year,
    );
  }

  /// Shows a date picker with a custom theme.
  void _showThemedPicker() async {
    final HebrewDatePickerTheme customTheme = HebrewDatePickerTheme(
      primaryColor: Colors.deepOrange,
      onPrimaryColor: Colors.white,
      surfaceColor: Colors.grey[200]!,
      onSurfaceColor: Colors.black,
      disabledColor: Colors.grey[400]!,
      selectedColor: Colors.deepOrange,
      todayColor: Colors.green,
      headerTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyTextStyle: const TextStyle(fontSize: 16),
      weekdayTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    await showMaterialHebrewDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      theme: customTheme,
    );
  }

  String _formatHebrewDate(DateTime dateTime) {
    final hebrewFormatter = HebrewDateFormatter()..hebrewFormat = true;
    final jewishDate = JewishDate.fromDateTime(dateTime);
    return hebrewFormatter.format(jewishDate);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_view_day), text: 'Dialogs'),
              Tab(icon: Icon(Icons.web_asset), text: 'Embedded'),
              Tab(icon: Icon(Icons.color_lens), text: 'Theming'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDialogsTab(),
            _buildEmbeddedTab(),
            _buildThemingTab(),
          ],
        ),
      ),
    );
  }

  /// Builds the content for the "Dialogs" tab.
  Widget _buildDialogsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showSingleDatePicker,
              child: const Text('Show Single Date Picker'),
            ),
            const SizedBox(height: 12),
            Text(
              _dialogSelectedDate == null
                  ? 'No date selected'
                  : 'Selected: ${_formatHebrewDate(_dialogSelectedDate!)}',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showDateRangePicker,
              child: const Text('Show Date Range Picker'),
            ),
            const SizedBox(height: 12),
            Text(
              _dialogSelectedDateRange == null
                  ? 'No date range selected'
                  : 'Selected: ${_formatHebrewDate(_dialogSelectedDateRange!.start)} - ${_formatHebrewDate(_dialogSelectedDateRange!.end)}',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showYearPicker,
              child: const Text('Show Picker in Year View'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the content for the "Embedded" tab.
  Widget _buildEmbeddedTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _embeddedSelectedDate == null
                ? 'No date selected'
                : 'Selected: ${_formatHebrewDate(_embeddedSelectedDate!)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.5,
          child: MaterialHebrewDatePicker(
            hebrewFormat: true,
            calendarDirection: HebrewCalendarDirection.rtl,
            initialDate: _embeddedSelectedDate ?? DateTime.now(),
            firstDate: (JewishDate()
                  ..setJewishDate(5780, JewishDate.TISHREI, 1))
                .getGregorianCalendar(),
            lastDate: (JewishDate()..setJewishDate(5790, JewishDate.ELUL, 29))
                .getGregorianCalendar(),
            onDateChange: (date) {
              setState(() {
                _embeddedSelectedDate = date;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Builds the content for the "Theming" tab.
  Widget _buildThemingTab() {
    return Center(
      child: ElevatedButton(
        onPressed: _showThemedPicker,
        child: const Text('Show Themed Picker'),
      ),
    );
  }
}
