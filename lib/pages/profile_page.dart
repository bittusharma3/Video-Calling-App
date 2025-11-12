import 'package:flutter/material.dart';
 import 'package:video_calling_app/widgets/common_appbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://img.freepik.com/premium-psd/avatar-profile-cool-cute-boy-with-hoodie_363054-46.jpg?w=360',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "John Doe",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "@john_brother",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

               const Text(
                "Account Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _ProfileInfoCard(
                icon: Icons.email_outlined,
                title: "Email",
                subtitle: "jhon_cina@example.com",
              ),
              _ProfileInfoCard(
                icon: Icons.phone_outlined,
                title: "Phone",
                subtitle: "9549731817",
              ),
              _ProfileInfoCard(
                icon: Icons.location_on_outlined,
                title: "Location",
                subtitle: "New York , India",
              ),
              const SizedBox(height: 24),

               const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {
                 },
              ),
              _SettingsCard(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                onTap: () {
                 },
              ),
              _SettingsCard(
                icon: Icons.logout_outlined,
                title: "Logout",
                onTap: () {
                 },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

 class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
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
