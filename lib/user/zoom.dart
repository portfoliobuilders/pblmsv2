import 'package:flutter/material.dart';

class PriorityTask extends StatelessWidget {
  const PriorityTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Live Zoom Meeting Class",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Join the live class now",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.video_call),
                  label: const Text("Join Zoom Meeting"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: isMobile ? 16 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Add functionality to join Zoom meeting
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Recorded Zoom Meeting Videos",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(5, (index) {
                return RecordedVideoItem(
                  title: "Zoom Session ${index + 1}",
                  description: "Recorded on: 2023-11-0${index + 1}",
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
class RecordedVideoItem extends StatelessWidget {
  final String title;
  final String description;

  const RecordedVideoItem({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: Colors.blueAccent,
                size: isMobile ? 24 : 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Play the recorded video
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 8 : 10,
                    horizontal: isMobile ? 12 : 16,
                  ),
                ),
                child: const Text(
                  "Watch",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
