import 'package:flutter/material.dart';
import 'resource.dart';
import 'loginsignup.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

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

// Dummy Todo class
class Todo {
  final String userid;
  final String userdata;
  final String day;
  final String assignment;
  final String title; // alias for userdata
  final DateTime time; // optional, mock if needed
  bool isCompleted;

  Todo({
    required this.userid,
    required this.userdata,
    required this.day,
    required this.assignment,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userid: json['userid'] ?? '',
      userdata: json['userdata'] ?? '',
      day: json['days'] ?? '',
      assignment: json['assignments'] ?? '',
      title: json['userdata'] ?? '', // match existing UI field
      time: DateTime.now(), // or parse if API returns time
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Todo2 {
  final String userid;
  final String userdata;
  final String days;
  final String assignments;

  Todo2({
    required this.userid,
    required this.userdata,
    required this.days,
    required this.assignments,
  });

  factory Todo2.fromJson(Map<String, dynamic> json) {
    return Todo2(
      userid: json['userid']?.toString() ?? '',
      userdata: json['userdata'] ?? '',
      days: json['days'] ?? '',
      assignments: json['assignments'] ?? '',
    );
  }
}

class Todo3 {
  final String days;
  final String assignments;
  final String description;

  Todo3({
    required this.days,
    required this.assignments,
    required this.description,
  });

  factory Todo3.fromJson(Map<String, dynamic> json) {
    return Todo3(
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
  List<Todo3> _todos3 = [];
  bool _isLoading2 = true;
  bool _isLoading3 = true;
  String status = '';
  Uint8List? fileBytes;
  String? fileName;
  File? file;
  String? fileName2;

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
        Uri.parse(
            'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/receive'),
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

  Future<void> fetchTodosFromAPI3() async {
    final url = Uri.parse(
        'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/display');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _todos3 = data.map((json) => Todo3.fromJson(json)).toList();
        _isLoading3 = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading3 = false;
      });
    }
  }

  Future<void> fetchTodosFromAPI2() async {
    final url = Uri.parse(
        'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/receive');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _todos2 = data.map((json) => Todo2.fromJson(json)).toList();
        _isLoading2 = false;
      });
    } else {
      setState(() {
        _isLoading2 = false;
      });
    }
  }

  Future<void> pickAndUploadFile() async {
    print("entered");
    final result = await FilePicker.platform.pickFiles();
    print("entered 2");

    if (result == null) {
      setState(() {
        status = 'No file selected.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status),
        ),
      );
      return;
    } else {
      setState(() {
        status = 'File selected: ${result.files.first.name}';
      });
      if (kIsWeb) {
        // Web
        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;
        print('pickand uploadFile called');
        print("File bytes: $fileBytes");
        print("File name: $fileName");
      } else {
        // Mobile/Desktop
        file = File(result.files.single.path!);
        fileName = result.files.single.name;
        if (file != null) {
          print(file!.path);
        }
        print("File name: $fileName");
        print('pickand uploadFile called');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTodosFromAPI2();
    fetchTodosFromAPI3();
  }

  Widget _buildChatsView() {
    final Map<String, List<String>> dayAssignmentMap = {
      'Day 1': ['Assignment 1', 'Assignment 2'],
      'Day 2': ['Assignment 1', 'Assignment 2', 'Assignment 3'],
      'Day 3': ['Assignment 1', 'Assignment 2', 'Assignment 3', 'Assignment 4'],
    };

    return SingleChildScrollView(
      //padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    "📋 Add New Task",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      print('button pressed');
                      await pickAndUploadFile();
                      print("object");
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Upload Assignment File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_selectedDay == null || _selectedAssignment == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠ Please fill all fields.'),
                          ),
                        );
                      } else {
                        {
                          if (_selectedDay != null &&
                              _selectedAssignment != null) {
                            setState(() {
                              isLoading = true;
                              error = '';
                            });

                            try {
                              if ((kIsWeb && fileBytes == null) ||
                                  (!kIsWeb &&
                                      (file == null || file!.path.isEmpty))) {
                                print('Exited');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '⚠ Please upload a file before adding a task.')),
                                );
                                return;
                              } else {
                                if (kIsWeb) {
                                  print("File bytes.....: $fileBytes");
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse(
                                        'http://127.0.0.1:8000/uploadfiletos3/'),
                                  );
                                  request.files
                                      .add(http.MultipartFile.fromBytes(
                                    'file',
                                    fileBytes!,
                                    filename: fileName,
                                  ));
                                  var response = await request.send();
                                  print(response.statusCode);
                                  print('File name: $fileName');
                                } else {
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse(
                                        'http://127.0.0.1:8000/uploadfiletos3/'),
                                  );
                                  request.files
                                      .add(await http.MultipartFile.fromPath(
                                    'file',
                                    file!.path,
                                    filename: fileName,
                                  ));
                                  print(
                                      'File path: ${file!.path}, File name: $fileName');
                                  // var response = await request.send();
                                }
                              }
                              final response = await http.post(
                                Uri.parse(
                                    'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/send/'),
                                body: {
                                  'userid': Provider.of<resource>(context,
                                          listen: false)
                                      .PresentWorkingUser,
                                  'userdata':
                                      "${Provider.of<resource>(context, listen: false).PresentWorkingUser}  $fileName",
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
      // padding: const EdgeInsets.all(16),
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
                                Uri.parse(
                                    'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/assignments/'),
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
      // ✅ New condition: Filter only for selectedUserId
      bool matchesUser = todo.userid ==
          Provider.of<resource>(context, listen: false).PresentWorkingUser;

      bool matchesSearch = todo.title.toLowerCase().contains(_searchQuery);
      bool matchesTab = _selectedTabIndex == 0 ||
          (_selectedTabIndex == 1 && todo.isCompleted) ||
          (_selectedTabIndex == 2 && !todo.isCompleted);

      bool matchesDate = true;
      if (_startDate != null) {
        matchesDate &=
            todo.time.isAfter(_startDate!.subtract(Duration(days: 1)));
      }
      if (_endDate != null) {
        matchesDate &= todo.time.isBefore(_endDate!.add(Duration(days: 1)));
      }

      return matchesUser && matchesSearch && matchesTab && matchesDate;
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

        // // Filter tabs
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children:
        //         ['All', 'Completed', 'Pending'].asMap().entries.map((entry) {
        //       return ChoiceChip(
        //         label: Text(entry.value),
        //         selected: _selectedTabIndex == entry.key,
        //         onSelected: (_) {
        //           setState(() {
        //             _selectedTabIndex = entry.key;
        //           });
        //         },
        //       );
        //     }).toList(),
        //   ),
        // ),

        // const SizedBox(height: 12),

        // // Date Range Filter
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: ElevatedButton.icon(
        //           onPressed: () async {
        //             DateTime? picked = await showDatePicker(
        //               context: context,
        //               initialDate: DateTime.now(),
        //               firstDate: DateTime(2022),
        //               lastDate: DateTime.now(),
        //             );
        //             if (picked != null) {
        //               setState(() {
        //                 _startDate = picked;
        //               });
        //             }
        //           },
        //           icon: const Icon(Icons.calendar_today),
        //           label: Text(
        //             _startDate == null
        //                 ? 'Start Date'
        //                 : 'From: ${DateFormat.yMMMd().format(_startDate!)}',
        //           ),
        //         ),
        //       ),
        //       const SizedBox(width: 10),
        //       Expanded(
        //         child: ElevatedButton.icon(
        //           onPressed: () async {
        //             DateTime? picked = await showDatePicker(
        //               context: context,
        //               initialDate: DateTime.now(),
        //               firstDate: DateTime(2022),
        //               lastDate: DateTime.now(),
        //             );
        //             if (picked != null) {
        //               setState(() {
        //                 _endDate = picked;
        //               });
        //             }
        //           },
        //           icon: const Icon(Icons.calendar_month),
        //           label: Text(
        //             _endDate == null
        //                 ? 'End Date'
        //                 : 'To: ${DateFormat.yMMMd().format(_endDate!)}',
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

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
    // Group todos by: userid -> day -> assignment
    Map<String, Map<String, Map<String, List<Todo2>>>> grouped = {};

    for (var todo in _todos2) {
      final userId = todo.userid;
      final day = todo.days;
      final assignment = todo.assignments;

      grouped.putIfAbsent(userId, () => {});
      grouped[userId]!.putIfAbsent(day, () => {});
      grouped[userId]![day]!.putIfAbsent(assignment, () => []);
      grouped[userId]![day]![assignment]!.add(todo);
    }

    return _isLoading2
        ? const Center(child: CircularProgressIndicator())
        : grouped.isEmpty
            ? const Center(child: Text("No data found."))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries.map((userEntry) {
                  final userId = userEntry.key;
                  final daysMap = userEntry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        "User: $userId",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: daysMap.entries.map((dayEntry) {
                        final day = dayEntry.key;
                        final assignmentsMap = dayEntry.value;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: ExpansionTile(
                            title: Text(
                              day,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            children: assignmentsMap.entries.map((assignEntry) {
                              final assignment = assignEntry.key;
                              final todos = assignEntry.value;

                              return ListTile(
                                title: Text(assignment),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('$assignment - $day'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: todos.map((todo) {
                                          return ListTile(
                                            title: Text(todo.userdata),
                                          );
                                        }).toList(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              );
  }

  Widget _buildCallsView() {
    fetchTodosFromAPI3();
    // Group todos by day first
    Map<String, Map<String, List<Todo3>>> groupedByDay = {};
    print(_todos3);

    for (var todo in _todos3) {
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
                      Map<String, List<Todo3>> assignments = dayEntry.value;

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
                            List<Todo3> todos = assignmentEntry.value;

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
                                            title: Text(todo.description),
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

  Widget _buildCallsView2() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search User For Approval',
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

        const SizedBox(height: 12),

        // Day Cards
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String User = "kalyan";
    Widget currentBody;
    print("here exists");
    if (_selectedIndex == 0) {
      if (Provider.of<resource>(context, listen: false).PresentWorkingUser ==
          User) {
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
          User) {
        currentBody = _buildStatusView2();
        debugPrint(
            'Entered inthisstatement $Provider.of<resource>(context, listen: false).PresentWorkingUser;');
        print("enterednin");
      } else {
        currentBody = _buildStatusView();

        print(resource().PresentWorkingUser);
        debugPrint(presentUser.toString());
      }
    } else if (Provider.of<resource>(context, listen: false)
            .PresentWorkingUser ==
        User) {
      currentBody = _buildCallsView2();
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
                  accountEmail: (presentUser == User)
                      ? Text("Administrator")
                      : Text("Student"),
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: AssetImage('assets/imgicon1.png'),
                  ),
                  decoration: BoxDecoration(
                    color: (presentUser == User)
                        ? Colors.blue
                        : Colors.orangeAccent,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () {
                    print("Profile tapped");
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text("Help"),
                  onTap: () {
                    print("Help tapped");
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_emergency),
                  title: const Text("Raise Query"),
                  onTap: () {
                    print("Info tapped");
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    print("Settings tapped");
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Assignments Board'),
        backgroundColor: Colors.green,
        centerTitle: true,
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
      body: Padding(padding: const EdgeInsets.all(6.0), child: currentBody),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color.fromARGB(255, 60, 209, 65),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color.fromARGB(255, 187, 202, 231),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.library_add), label: 'Add Task'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Total'),
        ],
      ),
    );
  }
}
