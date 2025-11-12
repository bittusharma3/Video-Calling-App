import 'package:flutter/material.dart';
import 'package:video_calling_app/widgets/common_appbar.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<Map<String, String>> _reports = [
    {"title": "Spam User", "description": "User was sending spam messages."},
    {
      "title": "Inappropriate Content",
      "description": "Offensive language in chat.",
    },
    {"title": "Harassment", "description": "User was harassing me repeatedly."},
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📋 Reports",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Hereeee are your submitted reports. You can view details or manage them below.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _reports.isEmpty
                    ? const Center(
                        child: Text(
                          "No reports yet.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _reports.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return _ReportCard(
                            title: report["title"]!,
                            description: report["description"]!,
                          );
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

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;

  const _ReportCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {},
              child: const Text("View Details"),
            ),
          ),
        ],
      ),
    );
  }
}
