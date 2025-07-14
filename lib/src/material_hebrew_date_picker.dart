import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'theme.dart';

/// The view mode of the date picker.
enum HebrewDatePickerMode {
  /// The user can select a day.
  day,

  /// The user can select a month.
  month,

  /// The user can select a year.
  year,
}

/// The direction of the calendar grid.
enum HebrewCalendarDirection {
  /// The calendar grid is laid out from left to right.
  ltr,

  /// The calendar grid is laid out from right to left.
  rtl,
}

// Base class for shared functionality
abstract class HebrewDatePickerBase extends StatefulWidget {
  final DateTime firstDate;
  final DateTime initialDate;
  final DateTime lastDate;
  final bool hebrewFormat;
  final HebrewDatePickerTheme? theme;
  final bool Function(DateTime)? selectableDayPredicate;
  final HebrewDatePickerMode initialPickerMode;
  final HebrewCalendarDirection? calendarDirection;

  /// An optional predicate that allows disabling specific days.
  ///
  /// If provided, this function will be called for each day in the calendar.
  /// If the function returns `false` for a given date, that day will be disabled
  /// and cannot be selected.
  ///
  /// The predicate receives a `DateTime` object representing the Gregorian date.
  ///
  /// Example:
  /// ```dart
  /// selectableDayPredicate: (DateTime val) => val.weekday != DateTime.saturday,
  /// ```
  HebrewDatePickerBase({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.hebrewFormat = true,
    this.theme,
    this.selectableDayPredicate,
    this.initialPickerMode = HebrewDatePickerMode.day,
    this.calendarDirection,
  })  : assert(!firstDate.isAfter(lastDate),
            'firstDate must be on or before lastDate'),
        assert(!initialDate.isBefore(firstDate),
            'initialDate must be on or after firstDate'),
        assert(!initialDate.isAfter(lastDate),
            'initialDate must be on or before lastDate');

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
  late HebrewDatePickerMode _pickerMode;

