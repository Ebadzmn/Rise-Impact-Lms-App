import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/storage_service.dart';

class NotificationItemModel {
  final String id;
  final String title;
  final String text;
  final DateTime? createdAt;
  final bool isRead;
  final String? route;
  final Map<String, dynamic> raw;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.isRead,
    required this.raw,
    this.route,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return NotificationItemModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Notification',
      text:
          data['text']?.toString() ??
          data['body']?.toString() ??
          data['description']?.toString() ??
          '',
      createdAt: _parseDate(data['createdAt'] ?? data['created_at']),
      isRead: _parseBool(data['isRead'] ?? data['read']),
      route: data['route']?.toString() ?? data['targetRoute']?.toString(),
      raw: Map<String, dynamic>.from(data),
    );
  }

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      title: title,
      text: text,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      route: route,
      raw: raw,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  String get timeLabel {
    final time = createdAt;
    if (time == null) return '';

    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(time);
  }
}

class NotificationsController extends GetxController {
  static const int _pageSize = 20;

  final ApiClient _api = ApiClient.instance;

  final RxList<NotificationItemModel> notificationList =
      <NotificationItemModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isMarkAllLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<String> markingIds = <String>{}.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _loadInitial() async {
    final storage = Get.find<StorageService>();
    if ((storage.getToken() ?? '').isEmpty) {
      isLoading.value = false;
      hasMore.value = false;
      return;
    }

    await fetchNotifications();
  }

  void _onScroll() {
    if (!hasMore.value || isLoadingMore.value) return;
    if (!scrollController.hasClients) return;

    if (scrollController.position.extentAfter < 240) {
      fetchNotifications(loadMore: true);
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
      currentPage.value += 1;
    } else {
      if (isLoading.value) return;
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 1;
      hasMore.value = true;
    }

    try {
      final response = await _api.get(
        ApiEndpoints.notifications,
        query: {'page': currentPage.value, 'limit': _pageSize},
      );

      final responseMap = _asMap(response.data);
      final items = _extractDataList(responseMap)
          .map(NotificationItemModel.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList();

      if (loadMore) {
        final existingIds = notificationList.map((item) => item.id).toSet();
        notificationList.addAll(
          items.where((item) => !existingIds.contains(item.id)),
        );
      } else {
        notificationList.assignAll(items);
      }

      final serverUnread = _extractUnreadCount(responseMap);
      if (serverUnread != null) {
        unreadCount.value = serverUnread;
      } else if (!loadMore) {
        unreadCount.value = notificationList
            .where((item) => !item.isRead)
            .length;
      }

      hasMore.value = _extractHasMore(responseMap, items.length);
    } catch (e, stack) {
      debugPrint('Fetch Notifications Error: $e\n$stack');
      errorMessage.value = 'Failed to load notifications';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    if (id.isEmpty || markingIds.contains(id)) return;

    final index = notificationList.indexWhere((item) => item.id == id);
    if (index == -1 || notificationList[index].isRead) return;

    markingIds.add(id);
    try {
      await _api.patch(ApiEndpoints.markNotificationRead(id));

      notificationList[index] = notificationList[index].copyWith(isRead: true);
      if (unreadCount.value > 0) {
        unreadCount.value -= 1;
      }
    } catch (e, stack) {
      debugPrint('Mark Notification Read Error: $e\n$stack');
      Get.snackbar('Error', 'Failed to mark as read');
      rethrow;
    } finally {
      markingIds.remove(id);
    }
  }

  Future<void> markAllAsRead() async {
    if (isMarkAllLoading.value) return;

    try {
      isMarkAllLoading.value = true;
      await _api.patch(ApiEndpoints.markAllNotificationsRead);

      notificationList.value = notificationList
          .map((item) => item.copyWith(isRead: true))
          .toList();
      unreadCount.value = 0;
    } catch (e, stack) {
      debugPrint('Mark All Notifications Read Error: $e\n$stack');
      Get.snackbar('Error', 'Failed to mark all as read');
    } finally {
      isMarkAllLoading.value = false;
    }
  }

  Future<void> openNotification(
    BuildContext context,
    NotificationItemModel item,
  ) async {
    try {
      await markAsRead(item.id);
    } catch (_) {
      return;
    }

    final route = item.route;
    if (route == null || route.isEmpty) return;

    final normalized = route.startsWith('/') ? route : '/$route';
    if (context.mounted) {
      context.push(normalized);
    }
  }

  void clearState() {
    notificationList.clear();
    unreadCount.value = 0;
    currentPage.value = 1;
    hasMore.value = true;
    isLoading.value = false;
    isLoadingMore.value = false;
    isMarkAllLoading.value = false;
    errorMessage.value = '';
    markingIds.clear();
  }

  List<Map<String, dynamic>> _extractDataList(Map<String, dynamic> map) {
    final dynamic rootData =
        map['data'] ?? map['notifications'] ?? map['items'];

    if (rootData is List) {
      return rootData
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }

    if (rootData is Map) {
      final notifications =
          rootData['notifications'] ?? rootData['items'] ?? rootData['data'];
      if (notifications is List) {
        return notifications
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  int? _extractUnreadCount(Map<String, dynamic> map) {
    final candidates = [
      map['unreadCount'],
      map['unread_count'],
      map['meta'] is Map ? (map['meta'] as Map)['unreadCount'] : null,
      map['pagination'] is Map
          ? (map['pagination'] as Map)['unreadCount']
          : null,
      map['data'] is Map ? (map['data'] as Map)['unreadCount'] : null,
    ];

    for (final candidate in candidates) {
      if (candidate == null) continue;
      final parsed = int.tryParse(candidate.toString());
      if (parsed != null) return parsed;
    }

    return null;
  }

  bool _extractHasMore(Map<String, dynamic> map, int fetchedCount) {
    final pagination = map['pagination'];
    if (pagination is Map) {
      final totalPages = int.tryParse(
        pagination['totalPages']?.toString() ?? '',
      );
      final currentPageValue = int.tryParse(
        pagination['currentPage']?.toString() ?? '',
      );
      if (totalPages != null && currentPageValue != null) {
        return currentPageValue < totalPages;
      }

      final hasNextPage = pagination['hasNextPage'];
      if (hasNextPage is bool) return hasNextPage;
      if (hasNextPage != null) {
        return hasNextPage.toString().toLowerCase() == 'true';
      }
    }

    final meta = map['meta'];
    if (meta is Map) {
      final hasMore = meta['hasMore'];
      if (hasMore is bool) return hasMore;
      if (hasMore != null) {
        return hasMore.toString().toLowerCase() == 'true';
      }
    }

    return fetchedCount >= _pageSize;
  }

  Map<String, dynamic> _asMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String) {
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    return <String, dynamic>{};
  }
}
