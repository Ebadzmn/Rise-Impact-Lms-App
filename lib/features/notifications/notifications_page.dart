import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/custom_app_bar.dart';
import 'notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Notifications',
          showBackButton: true,
          actions: [
            Obx(
              () => TextButton(
                onPressed:
                    controller.isMarkAllLoading.value ||
                        controller.unreadCount.value == 0
                    ? null
                    : controller.markAllAsRead,
                child: controller.isMarkAllLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Color(0xFFD88B2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: controller.unreadCount.value > 0
                                  ? const Color(0xFFD88B2F)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${controller.unreadCount.value}',
                              style: TextStyle(
                                color: controller.unreadCount.value > 0
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.notificationList.isEmpty) {
            return const _LoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.notificationList.isEmpty) {
            return _ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.refreshNotifications,
            );
          }

          if (controller.notificationList.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: const Color(0xFFD88B2F),
            onRefresh: controller.refreshNotifications,
            child: ListView.separated(
              controller: controller.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount:
                  controller.notificationList.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= controller.notificationList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD88B2F),
                      ),
                    ),
                  );
                }

                final item = controller.notificationList[index];
                final isMarking = controller.markingIds.contains(item.id);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isMarking
                      ? null
                      : () => controller.openNotification(context, item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? Colors.white
                          : const Color(0xFFF9F4E8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: item.isRead
                            ? const Color(0xFFE8E8E8)
                            : const Color(0xFFD88B2F).withOpacity(0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? const Color(0xFFF0F0F0)
                                : const Color(0xFFD88B2F).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconForNotification(item),
                            color: item.isRead
                                ? const Color(0xFF7A7A7A)
                                : const Color(0xFFD88B2F),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: item.isRead
                                            ? FontWeight.w600
                                            : FontWeight.bold,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!item.isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD88B2F),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (isMarking)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF5F5F5F),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.timeLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8A8A8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  IconData _iconForNotification(NotificationItemModel item) {
    final title = item.title.toLowerCase();
    final type = item.raw['type']?.toString().toLowerCase() ?? '';

    if (title.contains('badge') || type.contains('badge')) {
      return Icons.emoji_events_rounded;
    }
    if (title.contains('streak') || type.contains('streak')) {
      return Icons.local_fire_department_rounded;
    }
    if (title.contains('course') || type.contains('course')) {
      return Icons.menu_book_rounded;
    }
    return Icons.notifications_outlined;
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFD88B2F)),
          SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B6B6B)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Color(0xFF9B9B9B),
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'New updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF7B7B7B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFD88B2F),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF5F5F5F)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD88B2F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
