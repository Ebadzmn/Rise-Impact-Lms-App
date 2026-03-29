import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'controllers/my_posts_controller.dart';
import 'widgets/post_card.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'My Posts',
          showBackButton: true,
        ),
      ),
      body: Column(
        children: [
          _buildCourseFilter(),
          Expanded(
            child: GetBuilder<MyPostsController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return _buildShimmerList();
                }
                if (controller.posts.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () => controller.fetchMyPosts(isRefresh: true),
                  color: const Color(0xFFE39D41),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: controller.posts.length +
                        (controller.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.posts.length) {
                        return _buildLoadMoreLoader();
                      }
                      final post = controller.posts[index];
                      return PostCard(
                        post: post,
                        onTap: () => context
                            .push('/community/post-details/${post.id}'),
                        onLikeToggle: () => controller.toggleLike(post.id),
                        onEdit: () => context.push('/community/edit-post', extra: post),
                        onDelete: () => _showDeleteDialog(
                          context,
                          onConfirm: () => controller.deletePost(post.id),
                        ),
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

  void _showDeleteDialog(BuildContext context, {required VoidCallback onConfirm}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        content: Text('Are you sure you want to delete this post?', style: TextStyle(color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseFilter() {
    return GetBuilder<MyPostsController>(
      builder: (controller) {
        if (controller.courseOptions.isEmpty) return const SizedBox();
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: FilterChip(
                  label: Text(isAll
                      ? 'All'
                      : controller.courseOptions[index - 1].title),
                  selected: isSelected,
                  onSelected: (val) {
                    controller.filterByCourse(
                        isAll ? null : controller.courseOptions[index - 1].id);
                  },
                  selectedColor: const Color(0xFF869277),
                  disabledColor: Colors.white,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade200),
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
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'You haven\'t posted anything yet',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500),
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
              strokeWidth: 2, color: Color(0xFFE39D41)),
        ),
      ),
    );
  }
}
