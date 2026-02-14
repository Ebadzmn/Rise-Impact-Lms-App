import 'package:flutter/material.dart';
import '../../core/widgets/custom_app_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Notifications',
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFFD88B2F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNotificationItem(
                    icon: Icons.emoji_events_rounded,
                    iconColor: Colors.amber,
                    iconBgColor: Colors.amber.withOpacity(0.1),
                    title: 'New Badge Unlocked! 🏆',
                    description: 'You earned the "Credit Master"\nbadge',
                    time: '2 hours ago',
                    isUnread: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildNotificationItem(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.deepOrange.withOpacity(0.1),
                    title: 'Streak Milestone! 🔥',
                    description: "You've maintained a 7-day\nstreak!",
                    time: '1 day ago',
                    isUnread: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildNotificationItem(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF6A7554),
                    iconBgColor: const Color(0xFF6A7554).withOpacity(0.1),
                    title: 'New Course Available 📚',
                    description: 'Check out "Business\nFundamentals 101"',
                    time: '2 days ago',
                    isUnread: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'View All Notifications',
                  style: TextStyle(
                    color: Color(0xFF576045),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String time,
    required bool isUnread,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD88B2F),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
