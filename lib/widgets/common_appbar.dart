import 'package:flutter/material.dart';

class CommonSliverAppBar extends StatelessWidget {
  final bool showTabBar;

  const CommonSliverAppBar({super.key, this.showTabBar = false});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;

    return SliverAppBar(
      backgroundColor: backgroundColor,
      floating: true,
      pinned: true,
      snap: true,
      stretch: true,
      elevation: 0,
      title: const Text(
        "O M E G L E",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      leading: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
            'https://img.freepik.com/premium-psd/avatar-profile-cool-cute-boy-with-hoodie_363054-46.jpg?w=360',
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.bookmark_border, color: Colors.black),
        ),
      ],
      bottom: showTabBar
          ? const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: "Start a Room"),
                Tab(text: "Random Call"),
                Tab(text: "Join a Room"),
              ],
            )
          : null,
    );
  }
}
