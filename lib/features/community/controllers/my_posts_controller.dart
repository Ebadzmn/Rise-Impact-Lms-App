import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_interceptor.dart';
import '../models/post_model.dart';
import '../models/course_option_model.dart';

class MyPostsController extends GetxController {
  // ✅ Plain variables — NO Rx
  List<PostModel> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  int totalPage = 1;
  String? selectedCourseId;
  List<CourseOptionModel> courseOptions = [];

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _fetchCourseOptions();
    fetchMyPosts();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoadingMore || currentPage >= totalPage) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      _fetchMorePosts();
    }
  }

  Future<void> _fetchCourseOptions() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.courseOptions);
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        courseOptions = data.map((e) => CourseOptionModel.fromJson(e)).toList();
        update();
      }
    } catch (e) {
      debugPrint('Fetch Course Options Error: $e');
    }
  }

  Future<void> fetchMyPosts({bool isRefresh = false}) async {
    isLoading = true;
    currentPage = 1;
    totalPage = 1;
    if (isRefresh) posts.clear();
    update();

    try {
      String url = '${ApiEndpoints.myPosts}?page=$currentPage&limit=10&sort=-createdAt';
      if (selectedCourseId != null) {
        url += '&courseId=$selectedCourseId';
      }

      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        totalPage = response.data['pagination']?['totalPage'] ?? 1;

        if (isRefresh) posts.clear();
        posts = data.map((e) => PostModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch My Posts Error: $e');
      Get.snackbar('Error', e is NetworkException ? e.message : 'Failed to load posts',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _fetchMorePosts() async {
    if (isLoadingMore || currentPage >= totalPage) return;

    isLoadingMore = true;
    update();

    try {
      final nextPage = currentPage + 1;
      String url = '${ApiEndpoints.myPosts}?page=$nextPage&limit=10&sort=-createdAt';
      if (selectedCourseId != null) {
        url += '&courseId=$selectedCourseId';
      }

      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final newPosts = data.map((e) => PostModel.fromJson(e)).toList();
        posts.addAll(newPosts);
        currentPage = nextPage;
      }
    } catch (e) {
      debugPrint('Fetch More Posts Error: $e');
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  void filterByCourse(String? courseId) {
    if (selectedCourseId == courseId) return;
    selectedCourseId = courseId;
    fetchMyPosts(isRefresh: true);
  }

  Future<void> toggleLike(String postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];
    final originalIsLiked = post.isLiked;
    final originalLikesCount = post.likesCount;

    // Optimistic Update
    posts[index] = PostModel(
      id: post.id,
      title: post.title,
      content: post.content,
      image: post.image,
      author: post.author,
      courseName: post.courseName,
      likesCount: originalIsLiked ? originalLikesCount - 1 : originalLikesCount + 1,
      repliesCount: post.repliesCount,
      isLiked: !originalIsLiked,
      createdAt: post.createdAt,
    );
    update();

    try {
      final response = await ApiClient.instance.patch(ApiEndpoints.toggleLike(postId));
      if (response.statusCode != 200) {
        throw Exception('Failed to toggle like');
      }
    } catch (e) {
      debugPrint('Toggle Like Error: $e');
      // Revert on error
      posts[index] = PostModel(
        id: post.id,
        title: post.title,
        content: post.content,
        image: post.image,
        author: post.author,
        courseName: post.courseName,
        likesCount: originalLikesCount,
        repliesCount: post.repliesCount,
        isLiked: originalIsLiked,
        createdAt: post.createdAt,
      );
      update();
      Get.snackbar('Error', 'Failed to toggle like', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> deletePost(String id) async {
    try {
      final response = await ApiClient.instance.delete(ApiEndpoints.deletePost(id));
      if (response.statusCode == 200) {
        posts.removeWhere((p) => p.id == id);
        update(); // Trigger UI rebuild
        Get.snackbar('Success', 'Post deleted successfully',
            backgroundColor: const Color(0xFF576045), colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Delete Post Error: $e');
      Get.snackbar('Error', 'Failed to delete post',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
