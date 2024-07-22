import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';

import 'theme.dart';

class MaterialHebrewDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChange;
  final ValueChanged<DateTime> onConfirmDate;
  final bool hebrewFormat;
  final HebrewDatePickerTheme? theme;

  MaterialHebrewDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChange,
    required this.onConfirmDate,
    this.hebrewFormat = true,
    this.theme,
  })  : assert(firstDate.isBefore(lastDate),
            'firstDate of ${firstDate.toIso8601String()} must be before lastDate of ${lastDate.toIso8601String()}'),
        assert(initialDate.isAfter(firstDate) && initialDate.isBefore(lastDate),
            'initialDate must be after firstDate and before lastDate');

  @override
  _MaterialHebrewDatePickerState createState() =>
      _MaterialHebrewDatePickerState();
}

class _MaterialHebrewDatePickerState extends State<MaterialHebrewDatePicker> {
  late JewishDate _selectedDate;
  late JewishDate _displayedMonth;
  late HebrewDateFormatter _formatter;
  late PageController _pageController;
  late int _currentPage;
  late List<int> _years;
  late int _totalMonths;
  bool _isYearSelectionActive = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = JewishDate.fromDateTime(widget.initialDate);
    _displayedMonth = JewishDate.fromDateTime(widget.initialDate);
    _formatter = HebrewDateFormatter()..hebrewFormat = widget.hebrewFormat;
    _totalMonths = _monthsBetween(JewishDate.fromDateTime(widget.firstDate),
        JewishDate.fromDateTime(widget.lastDate));
    _currentPage = _monthsBetween(
        JewishDate.fromDateTime(widget.firstDate), _displayedMonth);
    _pageController = PageController(initialPage: _currentPage);
    _initializeYears();
  }

  void _initializeYears() {
    final startYear = JewishDate.fromDateTime(widget.firstDate).getJewishYear();
    final endYear = JewishDate.fromDateTime(widget.lastDate).getJewishYear();
    _years =
        List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  @override
  Widget build(BuildContext context) {
    const defaultTheme = HebrewDatePickerTheme();
    final mergedTheme = HebrewDatePickerTheme(
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
                    borderRadius: BorderRadius.circular(28)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(mergedTheme),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _isYearSelectionActive
                            ? _buildYearSelector(mergedTheme)
                            : _buildCalendar(mergedTheme),
                      ),
                    ),
                    _buildActions(mergedTheme),
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
            style: theme.headerTextStyle.copyWith(
              color: theme.onPrimaryColor,
            ),
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

  Widget _buildCalendar(HebrewDatePickerTheme theme) {
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
              itemBuilder: (context, index) => _buildMonthView(theme, index),
              itemCount: _totalMonths,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(HebrewDatePickerTheme theme, int pageIndex) {
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
      itemCount: 42,
      itemBuilder: (context, index) {
        final int day = index - firstWeekday + 2;
        if (day < 1 || day > daysInMonth) return Container();

        final currentDate = JewishDate()
          ..setJewishDate(
              monthDate.getJewishYear(), monthDate.getJewishMonth(), day);
        final isSelected = currentDate.compareTo(_selectedDate) == 0;
        final isDisabled = currentDate
                    .compareTo(JewishDate.fromDateTime(widget.firstDate)) <
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
                      _formatter.formatHebrewNumber(day),
                      style: theme.bodyTextStyle.copyWith(
                        color: isSelected
                            ? theme.onPrimaryColor
                            : isDisabled
                                ? theme.disabledColor
                                : theme.onSurfaceColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildYearSelector(HebrewDatePickerTheme theme) {
    return SizedBox(
      height: 300,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2,
        ),
        itemCount: _years.length,
        itemBuilder: (context, index) {
          final year = _years[index];
          final isSelected = year == _displayedMonth.getJewishYear();
          return InkWell(
            onTap: () => _selectYear(year),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? theme.selectedColor : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.hebrewFormat
                      ? _formatter.formatHebrewNumber(year)
                      : year.toString(),
                  style: theme.bodyTextStyle.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.onPrimaryColor
                        : theme.onSurfaceColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
            ),
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page.clamp(0, _totalMonths - 1);
      _displayedMonth = _getMonthFromPageIndex(_currentPage);
    });
  }

  void _confirmDate() {
    widget.onConfirmDate(_selectedDate.getGregorianCalendar());
    Navigator.of(context).pop();
  }

  void _toggleYearSelection() {
    setState(() {
      _isYearSelectionActive = !_isYearSelectionActive;
    });
  }

  void _selectYear(int year) {
    final newDate = JewishDate()
      ..setJewishDate(year, _displayedMonth.getJewishMonth(), 1);
    final newPage =
        _monthsBetween(JewishDate.fromDateTime(widget.firstDate), newDate);

    setState(() {
      _currentPage = newPage.clamp(0, _totalMonths - 1);
      _displayedMonth = _getMonthFromPageIndex(_currentPage);
      _isYearSelectionActive = false;
    });
    //ensure that build has completed before jumping to page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentPage);
    });
  }

  String _formatFullDate(JewishDate date) {
    final dayOfWeek = _getHebrewDayOfWeek(date.getDayOfWeek());
    final day = _formatter.formatHebrewNumber(date.getJewishDayOfMonth());
    final month = _getHebrewMonthName(date.getJewishMonth());
    final year = _formatter.formatHebrewNumber(date.getJewishYear());
    return '$dayOfWeek, $day $month $year';
  }

  String _getHebrewMonthName(int month) {
    List<String> months;
    if (widget.hebrewFormat)
      months = [
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
        'אדר'
      ];
    else {
      months = [
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
        'Adar'
      ];
    }

    if (_displayedMonth.isJewishLeapYear()) {
      if (month == JewishDate.ADAR) {
        return widget.hebrewFormat ? 'אדר א' : 'Adar I';
      } else if (month == JewishDate.ADAR_II) {
        return widget.hebrewFormat ? 'אדר ב' : 'Adar II';
      }
    }

    // Adjust index for months after Adar in leap years
    int adjustedIndex = month - 1;
    if (_displayedMonth.isJewishLeapYear() && month > JewishDate.ADAR) {
      adjustedIndex--;
    }

    return months[adjustedIndex];
  }

  String _getHebrewDayOfWeek(int day) {
    final days = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];
    return days[day - 1];
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
      for (int i = 0; i > index; i--) {
        date.back();
      }
    }
    return date;
  }

  _selectDate(JewishDate currentDate) {
    setState(() {
      _selectedDate = currentDate;
    });
    widget.onDateChange(currentDate.getGregorianCalendar());
  }

  Widget _buildMonthSelector(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: _toggleYearSelection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_getHebrewMonthName(_displayedMonth.getJewishMonth())} ${widget.hebrewFormat ? _formatter.formatHebrewNumber(_displayedMonth.getJewishYear()) : _displayedMonth.getJewishYear()}',
                    style: theme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                ],
              ),
            ),
          ),
          if (!_isYearSelectionActive)
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
    final weekdays = widget.hebrewFormat
        ? ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays
            .map((day) => Text(day,
                style: theme.weekdayTextStyle.copyWith(
                  color: theme.onSurfaceColor.withOpacity(0.6),
                )))
            .toList(),
      ),
    );
  }
}

class HebrewDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final bool hebrewFormat;
  final HebrewDatePickerTheme? theme;

  HebrewDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateRangeChanged,
    this.hebrewFormat = true,
    this.theme,
  });

  @override
  _HebrewDateRangePickerState createState() => _HebrewDateRangePickerState();
}

class _HebrewDateRangePickerState extends State<HebrewDateRangePicker> {
  late JewishDate _startDate;
  late JewishDate _endDate;
  late JewishDate _displayedMonth;
  late HebrewDateFormatter _formatter;
  late PageController _pageController;
  late int _currentPage;
  late int _totalMonths;
  bool _isSelectingEndDate = false;
  bool _hasSelection = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the first selectable date, but don't mark as selected
    _startDate = JewishDate.fromDateTime(widget.firstDate);
    _endDate = JewishDate.fromDateTime(widget.firstDate);

    // Set the displayed month to the first date or current date, whichever is later
    DateTime initialDisplayDate = widget.firstDate.isAfter(DateTime.now())
        ? widget.firstDate
        : DateTime.now();
    _displayedMonth = JewishDate.fromDateTime(initialDisplayDate);

    _formatter = HebrewDateFormatter()..hebrewFormat = widget.hebrewFormat;
    _totalMonths = _monthsBetween(JewishDate.fromDateTime(widget.firstDate),
        JewishDate.fromDateTime(widget.lastDate));
    _currentPage = _monthsBetween(
        JewishDate.fromDateTime(widget.firstDate), _displayedMonth);
    _pageController = PageController(initialPage: _currentPage);
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

