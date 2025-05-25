import 'dart:io';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:todoapp/resource.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

void main() {
  runApp(
    // Wrap the app with ChangeNotifierProvider to provide Resource globally
    ChangeNotifierProvider(create: (context) => resource(), child: TodoApp()),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: TodoListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/*class TimestampLogger extends StatefulWidget {
  @override
  _TimestampLoggerState createState() => _TimestampLoggerState();
}

class _TimestampLoggerState extends State<TimestampLogger> {
  late File _file;
  List<String> _logEntries = [];

  @override
  void initState() {
    super.initState();
    initFile().then(() {
      _logTimestamp("App Opened");
    });
  }

  Future<void> _initFile() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/timestamp_log.txt');
    if (!await _file.exists()) {
      await _file.create();
    }
    _readFile();
  }

  Future<void> _logTimestamp(String trigger) async {
    final timestamp = DateTime.now().toString();
    final entry = "$trigger at $timestamp\n";
    await _file.writeAsString(entry, mode: FileMode.append, flush: true);
    _readFile();
  }

  Future<void> _readFile() async {
    final content = await _file.readAsString();
    setState(() {
      _logEntries = content.trim().split('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timestamp Logger"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _logTimestamp("Button Clicked"),
            child: Text("Log Timestamp"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _logEntries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text(_logEntries[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} */

// Dummy Todo class
class Todo {
  String title;
  String day;
  String assignment;
  bool isCompleted;
  DateTime time = DateTime.now();
  Todo({
    required this.title,
    required this.day,
    required this.assignment,
    this.isCompleted = false,
  });
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['userdata'],
      day: json['days'] ?? 'Unspecified',
      assignment: json['assignments'] ?? 'Unspecified',
      // Default or derive if you have a field
    );
  }
}

class Todo2 {
  final String days;
  final String assignments;
  final String description;

  Todo2({
    required this.days,
    required this.assignments,
    required this.description,
  });

  factory Todo2.fromJson(Map<String, dynamic> json) {
    return Todo2(
      days: json['days'],
      assignments: json['assignments'],
      description: json['description'],
    );
  }
}

// Dummy resource provider
class AssignmentItem {
  final String description;

  AssignmentItem({required this.description});

  factory AssignmentItem.fromJson(Map<String, dynamic> json) {
    return AssignmentItem(description: json['description']);
  }
}

class AssignmentGroup {
  final String assignment;
  final List<AssignmentItem> items;

  AssignmentGroup({required this.assignment, required this.items});
}

class DayGroup {
  final String day;
  final List<AssignmentGroup> assignments;

  DayGroup({required this.day, required this.assignments});
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _addassignmentcontroller =
      TextEditingController();
  String? _selectedassignmentDay;
  final TextEditingController _adddescriptioncontroller =
      TextEditingController();

  String presentUser = 'default';
  String? _selectedDay;
  String? _selectedAssignment;
  List<Todo> _todos = [];
  DateTime? _selectedDate;
  int _selectedIndex = 0;
  String error = '';
  bool isLoading = false;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  List<Todo2> _todos2 = [];
  bool _isLoading2 = true;

