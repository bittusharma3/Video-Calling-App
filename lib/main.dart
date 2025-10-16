import 'package:flutter/material.dart';
//import 'package:flutter_application_1/page/drawerPage.dart';
//import 'package:flutter_application_1/page/homePage.dart';
// import 'package:todo_app_new/page/loginPage.dart'; // Ensure 
import 'package:video_calling_app/pages/homepage.dart';
// import 'package:todo_app_new/page/roomPage.dart';
 
// Ensure correct import

void main() {
  runApp(const MainApp());
}

class TaskModel {
  String? title;
  String? description;
  bool? isCompleted;

  TaskModel(
      {required this.title,
      required this.description,
      this.isCompleted = false});
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
    title: "video room app",
    theme: ThemeData(
      useMaterial3: true ,
      colorSchemeSeed: Colors.blue,
    ),
    initialRoute: '/',
    routes: {
      '/': (context)=>  Homepage(),
      //'/room': (context) => const RoomPage(roomID: 'test123' , userID: 'user1'),
      },
    );
  }
}



// // import 'package:flutter/material.dart';
// // import 'package:todo_app_new/page/roomPage.dart';
// // import 'package:uuid/uuid.dart';

// class Homepage extends StatelessWidget {
//   final TextEditingController roomController = TextEditingController();
//   //final String userID = const Uuid().v4(); // unique user ID

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Join a Room'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "Enter Room ID to Join Video Call",
//               style: TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: roomController,
//               decoration: InputDecoration(
//                 hintText: "Room ID (e.g. room123)",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () {
//                 final roomID = roomController.text.trim();
//                 if (roomID.isNotEmpty) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                          Homepage(),
//                   ),
//                   );
//                 }
//               },
//               child: const Text("Join Room"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






