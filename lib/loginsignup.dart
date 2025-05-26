import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:todoapp/resource.dart';
import 'package:todoapp/main.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

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
                                            'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/login/'),
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
                                Uri.parse(
                                    'https://8671a5f8-6323-4a16-9356-a2dd53e7078c-00-2m041txxfet0b.pike.replit.dev/signup/'),
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
