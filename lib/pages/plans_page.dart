import 'package:flutter/material.dart';
 import 'package:video_calling_app/widgets/common_appbar.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      title: "Basic",
      price: "\Rs 499 / month",
      features: ["Create rooms", "Join rooms", "Random calls"],
      color: Colors.blue.shade100,
    ),
    SubscriptionPlan(
      title: "Pro",
      price: "Rs 999 / month",
      features: ["Everything in Basic", "Priority matching", "Ad-free"],
      color: Colors.green.shade100,
    ),
    SubscriptionPlan(
      title: "Premium",
      price: "\Rs 1999 / month",
      features: ["Everything in Pro", "Exclusive rooms", "HD video"],
      color: Colors.purple.shade100,
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text(
                "💎 Plans & Rooms",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Choose the subscription that suits your video chatting needs. Start a room, join an existing one, or connect randomly.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),

               const Text(
                "Subscription Plans",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...plans.map((plan) => _SubscriptionCard(plan: plan)),

              const SizedBox(height: 24),
               const Text(
                "Rooms & Calls",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _RoomActionCard(
                icon: Icons.video_call_outlined,
                title: "Start a Room",
                subtitle: "Create your own private room for friends or public.",
                onTap: () {},
              ),
              _RoomActionCard(
                icon: Icons.meeting_room_outlined,
                title: "Join a Room",
                subtitle: "Enter a room ID to join an existing room.",
                onTap: () {},
              ),
              _RoomActionCard(
                icon: Icons.shuffle,
                title: "Random Video Call",
                subtitle: "Connect with a random user instantly.",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 class SubscriptionPlan {
  final String title;
  final String price;
  final List<String> features;
  final Color color;

  SubscriptionPlan({
    required this.title,
    required this.price,
    required this.features,
    required this.color,
  });
}

 class _SubscriptionCard extends StatelessWidget {
  final SubscriptionPlan plan;
  const _SubscriptionCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: plan.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            plan.price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plan.features
                .map(
                  (feature) => Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

 class _RoomActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoomActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
