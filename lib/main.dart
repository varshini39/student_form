import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'student.dart';
import 'dbhelper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
    // this step, it will use the sqlite version available on the system.
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: MaterialApp(
        title: 'Student Form - Flutter',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;

  List<Student> students = [];
  List<Student> studentsByName = [];

  //controllers used in insert operation UI
  TextEditingController nameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController rankController = TextEditingController();

  //controllers used in update operation UI
  TextEditingController idUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController genderUpdateController = TextEditingController();
  TextEditingController rankUpdateController = TextEditingController();

  //controllers used in delete operation UI
  TextEditingController idDeleteController = TextEditingController();

  //controllers used in query operation UI
  TextEditingController queryController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Student Form - CRUD'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Insert'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                DefaultTabController.of(context).animateTo(0);
              },
            ),
            ListTile(
              title: const Text('View'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                DefaultTabController.of(context).animateTo(1);
              },
            ),
            ListTile(
              title: const Text('Query'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                DefaultTabController.of(context).animateTo(2);
              },
            ),
            ListTile(
              title: const Text('Update'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                DefaultTabController.of(context).animateTo(3);
              },
            ),
            ListTile(
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                DefaultTabController.of(context).animateTo(4);
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Student Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: genderController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Gender',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: rankController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Rank',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('Insert Student Details'),
                    onPressed: () {
                      String name = nameController.text;
                      String gender = genderController.text;
                      int rank = int.parse(rankController.text);
                      _insert(name, gender, rank);
                    },
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: students.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == students.length) {
                return ElevatedButton(
                  child: const Text('Refresh'),
                  onPressed: () {
                    setState(() {
                      _queryAll();
                    });
                  },
                );
              }
              return SizedBox(
                height: 40,
                child: Center(
                  child: Text(
                    '${students[index].name} [Roll Number: ${students[index].id}] - ${students[index].gender} has rank ${students[index].rank}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
          ),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  height: 100,
                  child: TextField(
                    controller: queryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Student Name',
                    ),
                    onChanged: (text) {
                      if (text.length >= 2) {
                        setState(() {
                          _query(text);
                        });
                      } else {
                        setState(() {
                          studentsByName.clear();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: studentsByName.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        margin: const EdgeInsets.all(2),
                        child: Center(
                          child: Text(
                            '${students[index].name} [Roll Number: ${students[index].id}] - ${students[index].gender} has rank ${students[index].rank}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: idUpdateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Student ID',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: nameUpdateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Student Name',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: genderUpdateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Gender',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: rankController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Rank',
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Update Student Details'),
                  onPressed: () {
                    int id = int.parse(idUpdateController.text);
                    String name = nameUpdateController.text;
                    String gender = genderUpdateController.text;
                    int rank = int.parse(rankController.text);
                    _update(id, name, gender, rank);
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: idDeleteController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Student ID',
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    int id = int.parse(idDeleteController.text);
                    _delete(id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _insert(name, gender, rank) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnGender: gender,
      DatabaseHelper.columnRank: rank,
    };
    Student car = Student.fromMap(row);
    final id = await dbHelper.insert(car);
    _showMessageInScaffold('inserted row id: $id');
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    students.clear();
    for (var row in allRows) {
      students.add(Student.fromMap(row));
    }
    _showMessageInScaffold('Query done.');
    setState(() {});
  }

  void _query(name) async {
    final allRows = await dbHelper.queryRows(name);
    studentsByName.clear();
    for (var row in allRows) {
      studentsByName.add(Student.fromMap(row));
    }
  }

  void _update(id, name, gender, rank) async {
    // row to update
    Student car = Student(id: id, name: name, gender: gender, rank: rank);
    final rowsAffected = await dbHelper.update(car);
    _showMessageInScaffold('updated $rowsAffected row(s)');
  }

  void _delete(id) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(id);
    _showMessageInScaffold('deleted $rowsDeleted row(s): row $id');
  }
}
