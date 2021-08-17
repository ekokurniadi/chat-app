import 'package:flutter/material.dart';

class CariBantuan extends StatefulWidget {
  @override
  _CariBantuanState createState() => _CariBantuanState();
}

class _CariBantuanState extends State<CariBantuan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              label: Text("Help"),
              onPressed: () {
                print("hello");
              },
              icon: Icon(Icons.help),
            ),
			SizedBox(height:5),
            FloatingActionButton.extended(
              label: Text("List Security"),
              onPressed: () {
                print("hello");
              },
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
