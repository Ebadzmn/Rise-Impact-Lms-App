import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/notifications/notifications_controller.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final bool useCircularBackground;

  const NotificationBadgeIcon({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.useCircularBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : null;

    if (controller == null) {
      return _buildButton(context, 0);
    }

    return Obx(() => _buildButton(context, controller.unreadCount.value));
  }

  Widget _buildButton(BuildContext context, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: useCircularBackground
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: useCircularBackground ? null : borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.notifications_outlined, color: iconColor),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
