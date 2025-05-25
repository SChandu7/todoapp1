import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  // your data variable
  List<dynamic> userData = [];

  // fetchData function to get API data
  Future<void> fetchData() async {
    // your API call here (dummy example)
    final response = await http.get(Uri.parse('https://your-api.com/status'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userData = data;
      });
    } else {
      // handle error
      print("Failed to fetch data");
    }
  }

  // 👇 initState is placed here — called ONCE when the widget is inserted
  @override
  void initState() {
    super.initState();
    fetchData(); // fetch the data when the screen is first loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status")),
      body: userData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userData.length,
              itemBuilder: (context, index) {
                final item = userData[index];
                return ListTile(
                  title: Text(item['userdata']),
                  subtitle: Text(item['assignments']),
                );
              },
            ),
    );
  }
}