  Widget build(BuildContext context) {
    const defaultTheme = HebrewDatePickerTheme();
    final mergedTheme = HebrewDatePickerTheme(
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
                    _buildHeader(mergedTheme),
                    Flexible(
                      child: _buildCalendar(mergedTheme),
                    ),
                    _buildFooter(mergedTheme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    HebrewDatePickerTheme theme,
  ) {
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
                  Text(_hasSelection && !_isSelectingEndDate
                      ? _formatDate(_endDate)
                      : '-'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Update _buildFooter to disable the confirm button when no selection

  Widget _buildFooter(HebrewDatePickerTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.hebrewFormat ? 'ביטול' : 'Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
            ),
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

  Widget _buildCalendar(HebrewDatePickerTheme theme) {
    return Container(
      color: theme.surfaceColor,
      child: Column(
        children: [
          _buildMonthHeader(theme, _displayedMonth),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalMonths,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) => _buildMonthView(theme, index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(HebrewDatePickerTheme theme, int pageIndex) {
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
                monthDate.getJewishYear(), monthDate.getJewishMonth(), day);
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
                        _formatter.formatHebrewNumber(day),
                        style: theme.bodyTextStyle.copyWith(
                          color: isSelected
                              ? theme.onPrimaryColor
                              : isDisabled
                                  ? theme.onSurfaceColor.withOpacity(0.38)
                                  : isToday
                                      ? theme.todayColor
                                      : theme.onSurfaceColor,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: size * 2.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildMonthHeader(
    HebrewDatePickerTheme theme,
    JewishDate monthDate,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 0 ? _showPreviousMonth : null,
        ),
        Text(
          '${_getHebrewMonthName(monthDate.getJewishMonth())} ${widget.hebrewFormat ? _formatter.formatHebrewNumber(monthDate.getJewishYear()) : monthDate.getJewishYear().toString()}',
          style: theme.headerTextStyle,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < _totalMonths - 1 ? _showNextMonth : null,
        ),
      ],
    );
  }

  void _confirmDateRange() {
    final selectedRange = DateTimeRange(
      start: _startDate.getGregorianCalendar(),
      end: _endDate.getGregorianCalendar(),
    );

    // Use Navigator.of(context).pop() to close the dialog and return the result
    Navigator.of(context).pop(selectedRange);
  }

  void _showPreviousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showNextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _displayedMonth = _getMonthFromPageIndex(_currentPage);
    });
  }

  bool _isDateDisabled(JewishDate date) {
    return date.compareTo(JewishDate.fromDateTime(widget.firstDate)) < 0 ||
        date.compareTo(JewishDate.fromDateTime(widget.lastDate)) > 0;
  }

  String _formatDate(JewishDate date) {
    final day = _formatter.formatHebrewNumber(date.getJewishDayOfMonth());
    final month = _getHebrewMonthName(date.getJewishMonth());
    final year = widget.hebrewFormat
        ? _formatter.formatHebrewNumber(date.getJewishYear())
        : date.getJewishYear().toString();
    return '$day $month $year';
  }

  String _getHebrewMonthName(int month) {
    List<String> months;
    if (widget.hebrewFormat)
      months = [
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
        'אדר'
      ];
    else {
      months = [
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
        'Adar'
      ];
    }

    if (_displayedMonth.isJewishLeapYear()) {
      if (month == JewishDate.ADAR) {
        return widget.hebrewFormat ? 'אדר א' : 'Adar I';
      } else if (month == JewishDate.ADAR_II) {
        return widget.hebrewFormat ? 'אדר ב' : 'Adar II';
      }
    }

    // Adjust index for months after Adar in leap years
    int adjustedIndex = month - 1;
    if (_displayedMonth.isJewishLeapYear() && month > JewishDate.ADAR) {
      adjustedIndex--;
    }

    return months[adjustedIndex];
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
      for (int i = 0; i > index; i--) {
        date.back();
      }
    }
    return date;
  }
}

// Helper function to show the single date picker
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
        onDateChange: (date) {
          onDateChange(date);
        },
        onConfirmDate: (date) {
          onConfirmDate(date);
        },
        hebrewFormat: hebrewFormat,
        theme: theme,
      );
    },
  );
}

// Helper function to show the date range picker
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
