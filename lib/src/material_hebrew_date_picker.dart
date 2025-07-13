import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'theme.dart';
// Base class for shared functionality
abstract class HebrewDatePickerBase extends StatefulWidget {
  final DateTime firstDate;
  final DateTime initialDate;
  final DateTime lastDate;
  final bool hebrewFormat;
  final HebrewDatePickerTheme? theme;

  const HebrewDatePickerBase({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.hebrewFormat = true,
    this.theme,
  });

  @override
  HebrewDatePickerBaseState createState();
}

abstract class HebrewDatePickerBaseState<T extends HebrewDatePickerBase>
    extends State<T> {
  late JewishDate _displayedMonth;
  late HebrewDateFormatter _formatter;
  late PageController _pageController;
  late int _currentPage;
  late int _totalMonths;

  @override
  void initState() {
    super.initState();
    _displayedMonth = JewishDate.fromDateTime(widget.initialDate);
    _formatter = HebrewDateFormatter()..hebrewFormat = widget.hebrewFormat;
    _totalMonths = _monthsBetween(
      JewishDate.fromDateTime(widget.firstDate),
      JewishDate.fromDateTime(widget.lastDate),
    );
    _currentPage = _monthsBetween(
      JewishDate.fromDateTime(widget.firstDate),
      JewishDate.fromDateTime(widget.initialDate),
    );
    _pageController = PageController(initialPage: _currentPage);
  }

  int _monthsBetween(JewishDate start, JewishDate end) {
    int months = 0;
    JewishDate current = JewishDate()
      ..setJewishDate(start.getJewishYear(), start.getJewishMonth(), 1);

    while (current.compareTo(end) <= 0) {
      months++;
      current.forward(Calendar.MONTH, 1);
    }

    return months - 1;
  }

  JewishDate _getMonthFromPageIndex(int index) {
    JewishDate date = JewishDate.fromDateTime(widget.firstDate);
    if (index > 0) {
      date.forward(Calendar.MONTH, index);
    } else {
      //  Go back to the first day of the month, there is no backward method
      for (int i = 0; i > index; i--) {
        date.back();
      }
    }
    return date;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _displayedMonth = _getMonthFromPageIndex(_currentPage);
    });
  }

  void _showPreviousMonth() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showNextMonth() {
    if (_currentPage < _totalMonths - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getHebrewMonthName(int month) {
    List<String> months = widget.hebrewFormat
        ? [
            'ניסן',
            'אייר',
            'סיון',
            'תמוז',
            'אב',
            'אלול',
            'תשרי',
            'חשון',
            'כסלו',
            'טבת',
            'שבט',
            'אדר',
          ]
        : [
            'Nisan',
            'Iyyar',
            'Sivan',
            'Tammuz',
            'Av',
            'Elul',
            'Tishrei',
            'Heshvan',
            'Kislev',
            'Tevet',
            'Shevat',
            'Adar',
          ];

    if (_displayedMonth.isJewishLeapYear()) {
      if (month == JewishDate.ADAR) {
        return widget.hebrewFormat ? 'אדר א' : 'Adar I';
      } else if (month == JewishDate.ADAR_II) {
        return widget.hebrewFormat ? 'אדר ב' : 'Adar II';
      }
    }

    // Adjust the month index for leap years
    int adjustedMonth = month;
    // Jewish leap years have Adar I and Adar II
    // JewishDate.ADAR == 12, JewishDate.ADAR_II == 13
    if (_displayedMonth.isJewishLeapYear() && month > JewishDate.ADAR) {
      adjustedMonth--;
    }

    // Ensure the index is within bounds
    int index = (adjustedMonth - 1) % 12;
    return months[index];
  }

  Widget _buildMonthSelector(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_getHebrewMonthName(_displayedMonth.getJewishMonth())} ${widget.hebrewFormat ? _formatter.formatHebrewNumber(_displayedMonth.getJewishYear()) : _displayedMonth.getJewishYear()}',
            style: theme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left),
                onPressed: _showPreviousMonth,
                color: theme.primaryColor,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right),
                onPressed: _showNextMonth,
                color: theme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(HebrewDatePickerTheme theme) {
    final weekdays = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays
            .map(
              (day) => Text(
                day,
                style: theme.weekdayTextStyle.copyWith(
                  color: theme.onSurfaceColor.withOpacity(0.6),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendar(
    HebrewDatePickerTheme theme,
    Widget Function(BuildContext, int) monthViewBuilder,
  ) {
    return Container(
      color: theme.surfaceColor,
      child: Column(
        children: [
          _buildMonthSelector(theme),
          _buildWeekdayHeader(theme),
          AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: monthViewBuilder,
              itemCount: _totalMonths,
            ),
          ),
        ],
      ),
    );
  }

  HebrewDatePickerTheme _getMergedTheme() {
    const defaultTheme = HebrewDatePickerTheme();
    return HebrewDatePickerTheme(
      primaryColor: widget.theme?.primaryColor ?? defaultTheme.primaryColor,
      onPrimaryColor:
          widget.theme?.onPrimaryColor ?? defaultTheme.onPrimaryColor,
      surfaceColor: widget.theme?.surfaceColor ?? defaultTheme.surfaceColor,
      onSurfaceColor:
          widget.theme?.onSurfaceColor ?? defaultTheme.onSurfaceColor,
      disabledColor: widget.theme?.disabledColor ?? defaultTheme.disabledColor,
      selectedColor: widget.theme?.selectedColor ?? defaultTheme.selectedColor,
      todayColor: widget.theme?.todayColor ?? defaultTheme.todayColor,
      headerTextStyle:
          widget.theme?.headerTextStyle ?? defaultTheme.headerTextStyle,
      bodyTextStyle: widget.theme?.bodyTextStyle ?? defaultTheme.bodyTextStyle,
      weekdayTextStyle:
          widget.theme?.weekdayTextStyle ?? defaultTheme.weekdayTextStyle,
    );
  }
}

class MaterialHebrewDatePicker extends HebrewDatePickerBase {
  final ValueChanged<DateTime> onDateChange;
  final ValueChanged<DateTime> onConfirmDate;

  const MaterialHebrewDatePicker({
    Key? key,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required this.onDateChange,
    required this.onConfirmDate,
    bool hebrewFormat = true,
    HebrewDatePickerTheme? theme,
  }) : super(
         initialDate: initialDate,
         key: key,
         firstDate: firstDate,
         lastDate: lastDate,
         hebrewFormat: hebrewFormat,
         theme: theme,
       );

  @override
  _MaterialHebrewDatePickerState createState() =>
      _MaterialHebrewDatePickerState();
}

class _MaterialHebrewDatePickerState
    extends HebrewDatePickerBaseState<MaterialHebrewDatePicker> {
  late JewishDate _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = JewishDate.fromDateTime(widget.initialDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getMergedTheme();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = isSmallScreen ? screenSize.width * 0.95 : 360.0;
        final maxHeight = isSmallScreen ? screenSize.height * 0.9 : 640.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(theme),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _buildCalendar(theme, _buildMonthView),
                      ),
                    ),
                    _buildActions(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(HebrewDatePickerTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Text(
            widget.hebrewFormat ? 'בחר תאריך' : 'Select Date',
            style: theme.headerTextStyle.copyWith(color: theme.onPrimaryColor),
          ),
          const SizedBox(height: 10),
          Text(
            _formatFullDate(_selectedDate),
            style: theme.bodyTextStyle.copyWith(
              color: theme.onPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(BuildContext context, int pageIndex) {
    final theme = _getMergedTheme();
    final monthDate = _getMonthFromPageIndex(pageIndex);
    final daysInMonth = monthDate.getDaysInJewishMonth();
    final firstDayOfMonth = JewishDate()
      ..setJewishDate(monthDate.getJewishYear(), monthDate.getJewishMonth(), 1);
    final firstWeekday = firstDayOfMonth.getDayOfWeek();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 rows * 7 days
      itemBuilder: (context, index) {
        final int day = index - firstWeekday + 2;
        if (day < 1 || day > daysInMonth) return Container();

        final currentDate = JewishDate()
          ..setJewishDate(
            monthDate.getJewishYear(),
            monthDate.getJewishMonth(),
            day,
          );
        final isSelected = currentDate.compareTo(_selectedDate) == 0;
        final isDisabled =
            currentDate.compareTo(JewishDate.fromDateTime(widget.firstDate)) <
                0 ||
            currentDate.compareTo(JewishDate.fromDateTime(widget.lastDate)) > 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth / 7;
            return InkWell(
              onTap: isDisabled ? null : () => _selectDate(currentDate),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.selectedColor : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.hebrewFormat
                          ? _formatter.formatHebrewNumber(day)
                          : day.toString(),
                      style: theme.bodyTextStyle.copyWith(
                        color: isSelected
                            ? theme.onPrimaryColor
                            : isDisabled
                            ? theme.disabledColor
                            : theme.onSurfaceColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: size * 2.2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActions(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.hebrewFormat ? 'ביטול' : 'Cancel'),
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _confirmDate,
            child: Text(widget.hebrewFormat ? 'אישור' : 'Confirm'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.onPrimaryColor,
              backgroundColor: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(JewishDate currentDate) {
    setState(() {
      _selectedDate = currentDate;
    });
    widget.onDateChange(currentDate.getGregorianCalendar());
  }

  void _confirmDate() {
    widget.onConfirmDate(_selectedDate.getGregorianCalendar());
    Navigator.of(context).pop();
  }

  String _formatFullDate(JewishDate date) {
    final dayOfWeek = _getHebrewDayOfWeek(date.getDayOfWeek());
    final day = widget.hebrewFormat
        ? _formatter.formatHebrewNumber(date.getJewishDayOfMonth())
        : date.getJewishDayOfMonth().toString();
    final month = _getHebrewMonthName(date.getJewishMonth());
    final year = widget.hebrewFormat
        ? _formatter.formatHebrewNumber(date.getJewishYear())
        : date.getJewishYear().toString();
    return '$dayOfWeek, $day $month $year';
  }

  String _getHebrewDayOfWeek(int day) {
    final days = widget.hebrewFormat
        ? ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת']
        : [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
          ];
    return days[day - 1];
  }
}

class HebrewDateRangePicker extends HebrewDatePickerBase {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  const HebrewDateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required this.onDateRangeChanged,
    bool hebrewFormat = true,
    HebrewDatePickerTheme? theme,
  }) : super(
         initialDate: initialStartDate ?? firstDate,
         key: key,
         firstDate: firstDate,
         lastDate: lastDate,
         hebrewFormat: hebrewFormat,
         theme: theme,
       );

  @override
  _HebrewDateRangePickerState createState() => _HebrewDateRangePickerState();
}

class _HebrewDateRangePickerState
    extends HebrewDatePickerBaseState<HebrewDateRangePicker> {
  late JewishDate _startDate;
  late JewishDate _endDate;
  bool _isSelectingEndDate = false;
  bool _hasSelection = false;

  @override
  void initState() {
    super.initState();
    _startDate = JewishDate.fromDateTime(widget.firstDate);
    _endDate = JewishDate.fromDateTime(widget.firstDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getMergedTheme();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = isSmallScreen ? screenSize.width * 0.95 : 360.0;
        final maxHeight = isSmallScreen ? screenSize.height * 0.9 : 640.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(theme),
                    Flexible(child: _buildCalendar(theme, _buildMonthView)),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor,
      child: Column(
        children: [
          Text(
            widget.hebrewFormat ? 'בחר טווח תאריכים' : 'Select Date Range',
            style: theme.headerTextStyle,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.hebrewFormat ? 'מתאריך' : 'Start Date'),
                  Text(_hasSelection ? _formatDate(_startDate) : '-'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.hebrewFormat ? 'עד תאריך' : 'End Date'),
                  Text(
                    _hasSelection && !_isSelectingEndDate
                        ? _formatDate(_endDate)
                        : '-',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(BuildContext context, int pageIndex) {
    final theme = _getMergedTheme();
    final monthDate = _getMonthFromPageIndex(pageIndex);
    final daysInMonth = monthDate.getDaysInJewishMonth();
    final firstDayOfMonth = JewishDate()
      ..setJewishDate(monthDate.getJewishYear(), monthDate.getJewishMonth(), 1);
    final firstWeekday = firstDayOfMonth.getDayOfWeek();
    final today = JewishDate.fromDateTime(DateTime.now());

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final int day = index - firstWeekday + 2;
        if (day < 1 || day > daysInMonth) return Container();

        final currentDate = JewishDate()
          ..setJewishDate(
            monthDate.getJewishYear(),
            monthDate.getJewishMonth(),
            day,
          );
        final isSelected = _isDateInRange(currentDate);
        final isDisabled = _isDateDisabled(currentDate);
        final isToday = currentDate.compareTo(today) == 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth / 7;
            return InkWell(
              onTap: isDisabled ? null : () => _selectDate(currentDate),
              child: Padding(
                padding: EdgeInsets.all(size * 0.05),
                child: Container(
                  margin: EdgeInsets.all(size * 0.01),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor
                        : isToday
                        ? theme.todayColor.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isToday
                        ? Border.all(color: theme.todayColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.hebrewFormat
                          ? _formatter.formatHebrewNumber(day)
                          : day.toString(),
                      style: theme.bodyTextStyle.copyWith(
                        color: isSelected
                            ? theme.onPrimaryColor
                            : isDisabled
                            ? theme.onSurfaceColor.withOpacity(0.38)
                            : isToday
                            ? theme.todayColor
                            : theme.onSurfaceColor,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: size * 2.2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.hebrewFormat ? 'ביטול' : 'Cancel'),
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _hasSelection ? _confirmDateRange : null,
            child: Text(widget.hebrewFormat ? 'אישור' : 'Confirm'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.onPrimaryColor,
              backgroundColor: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(JewishDate date) {
    setState(() {
      if (!_hasSelection) {
        _startDate = date;
        _endDate = date;
        _hasSelection = true;
        _isSelectingEndDate = true;
      } else if (_isSelectingEndDate) {
        if (date.compareTo(_startDate) < 0) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _isSelectingEndDate = false;
      } else {
        _startDate = date;
        _endDate = date;
        _isSelectingEndDate = true;
      }
    });
  }

  bool _isDateInRange(JewishDate date) {
    if (!_hasSelection) return false;
    if (!_isSelectingEndDate && _startDate.compareTo(_endDate) == 0) {
      return date.compareTo(_startDate) == 0;
    }
    return (date.compareTo(_startDate) >= 0 && date.compareTo(_endDate) <= 0);
  }

  bool _isDateDisabled(JewishDate date) {
    return date.compareTo(JewishDate.fromDateTime(widget.firstDate)) < 0 ||
        date.compareTo(JewishDate.fromDateTime(widget.lastDate)) > 0;
  }

  void _confirmDateRange() {
    final selectedRange = DateTimeRange(
      start: _startDate.getGregorianCalendar(),
      end: _endDate.getGregorianCalendar(),
    );
    Navigator.of(context).pop(selectedRange);
  }

  String _formatDate(JewishDate date) {
    final day = _formatter.formatHebrewNumber(date.getJewishDayOfMonth());
    final month = _getHebrewMonthName(date.getJewishMonth());
    final year = widget.hebrewFormat
        ? _formatter.formatHebrewNumber(date.getJewishYear())
        : date.getJewishYear().toString();
    return '$day $month $year';
  }
}

// Helper functions
Future<void> showMaterialHebrewDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  bool hebrewFormat = true,
  required ValueChanged<DateTime> onDateChange,
  required ValueChanged<DateTime> onConfirmDate,
  HebrewDatePickerTheme? theme,
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return MaterialHebrewDatePicker(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        onDateChange: onDateChange,
        onConfirmDate: onConfirmDate,
        hebrewFormat: hebrewFormat,
        theme: theme,
      );
    },
  );
}

Future<DateTimeRange?> showMaterialHebrewDateRangePicker({
  required BuildContext context,
  DateTime? initialStartDate,
  DateTime? initialEndDate,
  required DateTime firstDate,
  required DateTime lastDate,
  bool hebrewFormat = true,
  HebrewDatePickerTheme? theme,
}) async {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (BuildContext context) {
      return HebrewDateRangePicker(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        firstDate: firstDate,
        lastDate: lastDate,
        hebrewFormat: hebrewFormat,
        onDateRangeChanged: (DateTimeRange? range) {
          Navigator.of(context).pop(range);
        },
        theme: theme,
      );
    },
  );
}
