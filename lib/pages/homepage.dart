
import 'package:flutter/material.dart';
import 'package:video_calling_app/pages/start_page.dart';
import 'call_page.dart';
import 'join_page.dart';
import '../widgets/common_appbar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController roomController = TextEditingController();
  bool isLoading = false;

  void _navigateToNextPage({required bool isCaller}) async {
    final roomId = roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Room ID")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Optional: simulate a small delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() => isLoading = false);

    final nextPage = isCaller
        ? CallPage(roomId: roomId)
        : JoinPage(roomId: roomId);
    Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 2,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const CommonSliverAppBar(showTabBar: true),
          ],
          body: TabBarView(
            children: [
              // 🟣 TAB 1 — Start Room (PRO UI)
              _buildStartRoomTab(context),

              // 🟢 TAB 2 — Random Call (untouched)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 30),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Make A Wish",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Ur Wish = Downfall",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const Positioned(
                          left: 70,
                          bottom: 130,
                          child: Icon(
                            Icons.tune_outlined,
                            size: 26,
                            color: Colors.black,
                          ),
                        ),
                        const Positioned(
                          right: 70,
                          bottom: 130,
                          child: Icon(
                            Icons.cameraswitch_outlined,
                            size: 26,
                            color: Colors.black,
                          ),
                        ),
                        Positioned(
                          bottom: 100,
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            elevation: 8,
                            child: InkWell(
                              onTap: () => _navigateToNextPage(isCaller: true),
                              customBorder: const CircleBorder(),
                              child: Ink(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6A11CB),
                                      Color(0xFF2575FC),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(45),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "START",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 50,
                          child: Text(
                            "Go Live Now",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 🟡 TAB 3 — Join Room (PRO UI)
              _buildJoinRoomTab(context),
            ],
          ),
        ),
      ),
    );
  }

  // ========================= START ROOM TAB =========================
  // Widget _buildStartRoomTab(BuildContext context) {
  //   return Center(
  //     child: AnimatedSwitcher(
  //       duration: const Duration(milliseconds: 300),
  //       child: isLoading
  //           ? const CircularProgressIndicator()
  //           : Container(
  //               width: 350,
  //               padding: const EdgeInsets.all(24),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     "Start a New Room",
  //                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 20),
  //                   TextField(
  //                     controller: roomController,
  //                     decoration: InputDecoration(
  //                       labelText: "Enter Room ID",
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 25),
  //                   SizedBox(
  //                     width: double.infinity,
  //                     child: ElevatedButton(
  //                       onPressed: () => _navigateToNextPage(isCaller: true),
  //                       child: const Text("Confirm & Start"),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   const Text(
  //                     "Create a new private room to start a secure call.",
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(fontSize: 13, color: Colors.black54),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //     ),
  //   );
  // }

// Replace your current _buildStartRoomTab method with this:
Widget _buildStartRoomTab(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 350,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StartRoomPage()),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Go to Start Room",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    ),
  );
}


  // ========================= JOIN ROOM TAB =========================
  Widget _buildJoinRoomTab(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isLoading
            ? const CircularProgressIndicator()
            : Container(
                width: 350,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Join an Existing Room",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: roomController,
                      decoration: InputDecoration(
                        labelText: "Enter Room ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToNextPage(isCaller: false),
                        child: const Text("Join Room"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your room ID to connect instantly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
