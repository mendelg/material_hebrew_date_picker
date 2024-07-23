# Material Hebrew Date Picker

A customizable Material Design Hebrew date picker for Flutter applications, supporting both single date and date range selection. This package provides a culturally appropriate date selection experience for apps targeting Hebrew/English-speaking users.

## Features

- Hebrew calendar support with accurate date calculations
- Single date and date range selection modes
- Customizable themes
- Support for both Hebrew and Gregorian date display
- Responsive design for various screen sizes
- Right-to-left (RTL) support for Hebrew text
- Today highlighting
- Year selection mode
- Customizable color scheme and typography

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  material_hebrew_date_picker: 1.0.0+7
```

Then run:

```
$ flutter pub get
```

## Usage

Import the package in your Dart code:

```dart
import 'package:material_hebrew_date_picker/material_hebrew_date_picker.dart';
```

### Single Date Picker

<img width="359" alt="image" src="https://github.com/user-attachments/assets/301d0fca-823c-45d4-a08c-09e4bb878264">



```dart
void _showSingleDatePicker() async {
  await showMaterialHebrewDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    hebrewFormat: true,
    onDateChange: (date) {
      print('Date changed: $date');
    },
    onConfirmDate: (date) {
      print('Date confirmed: $date');
      // Handle the confirmed date
    },
  );
}
```

### Date Range Picker

<img width="337" alt="image" src="https://github.com/user-attachments/assets/5a5cdc20-6ff1-4ffa-9012-f49708898eba">


```dart
void _showDateRangePicker() async {
  final DateTimeRange? result = await showMaterialHebrewDateRangePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 365)),
    hebrewFormat: true,
  );

  if (result != null) {
    print('Selected range: ${result.start} to ${result.end}');
    // Handle the selected date range
  }
}
```




### Using with kosher_dart

While not required, you may want to use the [`kosher_dart`](https://pub.dev/packages/kosher_dart) package for advanced Hebrew date functionality. Here's an example:

```dart
import 'package:kosher_dart/kosher_dart.dart';

void _showSingleDatePicker() {
  showMaterialHebrewDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: JewishDate().getGregorianCalendar(),
    lastDate: JewishDate().getGregorianCalendar().add(const Duration(days: 30)),
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
```

To use `kosher_dart`, add it to your `pubspec.yaml`:

```yaml
dependencies:
  kosher_dart: ^2.0.16  # Use the latest version
```




## Customization

You can customize the appearance of the date picker using the `HebrewDatePickerTheme` class:

```dart
HebrewDatePickerTheme customTheme = HebrewDatePickerTheme(
  primaryColor: Colors.blue,
  onPrimaryColor: Colors.white,
  surfaceColor: Colors.white,
  onSurfaceColor: Colors.black87,
  disabledColor: Colors.grey,
  selectedColor: Colors.blue,
  todayColor: Colors.orange,
  headerTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  bodyTextStyle: TextStyle(fontSize: 14),
  weekdayTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
);

showMaterialHebrewDatePicker(
  // ... other parameters
  theme: customTheme,
);
```

## Localization

The package supports both Hebrew and English languages. The language is determined by the `hebrewFormat` parameter:

- When `hebrewFormat` is `true`, the picker displays in Hebrew:

  - <img width="353" alt="image" src="https://github.com/user-attachments/assets/5ac15ccb-5d36-433d-9055-dd06489043b6">

- When `hebrewFormat` is `false`, the picker displays in English:
  
  - <img width="314" alt="image" src="https://github.com/user-attachments/assets/c2bd356c-153b-4082-9b8b-7c2621c13630">



## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/mendelg/material_hebrew_date_picker/blob/main/LICENSE) file for details.

## Support

If you have any questions or run into any problems, please open an issue in the GitHub repository.