  void _addTodo() {
    setState(() {
      _todos.add(
        Todo(
          title: _controller.text,
          day: _selectedDay!,
          assignment: _selectedAssignment!,
        ),
      );
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _toggleCompleted(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  Future<void> fetchTodosFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/receive'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _todos = data.map((item) => Todo.fromJson(item)).toList();
        });
      } else {
        print('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> fetchTodosFromAPI2() async {
    final url = Uri.parse('http://127.0.0.1:8000/display');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _todos2 = data.map((json) => Todo2.fromJson(json)).toList();
        _isLoading2 = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading2 = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTodosFromAPI2();
  }

  Widget _buildChatsView() {
    final Map<String, List<String>> dayAssignmentMap = {
      'Day 1': ['Assignment 1', 'Assignment 2'],
      'Day 2': ['Assignment 1', 'Assignment 2', 'Assignment 3'],
      'Day 3': ['Assignment 1', 'Assignment 2', 'Assignment 3', 'Assignment 4'],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "📋 Add New Task",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: Icon(Icons.task_alt),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    hint: const Text('Select Day'),
                    items: dayAssignmentMap.keys.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value;
                        _selectedAssignment = null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedDay != null)
                    DropdownButtonFormField<String>(
                      value: _selectedAssignment,
                      hint: const Text('Select Assignment'),
                      items: dayAssignmentMap[_selectedDay!]!.map((assignment) {
                        return DropdownMenuItem(
                          value: assignment,
                          child: Text(assignment),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAssignment = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Assignment',
                        prefixIcon: Icon(Icons.assignment),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_controller.text.isEmpty ||
                          _selectedDay == null ||
                          _selectedAssignment == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠ Please fill all fields.'),
                          ),
                        );
                      } else {
                        {
                          if (_controller.text.isNotEmpty &&
                              _selectedDay != null &&
                              _selectedAssignment != null) {
                            setState(() {
                              isLoading = true;
                              error = '';
                            });

                            try {
                              final response = await http.post(
                                Uri.parse('http://127.0.0.1:8000/send/'),
                                body: {
                                  'userid': Provider.of<resource>(context,
                                          listen: false)
                                      .PresentWorkingUser,
                                  'userdata': _controller.text.trim(),
                                  'days': _selectedDay?.trim() ?? '',
                                  'assignments':
                                      _selectedAssignment?.trim() ?? '',
                                },
                              );

                              debugPrint(
                                  'Response code: ${response.statusCode}');
                              debugPrint('Response body: ${response.body}');
                              debugPrint(
                                  'userid : ${Provider.of<resource>(context, listen: false).PresentWorkingUser}');
                              debugPrint(
                                  'user data : ${_selectedDay?.trim() ?? ''}');
                              debugPrint(
                                  'assignments : ${_selectedAssignment?.trim() ?? ''}');

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'New Task Saved Succesfully....')),
                                );
                                await Future.delayed(
                                    const Duration(seconds: 1));

                                // Show success dialog
                              } else {
                                setState(() {
                                  error = 'userAlreadyExists or server error.';
                                });
                                showDialog(
                                  context: context,
                                  builder: (_) => const AlertDialog(
                                    title: Text('Wrong  credentials'),
                                    content:
                                        Text("Please Enter valid credentials."),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                error = 'Network error: $e';
                              });
                              debugPrint('Login error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login failed: $e')),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_todos.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📝 Recent Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._todos.reversed.take(3).map(
                      (todo) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(todo.title),
                          subtitle: Text(
                            "Day: ${todo.day}, ${todo.assignment}",
                          ),
                          trailing: Text(
                            DateFormat('MMM d, HH:mm').format(todo.time),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChatsView2() {
    final Map<String, List<String>> dayAssignmentMap = {
      'Day 1': ['Problem 1', 'Problem 2'],
      'Day 2': ['Problem 1', 'Problem 2', 'Problem 3'],
      'Day 3': ['Problem 1', 'Problem 2', 'Problem 3', 'Problem 4'],
      'Day 4': ['Problem 1', 'Problem 2'],
      'Day 5': ['Problem 1', 'Problem 2'],
      'Day 6': ['Problem 1', 'Problem 2'],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "📋 Add New Assignment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _addassignmentcontroller,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: Icon(Icons.task_alt),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedassignmentDay,
                    hint: const Text('Select Day'),
                    items: dayAssignmentMap.keys.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedassignmentDay = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adddescriptioncontroller,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (false) {
                      } else {
                        {
                          if (true) {
                            setState(() {
                              isLoading = true;
                              error = '';
                            });

                            try {
                              final response = await http.post(
                                Uri.parse('http://127.0.0.1:8000/assignments/'),
                                body: {
                                  'days': _selectedassignmentDay,
                                  'assignments':
                                      _addassignmentcontroller.text.trim(),
                                  'description':
                                      _adddescriptioncontroller.text.trim(),
                                },
                              );

                              debugPrint(
                                  'Response code: ${response.statusCode}');
                              debugPrint('Response body: ${response.body}');
                              debugPrint(
                                  'userid : ${Provider.of<resource>(context, listen: false).PresentWorkingUser}');
                              debugPrint(
                                  'user data : ${_selectedDay?.trim() ?? ''}');
                              debugPrint(
                                  'assignments : ${_selectedAssignment?.trim() ?? ''}');

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'New Task Saved Succesfully....')),
                                );
                                await Future.delayed(
                                    const Duration(seconds: 1));

                                // Show success dialog
                              } else {
                                setState(() {
                                  error = 'userAlreadyExists or server error.';
                                });
                                showDialog(
                                  context: context,
                                  builder: (_) => const AlertDialog(
                                    title: Text('Wrong  credentials'),
                                    content:
                                        Text("Please Enter valid credentials."),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                error = 'Network error: $e';
                              });
                              debugPrint('Login error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login failed: $e')),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Assignment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_todos.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📝 Recent Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._todos.reversed.take(3).map(
                      (todo) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(todo.title),
                          subtitle: Text(
                            "Day: ${todo.day}, ${todo.assignment}",
                          ),
                          trailing: Text(
                            DateFormat('MMM d, HH:mm').format(todo.time),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusView() {
    fetchTodosFromAPI();

    // Group todos by day first
    Map<String, Map<String, List<Todo>>> groupedByDay = {};

    for (var todo in _todos.where((todo) {
      bool matchesSearch = todo.title.toLowerCase().contains(_searchQuery);

      bool matchesTab = _selectedTabIndex == 0 ||
          (_selectedTabIndex == 1 && todo.isCompleted) ||
          (_selectedTabIndex == 2 && !todo.isCompleted);

      bool matchesDate = true;
      if (_startDate != null) {
        matchesDate &= todo.time.isAfter(
          _startDate!.subtract(Duration(days: 1)),
        );
      }
      if (_endDate != null) {
        matchesDate &= todo.time.isBefore(_endDate!.add(Duration(days: 1)));
      }

      return matchesSearch && matchesTab && matchesDate;
    })) {
      groupedByDay.putIfAbsent(todo.day, () => {});
      groupedByDay[todo.day]!.putIfAbsent(todo.assignment, () => []).add(todo);
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Task',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                ['All', 'Completed', 'Pending'].asMap().entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: _selectedTabIndex == entry.key,
                onSelected: (_) {
                  setState(() {
                    _selectedTabIndex = entry.key;
                  });
                },
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Date Range Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _startDate == null
                        ? 'Start Date'
                        : 'From: ${DateFormat.yMMMd().format(_startDate!)}',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _endDate == null
                        ? 'End Date'
                        : 'To: ${DateFormat.yMMMd().format(_endDate!)}',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Day Cards
        Expanded(
          child: groupedByDay.isEmpty
              ? const Center(child: Text('No tasks found.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: (() {
                    var sortedEntries = groupedByDay.entries.toList();
                    sortedEntries.sort((a, b) {
                      int dayA = int.tryParse(
                              a.key.replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      int dayB = int.tryParse(
                              b.key.replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      return dayA.compareTo(dayB);
                    });
                    return sortedEntries.map((dayEntry) {
                      String day = dayEntry.key;
                      Map<String, List<Todo>> assignments = dayEntry.value;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              const Icon(Icons.today, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          children: assignments.entries.map((assignmentEntry) {
                            String assignment = assignmentEntry.key;
                            List<Todo> todos = assignmentEntry.value;

                            return ListTile(
                              title: Text(assignment),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: Text('$day - $assignment'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: todos.map((todo) {
                                          return ListTile(
                                            title: Text(todo.title),
                                            subtitle: Text(
                                              DateFormat(
                                                'MMM d, HH:mm',
                                              ).format(todo.time),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            ctx,
                                          ).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }).toList();
                  })(),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusView2() {
    fetchTodosFromAPI2();
    // Group todos by day first
    Map<String, Map<String, List<Todo2>>> groupedByDay = {};
    print(_todos2);

    for (var todo in _todos2) {
      final day = todo.days;
      final assignment = todo.assignments;

      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = {};
      }

      if (!groupedByDay[day]!.containsKey(assignment)) {
        groupedByDay[day]![assignment] = [];
      }

      groupedByDay[day]![assignment]!.add(todo);
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Task',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                ['All', 'Completed', 'Pending'].asMap().entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: _selectedTabIndex == entry.key,
                onSelected: (_) {
                  setState(() {
                    _selectedTabIndex = entry.key;
                  });
                },
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Date Range Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _startDate == null
                        ? 'Start Date'
                        : 'From: ${DateFormat.yMMMd().format(_startDate!)}',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _endDate == null
                        ? 'End Date'
                        : 'To: ${DateFormat.yMMMd().format(_endDate!)}',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Day Cards
        Expanded(
          child: groupedByDay.isEmpty
              ? const Center(child: Text('No tasks found.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: (() {
                    var sortedEntries = groupedByDay.entries.toList();
                    sortedEntries.sort((a, b) {
                      int dayA = int.tryParse(
                              a.key.replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      int dayB = int.tryParse(
                              b.key.replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      return dayA.compareTo(dayB);
                    });
                    return sortedEntries.map((dayEntry) {
                      String day = dayEntry.key;
                      Map<String, List<Todo2>> assignments = dayEntry.value;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              const Icon(Icons.today, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          children: assignments.entries.map((assignmentEntry) {
                            String assignments = assignmentEntry.key;
                            List<Todo2> todos = assignmentEntry.value;

                            return ListTile(
                              title: Text(assignments),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: Text('$day - $assignments'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: todos.map((todo) {
                                          return ListTile(
                                            title: Text(todo.days),
                                          );
                                        }).toList(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            ctx,
                                          ).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }).toList();
                  })(),
                ),
        ),
      ],
    );
  }

  Widget _buildCallsView() {
    final List<String> members = ['Alice', 'Bob', 'Charlie'];
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.call),
          title: Text(members[index]),
          trailing: const Icon(Icons.phone_forwarded),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    print("here exists");
    if (_selectedIndex == 0) {
      if (Provider.of<resource>(context, listen: false).PresentWorkingUser ==
          'mahesh') {
        currentBody = _buildChatsView2();
        debugPrint(
            'Entered inthisstatement $Provider.of<resource>(context, listen: false).PresentWorkingUser;');
        print("enterednin");
      } else {
        currentBody = _buildChatsView();

        print(resource().PresentWorkingUser);
        debugPrint(presentUser.toString());
      }
    } else if (_selectedIndex == 1) {
      if (Provider.of<resource>(context, listen: false).PresentWorkingUser ==
          'mahesh') {
        currentBody = _buildStatusView2();
        debugPrint(
            'Entered inthisstatement $Provider.of<resource>(context, listen: false).PresentWorkingUser;');
        print("enterednin");
      } else {
        currentBody = _buildStatusView();

        print(resource().PresentWorkingUser);
        debugPrint(presentUser.toString());
      }
    } else {
      currentBody = _buildCallsView();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Consumer<resource>(
        builder: (context, resource, child) {
          presentUser = resource.PresentWorkingUser;
          return Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(presentUser),
                  accountEmail: const Text("Administrator"),
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: AssetImage('assets/imgicon1.png'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('My Todo List'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu<int>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: const [
                  PopupMenuItem(value: 1, child: Text("Log-in")),
                  PopupMenuItem(value: 2, child: Text("Log-out")),
                  PopupMenuItem(value: 3, child: Text("Help")),
                ],
              ).then((value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                } else if (value == 2) {
                  Provider.of<resource>(
                    context,
                    listen: false,
                  ).setLoginDetails('default');
                } else if (value == 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Help selected")),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: currentBody),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
        ],
      ),
    );
  }
}

class BufferPopup {
  void showBufferPopup(
    BuildContext context,
    String text1,
    String text2,
    String text3,
  ) async {
    // Show the initial buffering dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text1),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(text2),
            ],
          ),
        );
      },
    );

    // Wait for 1 second
    await Future.delayed(const Duration(seconds: 1));

    // Close the initial popup
    Navigator.of(context).pop();

    // Show the success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
            child: Text(text3, style: TextStyle()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the success dialog
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }
}

class popup extends StatelessWidget {
  const popup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popup Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showPopup(
              context,
              "popup Example",
              'The content will be displayed here',
            ); // Call the popup function
          },
          child: const Text("Show Popup"),
        ),
      ),
    );
  }

  void showPopup(BuildContext context, String textt, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textt),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data),
              const SizedBox(height: 10),
              /*  ElevatedButton(
                onPressed: () {
                  print("Popup button pressed!");
                  Navigator.of(context).pop(); // Close the popup
                },
                child: Text("Close Popup"),
              ), */
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _GetUsername = TextEditingController();
  final TextEditingController _GetUserPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  var obj_popup = popup();
  bool eye = true;
  String selectedRole = "default"; // Default role
  String PresentUser = "default";

  // Default credentials for temporary login
  final String _defaultUsername = "admin";
  final String _defaultPassword = "admin123";

  String error = '';
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/login/'),
        body: {
          'username': _GetUsername.text,
          'password': _GetUserPassword.text,
        },
      );

      debugPrint('Response code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Provider.of<resource>(
          context,
          listen: false,
        ).setLoginDetails(_GetUsername.text);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TodoListPage()),
        );
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Login Success'),
            content: Text("You have successfully logged in."),
          ),
        );
      } else {
        setState(() => error = 'Invalid credentials or server error.');
      }
    } catch (e) {
      setState(() => error = 'Network error: $e');
      debugPrint('Login error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          colors: [
                            Colors.orange.shade900,
                            Colors.orange.shade800,
                            Colors.orange.shade400,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 90),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1100),
                                  child: const Text(
                                    "Welcome Back",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 60),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(225, 95, 27, .3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _GetUsername,
                                          decoration: const InputDecoration(
                                            hintText: "Email or Phone number",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            border: InputBorder.none,
                                            prefixIcon: Icon(
                                              Icons.verified_user,
                                              color: Colors.orangeAccent,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Username cannot be empty.";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _GetUserPassword,
                                          obscureText: eye,
                                          decoration: InputDecoration(
                                            hintText: "Password",
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            suffix: InkWell(
                                              onTap: () {
                                                print("visible");
                                                if (eye == false) {
                                                  eye = true;
                                                } else if (eye == true) {
                                                  eye = false;
                                                }
                                                setState(() {});
                                              },
                                              child: Icon(
                                                // iconColor: Colors.red,
                                                (eye == true)
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.lightBlue,
                                                size: 22,
                                              ),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.lock,
                                              color: Colors.orangeAccent,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Password cannot be empty.";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1300),
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 40),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1400),
                                child: MaterialButton(
                                  onPressed: () async {
                                    Provider.of<resource>(context,
                                            listen: false)
                                        .setLoginDetails(
                                            _GetUsername.text.trim());

                                    // Validate the username and password

                                    setState(() {
                                      isLoading = true;
                                      error = '';
                                    });

                                    try {
                                      final response = await http.post(
                                        Uri.parse(
                                            'http://127.0.0.1:8000/login/'),
                                        body: {
                                          'username': _GetUsername.text.trim(),
                                          'password':
                                              _GetUserPassword.text.trim(),
                                        },
                                      );

                                      debugPrint(
                                          'Response code: ${response.statusCode}');
                                      debugPrint(
                                          'Response body: ${response.body}');

                                      if (response.statusCode == 200) {
                                        // Save username using Provider

                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.bottomSlide,
                                          title:
                                              'Welcome ${_GetUsername.text.trim()}',
                                          desc:
                                              'You have successfully logged in.',
                                          btnOkText: 'Continue',
                                          btnOkOnPress: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TodoListPage()),
                                            );
                                          },
                                        ).show();

                                        await Future.delayed(
                                            const Duration(seconds: 2));

                                        // Navigate to the TodoListPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TodoListPage()),
                                        );

                                        // Show success dialog
                                      } else {
                                        setState(() {
                                          error =
                                              'Invalid credentials or server error.';
                                          showDialog(
                                            context: context,
                                            builder: (_) => const AlertDialog(
                                              title: Text('Wrong  credentials'),
                                              content: Text(
                                                  "Please Enter valid credentials."),
                                            ),
                                          );
                                        });
                                      }
                                    } catch (e) {
                                      setState(() {
                                        error = 'Network error: $e';
                                      });
                                      debugPrint('Login error: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Login failed: $e')),
                                      );
                                    } finally {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  height: 50,
                                  color: Colors.orange[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1500),
                                child: InkWell(
                                  onTap: () {
                                    // Add your desired action here
                                    print(
                                      "Text clicked: Navigate to the Sign-Up Page or Perform Action",
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Didn't Sign up? Let's Do..",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: FadeInUp(
                                      duration: const Duration(
                                        milliseconds: 1600,
                                      ),
                                      child: MaterialButton(
                                        onPressed: () {},
                                        height: 50,
                                        color: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Facebook",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: FadeInUp(
                                      duration: const Duration(
                                        milliseconds: 1700,
                                      ),
                                      child: MaterialButton(
                                        onPressed: () {},
                                        height: 50,
                                        color: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Google",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  String _selectedGender = "Select Gender";
  String _selectedRole = "Select Role";
  final TextEditingController _GetUsername = TextEditingController();
  final TextEditingController _GetUserPassword = TextEditingController();
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.orange.shade900,
                Colors.orange.shade800,
                Colors.orange.shade400,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 75),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 900),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Create a new account",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    FadeInDown(
                      duration: const Duration(milliseconds: 900),
                      child: GestureDetector(
                        onTap: () async {
                          final image = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {});
                          BufferPopup bufferPopup = BufferPopup();
                          bufferPopup.showBufferPopup(
                            context,
                            "Uploading..",
                            "please wait",
                            "Uploaded Complete",
                          );

                          // Perform your image upload or processing logic here
                          await Future.delayed(Duration(seconds: 1));
                          if (image != null) {
                            setState(() {
                              _selectedImage = image;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : null,
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 30,
                                  color: Colors.orange,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildInputField(
                        hintText: "Full Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        hintText: "Mobile Number",
                        icon: Icons.phone,
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdownField(
                        context,
                        title: _selectedGender,
                        icon: Icons.person_outline,
                        items: ["Male", "Female", "Other"],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdownField(
                        context,
                        title: _selectedRole,
                        icon: Icons.people_outline,
                        items: ["Student", "Staff", "Admin"],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(hintText: "Address", icon: Icons.home),
                      const SizedBox(height: 15),
                      _buildInputField(
                        hintText: "Username",
                        icon: Icons.verified_user,
                      ),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: const SizedBox(height: 15),
                      ),
                      _buildInputField(
                        hintText: "Password",
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),
                      FadeInDown(
                        duration: const Duration(milliseconds: 700),
                        child: MaterialButton(
                          onPressed: () async {
                            // Validate the username and password

                            setState(() {
                              isLoading = true;
                              error = '';
                            });

                            try {
                              final response = await http.post(
                                Uri.parse('http://127.0.0.1:8000/signup/'),
                                body: {
                                  'username': _GetUsername.text.trim(),
                                  'password': _GetUserPassword.text.trim(),
                                },
                              );

                              debugPrint(
                                  'Response code: ${response.statusCode}');
                              debugPrint('Response body: ${response.body}');

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Signup Succesfull: Please Login....')),
                                );
                                await Future.delayed(
                                    const Duration(seconds: 1));

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );

                                // Show success dialog
                              } else {
                                setState(() {
                                  error = 'userAlreadyExists or server error.';
                                  showDialog(
                                    context: context,
                                    builder: (_) => const AlertDialog(
                                      title: Text('Wrong  credentials'),
                                      content: Text(
                                          "Please Enter valid credentials."),
                                    ),
                                  );
                                });
                              }
                            } catch (e) {
                              setState(() {
                                error = 'Network error: $e';
                              });
                              debugPrint('Login error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login failed: $e')),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          height: 50,
                          color: Colors.orange.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(225, 95, 27, .3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller:
              ('Username' == hintText) ? _GetUsername : _GetUserPassword,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Colors.orange),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(225, 95, 27, .3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Colors.orange),
          ),
          value:
              title == "Select Gender" || title == "Select Role" ? null : title,
          hint: Text(title, style: const TextStyle(color: Colors.grey)),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
