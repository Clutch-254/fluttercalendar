import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  final int _monthsToShow = 12; // Show 12 months (1 year) in the scroll view
  late List<DateTime> _monthsList;

  // International holidays (date format: 'MM-DD')
  final Map<String, String> _internationalHolidays = {
    '01-01': 'New Year\'s Day',
    '02-14': 'Valentine\'s Day',
    '03-17': 'St. Patrick\'s Day',
    '04-22': 'Earth Day',
    '05-01': 'Labour Day',
    '06-21': 'Summer Solstice',
    '07-04': 'Independence Day (US)',
    '10-31': 'Halloween',
    '12-25': 'Christmas Day',
    '12-31': 'New Year\'s Eve',
  };

  // Mother's Day is the second Sunday in May
  bool _isMothersDay(DateTime date) {
    if (date.month == 5) {
      // Check if it's the second Sunday
      int sundayCount = 0;
      DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
      DateTime checkDate = firstDayOfMonth;

      while (checkDate.day <= date.day) {
        if (checkDate.weekday == DateTime.sunday) {
          sundayCount++;
        }

        if (sundayCount == 2 && checkDate.day == date.day) {
          return true;
        }

        checkDate = checkDate.add(const Duration(days: 1));
      }
    }
    return false;
  }

  // Check if a date is a special event
  String? _getSpecialEvent(DateTime date) {
    String formattedDate =
        '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Check international holidays
    if (_internationalHolidays.containsKey(formattedDate)) {
      return _internationalHolidays[formattedDate];
    }

    // Check Mother's Day
    if (_isMothersDay(date)) {
      return 'Mother\'s Day';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeMonthsList();
    // Set up a timer to update the calendar at midnight
    _setupMidnightUpdate();
  }

  void _initializeMonthsList() {
    final now = DateTime.now();
    // Create a list of months to display (6 months before and after current month)
    _monthsList = List.generate(
      _monthsToShow,
      (index) => DateTime(now.year, now.month - 6 + index, 1),
    );

    // Scroll to current month initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          6 * 320.0, // Approximate height per month * 6 (to get to current month)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupMidnightUpdate() {
    // Calculate time until midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Set up a future to update the calendar at midnight
    Future.delayed(timeUntilMidnight, () {
      if (mounted) {
        setState(() {
          _selectedDate = DateTime.now();
          _currentMonth = DateTime.now();
          _initializeMonthsList(); // Refresh the months list
        });
        _setupMidnightUpdate(); // Setup for the next day
      }
    });
  }

  // Build the month and year header
  Widget _buildHeader(DateTime month) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat('MMMM yyyy').format(month),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Build the weekday labels
  Widget _buildWeekdayLabels() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekdays.map((day) {
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Build the calendar days for a specific month
  Widget _buildCalendarDays(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7; // Adjust for Sunday start

    // Create a list of dates to display
    List<DateTime?> dates =
        List.generate(startWeekday, (index) => null); // Empty spaces
    dates.addAll(List.generate(
        daysInMonth, (index) => DateTime(month.year, month.month, index + 1)));

    // Calculate number of weeks
    final numWeeks = (dates.length / 7).ceil();

    // Pad the remaining spaces in the last week
    while (dates.length < numWeeks * 7) {
      dates.add(null);
    }

    return Column(
      children: List.generate(numWeeks, (weekIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (dayIndex) {
            final index = weekIndex * 7 + dayIndex;
            final date = index < dates.length ? dates[index] : null;

            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _buildDayCell(date),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // Build a single day cell
  Widget _buildDayCell(DateTime? date) {
    if (date == null) {
      return Container();
    }

    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final specialEvent = _getSpecialEvent(date);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? Colors.blue.shade700
              : isSelected
                  ? Colors.blue.shade500
                  : specialEvent != null
                      ? Colors.blue.shade100
                      : null,
          border: Border.all(
            color: isSelected ? Colors.blue.shade900 : Colors.blue.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color:
                    isToday || isSelected ? Colors.white : Colors.blue.shade800,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (specialEvent != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  specialEvent,
                  style: TextStyle(
                    fontSize: 9,
                    color: isToday || isSelected
                        ? Colors.white
                        : Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build a single month calendar
  Widget _buildMonthCalendar(DateTime month) {
    return Column(
      children: [
        _buildHeader(month),
        _buildWeekdayLabels(),
        _buildCalendarDays(month),
        const SizedBox(height: 16), // Add space between months
      ],
    );
  }

  // Build the jump to today button
  Widget _buildJumpToTodayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FloatingActionButton(
        mini: true,
        child: const Icon(Icons.calendar_today),
        onPressed: () {
          final now = DateTime.now();
          setState(() {
            _selectedDate = now;
            _currentMonth = now;
          });

          // Find index of current month in the list
          int currentMonthIndex = _monthsList.indexWhere(
              (month) => month.year == now.year && month.month == now.month);

          if (currentMonthIndex != -1 && _scrollController.hasClients) {
            // Scroll to the current month
            _scrollController.animateTo(
              currentMonthIndex * 320.0, // Approximate height per month
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 4,
          color: Colors.blue.shade50,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Instructions text
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Scroll to view more months',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ),
                // Scrollable calendar area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _monthsList.length,
                    itemBuilder: (context, index) {
                      return _buildMonthCalendar(_monthsList[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Positioned jump to today button
        Positioned(
          bottom: 24,
          right: 24,
          child: _buildJumpToTodayButton(),
        ),
      ],
    );
  }
}
