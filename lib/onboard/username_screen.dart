import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/main.dart';


class UsernameScreen extends StatefulWidget {
 @override
 _UsernameScreenState createState() => _UsernameScreenState();
}


class _UsernameScreenState extends State<UsernameScreen> {
 final TextEditingController _usernameController = TextEditingController();
 String? _selectedPfp;


 // List of profile pictures
 final List<String> _pfpList = [
   'assets/profiles/pfp1.png',
    'assets/profiles/pfp2.png',
    'assets/profiles/pfp3.png',
    'assets/profiles/pfp4.png',
    'assets/profiles/pfp5.png',
    'assets/profiles/pfp6.png'
 ];


 void _saveData() async {
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('username', _usernameController.text);
   await prefs.setString('profile_picture', _selectedPfp!);
   // Navigate to the next screen, e.g., HomeScreen
   Navigator.of(context).pushReplacement(
     MaterialPageRoute(builder: (context) => HomeScreen()),
   );
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text('Set Username & Profile Picture')),
     body: Padding(
       padding: EdgeInsets.all(16.0),
       child: Column(
         children: [
           TextField(
             controller: _usernameController,
             decoration: InputDecoration(labelText: 'Username'),
           ),
           SizedBox(height: 20),
           GridView.builder(
             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
             itemCount: _pfpList.length,
             shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
             itemBuilder: (context, index) {
               return GestureDetector(
                 onTap: () {
                   setState(() {
                     _selectedPfp = _pfpList[index];
                   });
                 },
                 child: Container(
                   margin: EdgeInsets.all(8.0),
                   decoration: BoxDecoration(
                     border: Border.all(
                       color: _selectedPfp == _pfpList[index] ? Colors.blue : Colors.grey,
                     ),
                   ),
                   child: Image.asset(_pfpList[index]),
                 ),
               );
             },
           ),
           SizedBox(height: 20),
           ElevatedButton(
             onPressed: _saveData,
             child: Text('Save'),
           ),
         ],
       ),
     ),
   );
 }
}



