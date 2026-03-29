import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../profile/profile_controller.dart';
import 'controllers/post_details_controller.dart';
import 'models/post_model.dart';

class PostDetailsPage extends GetView<PostDetailsController> {
  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Discussion',
          showBackButton: true,
          actions: [_buildNotificationIcon()],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerDetails();
        }
        final post = controller.post.value;
        if (post == null) {
          return const Center(child: Text('Post not found'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOriginalPostCard(post),
                    const SizedBox(height: 24),
                    Text(
                      '${post.repliesCount} Replies',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 16),
                    ...post.replies.map((reply) => _buildNestedReply(reply)).toList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildReplyInput(),
          ],
        );
      }),
    );
  }

  Widget _buildNestedReply(ReplyModel reply) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReplyCard(reply, isParent: true),
        if (reply.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 8),
            child: Column(
              children: reply.children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildReplyCard(child, isParent: false),
              )).toList(),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildReplyCard(ReplyModel reply, {required bool isParent}) {
    String currentUserId = '';
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      currentUserId = profileController.profileData.value?.id ?? '';
    }
    final isOwnReply = reply.author.id == currentUserId;

    return Obx(() {
      final isEditing = controller.editingReplyId.value == reply.id;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isParent ? Colors.white : const Color(0xFFF9FBF6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isParent ? Colors.grey.shade100 : const Color(0xFFE8F0DC)),
          boxShadow: isParent ? [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSimpleAvatar(reply.author, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply.author.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50))),
                      Text(DateFormat('dd MMM hh:mm a').format(reply.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                if (!isEditing && isOwnReply) ...[
                   IconButton(
                    onPressed: () => controller.startEditing(reply),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFE39D41)),
                    visualDensity: VisualDensity.compact,
                  ),
                   IconButton(
                    onPressed: () => _showDeleteDialog(
                      title: 'Delete Reply',
                      message: 'Are you sure you want to delete this reply?',
                      onConfirm: () => controller.deleteReply(reply.id),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                if (isParent && !isEditing)
                  TextButton(
                    onPressed: () => controller.setReplyingTo(reply),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFFE39D41),
                    ),
                    child: const Text('Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isEditing)
              Column(
                children: [
                  TextField(
                    controller: controller.editReplyController,
                    maxLines: null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => controller.cancelEditing(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => ElevatedButton(
                        onPressed: controller.isUpdatingReply.value 
                          ? null 
                          : () => controller.updateReply(reply.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE39D41),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          minimumSize: const Size(60, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: controller.isUpdatingReply.value 
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                ],
              )
            else
              Text(reply.content, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
          ],
        ),
      );
    });
  }

  Widget _buildOriginalPostCard(PostDetailsModel post) {
    String currentUserId = '';
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      currentUserId = profileController.profileData.value?.id ?? '';
    }
    final isOwnPost = post.author.id == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSimpleAvatar(post.author, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.author.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))),
                  Text('Posted on ${DateFormat('dd MMM').format(post.createdAt)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (isOwnPost)
              IconButton(
                onPressed: () => _showDeleteDialog(
                  title: 'Delete Post',
                  message: 'Are you sure you want to delete this post?',
                  onConfirm: () => controller.deletePost(),
                ),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), height: 1.3)),
        const SizedBox(height: 12),
        Text(post.content, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6)),
        if (post.image != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(post.image!, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => controller.toggleLike(),
          child: Row(
            children: [
              Icon(
                post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, 
                size: 20, 
                color: const Color(0xFFE39D41)
              ),
              const SizedBox(width: 8),
              Text('${post.likesCount} upvotes', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50), fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        content: Text(message, style: TextStyle(color: Colors.grey.shade600)),
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

  Widget _buildSimpleAvatar(AuthorModel author, {double size = 40}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF6A7554),
        shape: BoxShape.circle,
        image: author.profilePicture != null ? DecorationImage(image: NetworkImage(author.profilePicture!), fit: BoxFit.cover) : null,
      ),
      alignment: Alignment.center,
      child: author.profilePicture == null ? Text(author.name[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * 0.4)) : null,
    );
  }

  Widget _buildShimmerDetails() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 50, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 40),
            ...List.generate(3, (index) => Container(margin: const EdgeInsets.only(bottom: 20), height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Obx(() {
      final replyingTo = controller.selectedParentReply.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Replying to ${replyingTo.author.name}', 
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.clearReplyingTo(),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
                    child: TextField(
                      controller: controller.replyController,
                      focusNode: controller.replyFocusNode,
                      decoration: const InputDecoration(hintText: 'Share your thoughts...', hintStyle: TextStyle(fontSize: 14), border: InputBorder.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                controller.isReplying.value 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE39D41)))
                  : CircleAvatar(
                      backgroundColor: const Color(0xFFE39D41),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18), 
                        onPressed: () {
                          controller.addReply(
                            content: controller.replyController.text,
                            parentReplyId: replyingTo?.id,
                          ).then((_) {
                            controller.replyController.clear();
                            controller.clearReplyingTo();
                          });
                        }
                      ),
                    ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotificationIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2C3E50)), onPressed: () {}),
    );
  }
}