  @override
  void initState() {
    super.initState();
    _pickerMode = widget.initialPickerMode;
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

  void _showMonthPicker() {
    setState(() {
      _pickerMode = HebrewDatePickerMode.month;
    });
  }

  void _showYearPicker() {
    setState(() {
      _pickerMode = HebrewDatePickerMode.year;
    });
  }

  Widget _buildMonthSelector(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: _showMonthPicker,
                child: Text(
                  _getHebrewMonthName(_displayedMonth.getJewishMonth()),
                  style: theme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showYearPicker,
                child: Text(
                  widget.hebrewFormat
                      ? _formatter.formatHebrewNumber(
                          _displayedMonth.getJewishYear())
                      : _displayedMonth.getJewishYear().toString(),
                  style: theme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left),
                onPressed: _pickerMode == HebrewDatePickerMode.day
                    ? _showPreviousMonth
                    : null,
                color: theme.primaryColor,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    _pickerMode == HebrewDatePickerMode.day ? _showNextMonth : null,
                color: theme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(HebrewDatePickerTheme theme) {
    final textDirection = (widget.calendarDirection == HebrewCalendarDirection.rtl ||
            (widget.calendarDirection == null && widget.hebrewFormat))
        ? TextDirection.rtl
        : TextDirection.ltr;
    final weekdays = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];
    return Directionality(
      textDirection: textDirection,
      child: Padding(
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
            aspectRatio: 7 / 6,
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

  void _handleMonthSelection(int month) {
    setState(() {
      _displayedMonth.setJewishMonth(month);
      _pickerMode = HebrewDatePickerMode.day;
      _currentPage = _monthsBetween(
        JewishDate.fromDateTime(widget.firstDate),
        _displayedMonth,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    });
  }

  void _handleYearSelection(int year) {
    setState(() {
      final newDate = JewishDate()
        ..setJewishDate(
            year, _displayedMonth.getJewishMonth(), _displayedMonth.getJewishDayOfMonth());
      _displayedMonth = newDate;
      _pickerMode = HebrewDatePickerMode.day;
      _currentPage = _monthsBetween(
        JewishDate.fromDateTime(widget.firstDate),
        _displayedMonth,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    });
  }

  Widget _buildMonthPicker(HebrewDatePickerTheme theme) {
    final hebrewMonths = widget.hebrewFormat
        ? [
            'ניסן', 'אייר', 'סיון', 'תמוז', 'אב', 'אלול', 'תשרי', 'חשון', 'כסלו', 'טבת', 'שבט', 'אדר א׳', 'אדר ב׳'
          ]
        : [
            'Nisan', 'Iyar', 'Sivan', 'Tammuz', 'Av', 'Elul', 'Tishrei', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar I', 'Adar II'
          ];
    final isLeap = _displayedMonth.isJewishLeapYear();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: hebrewMonths.length,
      itemBuilder: (context, index) {
        final month = index + 1;
        // Adjust for Adar II
        final jewishMonth = (month >= 12 && isLeap) ? month + 1 : month;
        final isDisabled = month == 13 && !isLeap;
        final isSelectedMonth = jewishMonth == _displayedMonth.getJewishMonth();

        return InkWell(
          onTap: isDisabled ? null : () => _handleMonthSelection(jewishMonth),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedMonth ? theme.selectedColor : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                hebrewMonths[index],
                style: theme.bodyTextStyle.copyWith(
                  color: isDisabled
                      ? theme.disabledColor
                      : isSelectedMonth
                          ? theme.onPrimaryColor
                          : theme.onSurfaceColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearPicker(HebrewDatePickerTheme theme) {
    final firstYear = JewishDate.fromDateTime(widget.firstDate).getJewishYear();
    final lastYear = JewishDate.fromDateTime(widget.lastDate).getJewishYear();
    final yearCount = lastYear - firstYear + 1;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: yearCount,
      itemBuilder: (context, index) {
        final year = firstYear + index;
        final isSelectedYear = year == _displayedMonth.getJewishYear();
        return InkWell(
          onTap: () => _handleYearSelection(year),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedYear ? theme.selectedColor : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.hebrewFormat
                    ? _formatter.formatHebrewNumber(year)
                    : year.toString(),
                style: theme.bodyTextStyle.copyWith(
                  color: isSelectedYear
                      ? theme.onPrimaryColor
                      : theme.onSurfaceColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HebrewDatePickerTheme theme);
}

class MaterialHebrewDatePicker extends HebrewDatePickerBase {
  final ValueChanged<DateTime> onDateChange;

  MaterialHebrewDatePicker({
    super.key,
    required super.initialDate,
    required super.firstDate,
    required super.lastDate,
    required this.onDateChange,
    super.hebrewFormat,
    super.theme,
    super.selectableDayPredicate,
    super.initialPickerMode,
    super.calendarDirection,
  });

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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          _buildBody(context, theme),
        ],
      ),
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

  @override
  Widget _buildBody(BuildContext context, HebrewDatePickerTheme theme) {
    switch (_pickerMode) {
      case HebrewDatePickerMode.day:
        return _buildCalendar(
          theme,
          (context, pageIndex) => _buildMonthView(context, pageIndex, theme),
        );
      case HebrewDatePickerMode.month:
        return Column(
          children: [
            _buildMonthSelector(theme),
            AspectRatio(
              aspectRatio: 7 / 6,
              child: _buildMonthPicker(theme),
            ),
          ],
        );
      case HebrewDatePickerMode.year:
        return Column(
          children: [
            _buildMonthSelector(theme),
            AspectRatio(
              aspectRatio: 7 / 6,
              child: _buildYearPicker(theme),
            ),
          ],
        );
    }
  }

  Widget _buildMonthView(
      BuildContext context, int pageIndex, HebrewDatePickerTheme theme) {
    final textDirection = (widget.calendarDirection == HebrewCalendarDirection.rtl ||
            (widget.calendarDirection == null && widget.hebrewFormat))
        ? TextDirection.rtl
        : TextDirection.ltr;
    final monthDate = _getMonthFromPageIndex(pageIndex);
    final daysInMonth = monthDate.getDaysInJewishMonth();
    final firstDayOfMonth = JewishDate()
      ..setJewishDate(monthDate.getJewishYear(), monthDate.getJewishMonth(), 1);
    final firstWeekday = firstDayOfMonth.getDayOfWeek();

    return Directionality(
      textDirection: textDirection,
      child: GridView.builder(
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
          final gregorianDate = currentDate.getGregorianCalendar();
          final isDisabled =
              currentDate.compareTo(JewishDate.fromDateTime(widget.firstDate)) <
                      0 ||
                  currentDate
                          .compareTo(JewishDate.fromDateTime(widget.lastDate)) >
                      0 ||
                  (widget.selectableDayPredicate != null &&
                      !widget.selectableDayPredicate!(gregorianDate));

          return LayoutBuilder(
            builder: (context, constraints) {
              return InkWell(
                onTap: isDisabled ? null : () => _selectDate(currentDate),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    margin: const EdgeInsets.all(1),
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
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
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
    Navigator.of(context).pop(_selectedDate.getGregorianCalendar());
  }

  void _goToToday() {
    final today = JewishDate();
    final gregorianToday = today.getGregorianCalendar();

    // Check if "today" is within the allowed date range and is selectable.
    if (gregorianToday.isBefore(widget.firstDate) ||
        gregorianToday.isAfter(widget.lastDate) ||
        (widget.selectableDayPredicate != null &&
            !widget.selectableDayPredicate!(gregorianToday))) {
      // Optionally, show a message to the user that today is not available.
      return;
    }

    setState(() {
      _pickerMode = HebrewDatePickerMode.day;
      _displayedMonth = today;
      _selectedDate = today; // Select today's date
      _currentPage = _monthsBetween(
        JewishDate.fromDateTime(widget.firstDate),
        today,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    });
    widget.onDateChange(today.getGregorianCalendar());
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

  HebrewDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required super.firstDate,
    required super.lastDate,
    super.hebrewFormat,
    super.theme,
    super.selectableDayPredicate,
    super.initialPickerMode,
    super.calendarDirection,
  }) : super(
          initialDate: initialStartDate ?? firstDate,
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          _buildBody(context, theme),
        ],
      ),
    );
  }

  void _goToToday() {
    final today = JewishDate();
    final gregorianToday = today.getGregorianCalendar();

    // Check if "today" is within the allowed date range and is selectable.
    if (gregorianToday.isBefore(widget.firstDate) ||
        gregorianToday.isAfter(widget.lastDate) ||
        (widget.selectableDayPredicate != null &&
            !widget.selectableDayPredicate!(gregorianToday))) {
      // Optionally, show a message to the user that today is not available.
      return;
    }

    setState(() {
      _pickerMode = HebrewDatePickerMode.day;
      _displayedMonth = today;
      // Reset the selection and start a new range from today.
      _startDate = today;
      _endDate = today;
      _hasSelection = true;
      _isSelectingEndDate = true;
      _currentPage = _monthsBetween(
        JewishDate.fromDateTime(widget.firstDate),
        today,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    });
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

  @override
  Widget _buildBody(BuildContext context, HebrewDatePickerTheme theme) {
    switch (_pickerMode) {
      case HebrewDatePickerMode.day:
        return _buildCalendar(
          theme,
          (context, pageIndex) => _buildMonthView(context, pageIndex, theme),
        );
      case HebrewDatePickerMode.month:
        return Column(
          children: [
            _buildMonthSelector(theme),
            AspectRatio(
              aspectRatio: 7 / 6,
              child: _buildMonthPicker(theme),
            ),
          ],
        );
      case HebrewDatePickerMode.year:
        return Column(
          children: [
            _buildMonthSelector(theme),
            AspectRatio(
              aspectRatio: 7 / 6,
              child: _buildYearPicker(theme),
            ),
          ],
        );
    }
  }

  Widget _buildMonthView(
      BuildContext context, int pageIndex, HebrewDatePickerTheme theme) {
    final textDirection = (widget.calendarDirection == HebrewCalendarDirection.rtl ||
            (widget.calendarDirection == null && widget.hebrewFormat))
        ? TextDirection.rtl
        : TextDirection.ltr;
    final monthDate = _getMonthFromPageIndex(pageIndex);
    final daysInMonth = monthDate.getDaysInJewishMonth();
    final firstDayOfMonth = JewishDate()
      ..setJewishDate(monthDate.getJewishYear(), monthDate.getJewishMonth(), 1);
    final firstWeekday = firstDayOfMonth.getDayOfWeek();
    final today = JewishDate.fromDateTime(DateTime.now());

    return Directionality(
      textDirection: textDirection,
      child: GridView.builder(
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
              return InkWell(
                onTap: isDisabled ? null : () => _selectDate(currentDate),
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                  child: Container(
                    margin: EdgeInsets.all(constraints.maxWidth * 0.01),
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
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
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
    final gregorianDate = date.getGregorianCalendar();
    return date.compareTo(JewishDate.fromDateTime(widget.firstDate)) < 0 ||
        date.compareTo(JewishDate.fromDateTime(widget.lastDate)) > 0 ||
        (widget.selectableDayPredicate != null &&
            !widget.selectableDayPredicate!(gregorianDate));
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
/// Displays a Material Design Hebrew date picker dialog.
///
/// This function is a helper that wraps the [MaterialHebrewDatePicker] widget.
///
///  * `selectableDayPredicate`: An optional predicate to disable specific days.
Future<DateTime?> showMaterialHebrewDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  ValueChanged<DateTime>? onDateChange,
  bool hebrewFormat = true,
  HebrewDatePickerTheme? theme,
  bool Function(DateTime)? selectableDayPredicate,
  HebrewDatePickerMode initialPickerMode = HebrewDatePickerMode.day,
  HebrewCalendarDirection? calendarDirection,
}) async {
  final pickerKey = GlobalKey<_MaterialHebrewDatePickerState>();
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      final finalTheme = theme ?? const HebrewDatePickerTheme();
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: SizedBox(
          width: 328,
          height: 500,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: MaterialHebrewDatePicker(
                    key: pickerKey,
                    initialDate: initialDate ?? DateTime.now(),
                    firstDate: firstDate,
                    lastDate: lastDate,
                    onDateChange: onDateChange ?? (_) {},
                    hebrewFormat: hebrewFormat,
                    theme: finalTheme,
                    selectableDayPredicate: selectableDayPredicate,
                    initialPickerMode: initialPickerMode,
                    calendarDirection: calendarDirection,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDialogActions(
                  context: context,
                  pickerKey: pickerKey,
                  theme: finalTheme,
                  hebrewFormat: hebrewFormat,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDialogActions({
  required BuildContext context,
  required GlobalKey<_MaterialHebrewDatePickerState> pickerKey,
  required HebrewDatePickerTheme theme,
  required bool hebrewFormat,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton(
        onPressed: () {
          // Access the state via the key to call the method
          pickerKey.currentState?._goToToday();
        },
        child: Text(hebrewFormat ? 'היום' : 'Today'),
      ),
      Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(hebrewFormat ? 'ביטול' : 'Cancel'),
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              pickerKey.currentState?._confirmDate();
            },
            child: Text(hebrewFormat ? 'אישור' : 'Confirm'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.onPrimaryColor,
              backgroundColor: theme.primaryColor,
            ),
          ),
        ],
      ),
    ],
  );
}

/// Displays a Material Design Hebrew date range picker dialog.
///
/// This function is a helper that wraps the [HebrewDateRangePicker] widget.
///
///  * `selectableDayPredicate`: An optional predicate to disable specific days.
Future<DateTimeRange?> showMaterialHebrewDateRangePicker({
  required BuildContext context,
  DateTime? initialStartDate,
  DateTime? initialEndDate,
  required DateTime firstDate,
  required DateTime lastDate,
  bool hebrewFormat = true,
  HebrewDatePickerTheme? theme,
  bool Function(DateTime)? selectableDayPredicate,
  HebrewDatePickerMode initialPickerMode = HebrewDatePickerMode.day,
  HebrewCalendarDirection? calendarDirection,
}) async {
  final pickerKey = GlobalKey<_HebrewDateRangePickerState>();
  return showDialog<DateTimeRange>(
    context: context,
    builder: (BuildContext context) {
      final finalTheme = theme ?? const HebrewDatePickerTheme();
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: SizedBox(
          width: 328,
          height: 500,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: HebrewDateRangePicker(
                    key: pickerKey,
                    initialStartDate: initialStartDate,
                    initialEndDate: initialEndDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    hebrewFormat: hebrewFormat,
                    theme: finalTheme,
                    selectableDayPredicate: selectableDayPredicate,
                    initialPickerMode: initialPickerMode,
                    calendarDirection: calendarDirection,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildRangeDialogActions(
                  context: context,
                  pickerKey: pickerKey,
                  theme: finalTheme,
                  hebrewFormat: hebrewFormat,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRangeDialogActions({
  required BuildContext context,
  required GlobalKey<_HebrewDateRangePickerState> pickerKey,
  required HebrewDatePickerTheme theme,
  required bool hebrewFormat,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton(
        onPressed: () => pickerKey.currentState?._goToToday(),
        child: Text(hebrewFormat ? 'היום' : 'Today'),
      ),
      Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(hebrewFormat ? 'ביטול' : 'Cancel'),
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => pickerKey.currentState?._confirmDateRange(),
            child: Text(hebrewFormat ? 'אישור' : 'Confirm'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.onPrimaryColor,
              backgroundColor: theme.primaryColor,
            ),
          ),
        ],
      ),
    ],
  );
}
