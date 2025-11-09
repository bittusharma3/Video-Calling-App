import 'package:flutter/material.dart';
import 'package:video_calling_app/widgets/common_appbar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final List<ActivityItem> activities = [
    ActivityItem(
      icon: Icons.video_call,
      title: "You started a room",
      subtitle: "5 minutes ago",
    ),
    ActivityItem(
      icon: Icons.meeting_room,
      title: "Joined room with John",
      subtitle: "10 minutes ago",
    ),
    ActivityItem(
      icon: Icons.shuffle,
      title: "Random video call with Sarah",
      subtitle: "20 minutes ago",
    ),
    ActivityItem(
      icon: Icons.report,
      title: "Reported inappropriate content",
      subtitle: "1 hour ago",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const CommonSliverAppBar(showTabBar: false),
        ],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📋 Recent Activity",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Keep track of your room activities and interactions.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 5),

              // Activities List
              Expanded(
                child: ListView.separated(
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _ActivityCard(activity: activity);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Activity Model -----------------
class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

// ----------------- Activity Card Widget -----------------
class _ActivityCard extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black12,
            child: Icon(activity.icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
