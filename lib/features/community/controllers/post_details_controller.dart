import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_interceptor.dart';
import '../models/post_model.dart';
import 'community_controller.dart';
import 'my_posts_controller.dart';

class PostDetailsController extends GetxController {
  final String postId;
  final Rx<PostDetailsModel?> post = Rx<PostDetailsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isLiking = false.obs;
  final RxBool isReplying = false.obs;
  final RxBool isUpdatingReply = false.obs;
  final RxBool isDeletingPost = false.obs;
  final RxBool isDeletingReply = false.obs;
  final RxString editingReplyId = ''.obs;
  
  final TextEditingController replyController = TextEditingController();
  final FocusNode replyFocusNode = FocusNode();
  final Rx<ReplyModel?> selectedParentReply = Rx<ReplyModel?>(null);
  final TextEditingController editReplyController = TextEditingController();

  PostDetailsController({required this.postId});

  @override
  void onInit() {
    super.onInit();
    fetchPostDetails();
  }

  @override
  void onClose() {
    replyController.dispose();
    replyFocusNode.dispose();
    editReplyController.dispose();
    super.onClose();
  }

  void startEditing(ReplyModel reply) {
    editingReplyId.value = reply.id;
    editReplyController.text = reply.content;
  }

  void cancelEditing() {
    editingReplyId.value = '';
    editReplyController.clear();
  }

  void setReplyingTo(ReplyModel? reply) {
    selectedParentReply.value = reply;
    replyFocusNode.requestFocus();
  }

  void clearReplyingTo() {
    selectedParentReply.value = null;
  }

