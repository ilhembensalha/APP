import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:date_time_format/date_time_format.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat;
  DateTime _focusedDay;
  DateTime _selectedDay;
  Map<DateTime, List<dynamic>> _events;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    DbHelper dbHelper = DbHelper();
    List<Map<String, dynamic>> transactions = await dbHelper.gettr();

    for (var transaction in transactions) {
      
      final date = DateTime.parse(transaction['date']);
      print(date);
      setState(() {
        if (_events.containsKey(date)) {
          _events[date].add(date);
          
        } else {
          _events[date] = [date];
        }
      });
    }

    setState(() {
      _isLoading = false;
    });

    print(_events);
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(fontSize: 20),
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _showTransactionsDialog(context, selectedDay);
                });
              },
              calendarBuilders: CalendarBuilders(
  defaultBuilder: (context, date, focusedDay) {
   
    if (_events.containsKey(date)) {
      for (DateTime d in _events[date]) {
        if (isSameDay(date, d)) {
          return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 76, 175, 175), // Change color as desired
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
        }
      }
    }

    // Custom logic for changing color for specific dates
List<MapEntry<DateTime, List<dynamic>>> eventList = _events.entries.toList();
print(eventList);
DateTime thirdDate = eventList[1].value[0];
  print(thirdDate);
    bool isEventDate = eventList.any((entry) => entry.key == date);
print(isEventDate);
    if (isEventDate) {
      // Change color for May 15, 2023
      return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 175, 76, 137), // Change color as desired
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Default styling for other dates
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  },
),
            ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getEventColor(String typeTrans) {
    if (typeTrans == 'revenu') {
      return Colors.lightGreen;
    } else if (typeTrans == 'depense') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  void _showTransactionsDialog(BuildContext context, DateTime selectedDay) async {
    DbHelper dbHelper = DbHelper();
    List<Map<String, dynamic>> transactions = await dbHelper.getTranByDate(selectedDay);

    List<dynamic> transactionDescriptions =
        transactions.map((transaction) => transaction['name']).toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Transactions - $selectedDay'),
          content: SingleChildScrollView(
            child: Column(
              children: transactionDescriptions.map((transaction) {
                return ListTile(
                  title: Text(transaction),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
