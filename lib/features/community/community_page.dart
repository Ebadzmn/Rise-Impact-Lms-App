import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/notification_badge_icon.dart';
import '../../routes/app_routes.dart';
import '../profile/profile_controller.dart';
import 'controllers/community_controller.dart';
import 'widgets/post_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Community',
          showBackButton: true,
          onBackCallback: () => context.go(AppRoutes.home),
          actions: [_buildNotificationIcon(context), const SizedBox(width: 8)],
        ),
      ),
      body: Column(
        children: [
          _buildActionButtons(context),
          _buildCourseFilter(),
          Expanded(
            child: GetBuilder<CommunityController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return _buildShimmerList();
                }
                if (controller.posts.isEmpty) {
                  return _buildEmptyState();
                }

                String currentUserId = '';
                if (Get.isRegistered<ProfileController>()) {
                  final profileController = Get.find<ProfileController>();
                  currentUserId = profileController.profileData.value?.id ?? '';
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchPosts(isRefresh: true),
                  color: const Color(0xFFE39D41),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount:
                        controller.posts.length +
                        (controller.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.posts.length) {
                        return _buildLoadMoreLoader();
                      }
                      final post = controller.posts[index];
                      final isOwnPost = post.author.id == currentUserId;

                      return PostCard(
                        post: post,
                        onTap: () =>
                            context.push('/community/post-details/${post.id}'),
                        onLikeToggle: () => controller.toggleLike(post.id),
                        onEdit: isOwnPost
                            ? () => context.push(
                                '/community/edit-post',
                                extra: post,
                              )
                            : null,
                        onDelete: isOwnPost
                            ? () => _showDeleteDialog(
                                context,
                                onConfirm: () => controller.deletePost(post.id),
                              )
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post?',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.createPost),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE39D41),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE39D41).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create a post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.myPosts),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF576045),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'My post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseFilter() {
    return GetBuilder<CommunityController>(
      builder: (controller) {
        if (controller.courseOptions.isEmpty) return const SizedBox();
        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.courseOptions.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isSelected = isAll
                  ? controller.selectedCourseId == null
                  : controller.selectedCourseId ==
                        controller.courseOptions[index - 1].id;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: FilterChip(
                  label: Text(
                    isAll ? 'All' : controller.courseOptions[index - 1].title,
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    controller.filterByCourse(
                      isAll ? null : controller.courseOptions[index - 1].id,
                    );
                  },
                  selectedColor: const Color(0xFF869277),
                  disabledColor: Colors.white,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade200,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No posts available',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFE39D41),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return NotificationBadgeIcon(
      onTap: () => context.push(AppRoutes.notifications),
      iconColor: const Color(0xFF2C3E50),
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(8),
      useCircularBackground: false,
    );
  }
}