  Future<void> fetchPostDetails() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.communityPostDetails(postId));

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? {};
        post.value = PostDetailsModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Fetch Post Details Error: $e');
      Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to load post details', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike() async {
    if (post.value == null || isLiking.value) return;

    final currentPost = post.value!;
    final originalIsLiked = currentPost.isLiked;
    final originalLikesCount = currentPost.likesCount;

    // Optimistic Update
    post.value = PostDetailsModel(
      id: currentPost.id,
      title: currentPost.title,
      content: currentPost.content,
      image: currentPost.image,
      author: currentPost.author,
      likesCount: originalIsLiked ? originalLikesCount - 1 : originalLikesCount + 1,
      repliesCount: currentPost.repliesCount,
      isLiked: !originalIsLiked,
      createdAt: currentPost.createdAt,
      replies: currentPost.replies,
    );

    try {
      isLiking.value = true;
      final response = await ApiClient.instance.patch(ApiEndpoints.toggleLike(postId));
      if (response.statusCode != 200) throw Exception('Failed to toggle like');
    } catch (e) {
      debugPrint('Toggle Like Error: $e');
      // Revert
      post.value = PostDetailsModel(
        id: currentPost.id,
        title: currentPost.title,
        content: currentPost.content,
        image: currentPost.image,
        author: currentPost.author,
        likesCount: originalLikesCount,
        repliesCount: currentPost.repliesCount,
        isLiked: originalIsLiked,
        createdAt: currentPost.createdAt,
        replies: currentPost.replies,
      );
      Get.snackbar('Error', 'Failed to toggle like', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLiking.value = false;
    }
  }

  Future<void> addReply({required String content, String? parentReplyId}) async {
    if (isReplying.value || content.trim().isEmpty) return;

    try {
      isReplying.value = true;
      final response = await ApiClient.instance.post(
        ApiEndpoints.addReply(postId),
        body: {
          'content': content,
          if (parentReplyId != null) 'parentReplyId': parentReplyId,
        },
      );

      if (response.statusCode == 201) {
        final newReply = ReplyModel.fromJson(response.data['data']);
        
        final currentPost = post.value!;
        List<ReplyModel> updatedReplies = List.from(currentPost.replies);

        if (parentReplyId == null) {
          updatedReplies.add(newReply);
        } else {
          final parentIndex = updatedReplies.indexWhere((r) => r.id == parentReplyId);
          if (parentIndex != -1) {
            final parent = updatedReplies[parentIndex];
            List<ReplyModel> updatedChildren = List.from(parent.children);
            updatedChildren.add(newReply);
            
            updatedReplies[parentIndex] = ReplyModel(
              id: parent.id,
              content: parent.content,
              author: parent.author,
              createdAt: parent.createdAt,
              children: updatedChildren,
            );
          }
        }

        post.value = PostDetailsModel(
          id: currentPost.id,
          title: currentPost.title,
          content: currentPost.content,
          image: currentPost.image,
          author: currentPost.author,
          likesCount: currentPost.likesCount,
          repliesCount: currentPost.repliesCount + 1,
          isLiked: currentPost.isLiked,
          createdAt: currentPost.createdAt,
          replies: updatedReplies,
        );
      }
    } catch (e) {
      debugPrint('Add Reply Error: $e');
      Get.snackbar('Error', 'Failed to add reply', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isReplying.value = false;
    }
  }

  Future<void> updateReply(String replyId) async {
    final newContent = editReplyController.text.trim();
    if (newContent.isEmpty || isUpdatingReply.value) return;

    try {
      isUpdatingReply.value = true;
      final response = await ApiClient.instance.patch(
        ApiEndpoints.editReply(replyId),
        body: {'content': newContent},
      );

      if (response.statusCode == 200) {
        final currentPost = post.value!;
        List<ReplyModel> updatedReplies = List.from(currentPost.replies);

        bool findAndUpdate(List<ReplyModel> list) {
          for (int i = 0; i < list.length; i++) {
            if (list[i].id == replyId) {
              list[i] = ReplyModel(
                id: list[i].id,
                content: newContent,
                author: list[i].author,
                createdAt: list[i].createdAt,
                children: list[i].children,
              );
              return true;
            }
            if (findAndUpdate(list[i].children)) return true;
          }
          return false;
        }

        findAndUpdate(updatedReplies);

        post.value = PostDetailsModel(
          id: currentPost.id,
          title: currentPost.title,
          content: currentPost.content,
          image: currentPost.image,
          author: currentPost.author,
          likesCount: currentPost.likesCount,
          repliesCount: currentPost.repliesCount,
          isLiked: currentPost.isLiked,
          createdAt: currentPost.createdAt,
          replies: updatedReplies,
        );

        cancelEditing();
        Get.snackbar('Success', 'Reply updated successfully',
          backgroundColor: const Color(0xFF576045), colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Update Reply Error: $e');
      Get.snackbar('Error', 'Failed to update reply', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isUpdatingReply.value = false;
    }
  }

  Future<void> deletePost() async {
    if (isDeletingPost.value) return;

    try {
      isDeletingPost.value = true;
      final response = await ApiClient.instance.delete(ApiEndpoints.deletePost(postId));
      
      if (response.statusCode == 200) {
        // Notify other controllers if they exist
        if (Get.isRegistered<CommunityController>()) {
          Get.find<CommunityController>().posts.removeWhere((p) => p.id == postId);
          Get.find<CommunityController>().update();
        }
        if (Get.isRegistered<MyPostsController>()) {
          Get.find<MyPostsController>().posts.removeWhere((p) => p.id == postId);
          Get.find<MyPostsController>().update();
        }

        Get.back(); // Go back to list
        Get.snackbar('Success', 'Post deleted successfully',
          backgroundColor: const Color(0xFF576045), colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Delete Post Error: $e');
      Get.snackbar('Error', 'Failed to delete post', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isDeletingPost.value = false;
    }
  }

  Future<void> deleteReply(String replyId) async {
    if (isDeletingReply.value) return;

    try {
      isDeletingReply.value = true;
      final response = await ApiClient.instance.delete(ApiEndpoints.deleteReply(replyId));

      if (response.statusCode == 200) {
        final currentPost = post.value!;
        List<ReplyModel> updatedReplies = List.from(currentPost.replies);

        bool findAndDelete(List<ReplyModel> list) {
          for (int i = 0; i < list.length; i++) {
            if (list[i].id == replyId) {
              list.removeAt(i);
              return true;
            }
            if (findAndDelete(list[i].children)) return true;
          }
          return false;
        }

        if (findAndDelete(updatedReplies)) {
          post.value = PostDetailsModel(
            id: currentPost.id,
            title: currentPost.title,
            content: currentPost.content,
            image: currentPost.image,
            author: currentPost.author,
            likesCount: currentPost.likesCount,
            repliesCount: (currentPost.repliesCount - 1).clamp(0, 99999),
            isLiked: currentPost.isLiked,
            createdAt: currentPost.createdAt,
            replies: updatedReplies,
          );
          
          Get.snackbar('Success', 'Reply deleted successfully',
            backgroundColor: const Color(0xFF576045), colorText: Colors.white);
        }
      }
    } catch (e) {
      debugPrint('Delete Reply Error: $e');
      Get.snackbar('Error', 'Failed to delete reply', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isDeletingReply.value = false;
    }
  }
}
