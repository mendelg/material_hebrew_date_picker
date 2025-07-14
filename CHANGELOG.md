## 1.2.0

- **FEAT**: Added year and month picker views for enhanced navigation.
- **FEAT**: Added a "Go to Today" button for quick access to the current date.
- **FEAT**: Added `initialPickerMode` to allow opening the picker in year or month view.

## 1.1.0

- **FEAT**: Added `selectableDayPredicate` to disable specific days of the week.
- **FEAT**: `showMaterialHebrewDatePicker` now returns a `Future<DateTime?>` to allow for `await`.
- **FEAT**: Added assertions to prevent invalid date ranges (`firstDate` after `lastDate`, etc.).
- **REFACTOR**: Removed the `onConfirmDate` callback in favor of the `Future` return value.
- **REFACTOR**: Removed the redundant `onDateRangeChanged` callback from the date range picker.

## 1.0.0+8

- Initial release.
