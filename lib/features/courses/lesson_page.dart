import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';
import '../../data/models/lesson_detail_model.dart';
import 'lesson_controller.dart';

class LessonPage extends StatelessWidget {
  final String courseId;
  final String lessonId;
  final String? courseSlug;

  const LessonPage({
    super.key,
    required this.courseId,
    required this.lessonId,
    this.courseSlug,
  });

  @override
  Widget build(BuildContext context) {
    // Unique tag for controller instance
    final controller = Get.find<LessonController>(
      tag: '${courseId}_${lessonId}',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(
          () => Text(controller.lessonData.value?.title ?? 'Lesson Content'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final lesson = controller.lessonData.value;
        if (lesson == null) {
          return const Center(child: Text('Lesson not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContentHeader(lesson),
              const Divider(),
              _buildLessonContent(context, controller, lesson),
              _buildObjectives(lesson),
              _buildAttachments(lesson),
              const SizedBox(height: 100), // Space for action button
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        final lesson = controller.lessonData.value;
        if (lesson == null || controller.isLoading.value)
          return const SizedBox.shrink();

        return _buildActionSection(context, controller, lesson);
      }),
    );
  }

  Widget _buildContentHeader(LessonDetailModel lesson) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(
    BuildContext context,
    LessonController controller,
    LessonDetailModel lesson,
  ) {
    switch (lesson.type.toUpperCase()) {
      case 'VIDEO':
        return _buildVideoPlayer(lesson);
      case 'READING':
        return _buildReadingContent(lesson);
      case 'QUIZ':
        return _buildQuizContent(context, lesson);
      default:
        return _buildReadingContent(lesson);
    }
  }

  Widget _buildVideoPlayer(LessonDetailModel lesson) {
    final videoUrl = lesson.video?.url?.trim() ?? '';

    if (videoUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Video URL unavailable in API response',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: LessonVideoPlayer(videoUrl: videoUrl),
    );
  }

  Widget _buildReadingContent(LessonDetailModel lesson) {
    final readingText = lesson.readingContent?.trim() ?? '';
    final contentFile = lesson.contentFile;
    final hasReadingText = readingText.isNotEmpty;
    final hasContentFile =
        contentFile != null && contentFile.url.trim().isNotEmpty;

    if (!hasReadingText && !hasContentFile) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No content available.',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReadingText)
            HtmlWidget(
              readingText,
              textStyle: const TextStyle(fontSize: 16, height: 1.6),
            ),
          if (hasReadingText && hasContentFile) const SizedBox(height: 20),
          if (hasContentFile) _buildReadingFileCard(contentFile),
        ],
      ),
    );
  }

  Widget _buildReadingFileCard(LessonContentFile file) {
    final rawName = file.name.trim();
    final fileName = rawName.isNotEmpty
        ? rawName
        : (file.url.split('/').isNotEmpty
              ? file.url.split('/').last
              : 'Reading material.pdf');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F3EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6D6C4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_outlined,
            color: Color(0xFFD88B2F),
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PDF Reading Material',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: () => _downloadAndOpenAttachment(
              AttachmentModel(title: fileName, url: file.url),
            ),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, LessonDetailModel lesson) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F3EB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE6D6C4)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Color(0xFFD88B2F),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lesson Quiz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your knowledge on this topic!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (lesson.quiz?.quizId != null) {
                  // Ensure fresh controller state before entering
                  try {
                    Get.delete(tag: lesson.quiz!.quizId, force: true);
                  } catch (_) {}

                  context.pushNamed(
                    AppRoutes.quiz,
                    pathParameters: {'id': lesson.quiz!.quizId},
                    queryParameters: {
                      'courseId': courseId,
                      'lessonId': lessonId,
                      if (courseSlug != null && courseSlug!.isNotEmpty) 'slug': courseSlug!,
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD88B2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectives(LessonDetailModel lesson) {
    if (lesson.learningObjectives.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Objectives',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...lesson.learningObjectives.map(
            (obj) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Color(0xFF6A7554),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(obj, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(LessonDetailModel lesson) {
    if (lesson.attachments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attachments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...lesson.attachments.map(
            (file) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.file_present_outlined,
                color: Colors.blue,
              ),
              title: Text(
                file.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.download_outlined),
              onTap: () => _downloadAndOpenAttachment(file),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpenAttachment(AttachmentModel file) async {
    final candidateUris = _resolveResourceUris(file.url);
    if (candidateUris.isEmpty) {
      Get.snackbar('Error', 'Invalid attachment URL');
      return;
    }

    Get.snackbar('Downloading', 'Preparing attachment...');

    try {
      final token = Get.find<StorageService>().getToken();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final fileName = _buildDownloadFileName(file.title, candidateUris.first);
      final savePath = '${docsDir.path}/$fileName';
      Object? lastDownloadError;
      var downloaded = false;

      for (final uri in candidateUris) {
        try {
          await Dio().downloadUri(
            uri,
            savePath,
            options: Options(headers: headers),
          );
          downloaded = true;
          break;
        } catch (error) {
          lastDownloadError = error;
          debugPrint('Attachment download failed for $uri -> $error');
        }
      }

      if (!downloaded) {
        for (final uri in candidateUris) {
          final opened = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (opened) return;
        }
        throw lastDownloadError ?? Exception('Failed to download attachment');
      }

      final result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done) {
        var fallbackOpened = false;
        for (final uri in candidateUris) {
          fallbackOpened = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (fallbackOpened) break;
        }
        if (!fallbackOpened) {
          Get.snackbar('Success', 'File downloaded: $fileName');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to download attachment');
      debugPrint('Attachment download/open error: $e');
    }
  }

  List<Uri> _resolveResourceUris(String rawUrl) {
    final uri = _resolveResourceUri(rawUrl);
    if (uri == null) return const [];

    final candidates = <Uri>[uri];
    final httpsUri = _forceHttps(uri);
    if (httpsUri != uri) {
      candidates.add(httpsUri);
    }

    return candidates.toSet().toList();
  }

  Uri? _resolveResourceUri(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;

    final apiBase = Uri.tryParse(ApiEndpoints.baseUrl);
    if (apiBase == null) return null;
    final origin = Uri(
      scheme: apiBase.scheme,
      host: apiBase.host,
      port: apiBase.hasPort ? apiBase.port : null,
    );

    if (trimmed.startsWith('/')) {
      return origin.resolve(trimmed);
    }

    return origin.resolve('/$trimmed');
  }

  Uri _forceHttps(Uri uri) {
    if (uri.scheme.toLowerCase() == 'http') {
      final int? securePort;
      if (!uri.hasPort || uri.port == 80 || uri.port == 443) {
        securePort = null;
      } else {
        securePort = uri.port;
      }

      return uri.replace(scheme: 'https', port: securePort);
    }
    return uri;
  }

  String _buildDownloadFileName(String title, Uri uri) {
    final rawName = title.trim().isNotEmpty
        ? title.trim()
        : uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'attachment';
    final safeName = rawName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    final hasExtension =
        safeName.contains('.') && safeName.split('.').last.isNotEmpty;
    if (hasExtension) {
      return '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    }

    final uriExt =
        uri.pathSegments.isNotEmpty && uri.pathSegments.last.contains('.')
        ? '.${uri.pathSegments.last.split('.').last}'
        : '.pdf';
    return '${DateTime.now().millisecondsSinceEpoch}_${safeName}$uriExt';
  }

  Widget _buildActionSection(
    BuildContext context,
    LessonController controller,
    LessonDetailModel lesson,
  ) {
    if (lesson.type.toUpperCase() == 'QUIZ') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isCompleting.value
                ? null
                : () => controller.markAsComplete(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A7554),
              disabledBackgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: controller.isCompleting.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Mark Complete',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

class LessonVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const LessonVideoPlayer({super.key, required this.videoUrl});

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  String? _playerError;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant LessonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initPlayer();
    }
  }

  void _initPlayer() {
    _playerError = null;
    _isInitializing = true;
    final uri = _resolveVideoUri(widget.videoUrl);
    if (uri == null) {
      _playerError = 'Invalid video URL';
      _isInitializing = false;
      return;
    }
    debugPrint('LessonVideoPlayer URL: $uri');

    // video_player cannot play normal YouTube watch/share pages directly.
    if (_isYouTubePageUri(uri)) {
      _playerError = 'YouTube page link is not directly playable.';
      _isInitializing = false;
      return;
    }

    final headers = <String, String>{};
    try {
      final token = Get.find<StorageService>().getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Storage service unavailable; continue without auth headers.
    }

    final candidateUris = <Uri>[uri];
    final httpsUri = _forceHttps(uri);
    if (httpsUri != uri) {
      candidateUris.add(httpsUri);
    }

    _initializeFuture = _initializeWithFallback(candidateUris, headers);
  }

  Future<void> _initializeWithFallback(
    List<Uri> uris,
    Map<String, String> headers,
  ) async {
    Object? lastError;

    for (final uri in uris.toSet()) {
      final controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: headers,
      );

      try {
        await controller.initialize();
        await controller.setLooping(false);
        await controller.setPlaybackSpeed(1.0);
        await controller.play();
        _controller = controller;
        _isInitializing = false;
        if (mounted) setState(() {});
        return;
      } catch (error) {
        lastError = error;
        debugPrint('LessonVideoPlayer init failed for $uri -> $error');
        await controller.dispose();
      }
    }

    _playerError = lastError?.toString() ?? 'Failed to load video';
    _isInitializing = false;
    if (mounted) setState(() {});
  }

  Uri? _resolveVideoUri(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;

    // Convert relative media path to absolute URL using API origin.
    final apiBase = Uri.tryParse(ApiEndpoints.baseUrl);
    if (apiBase == null) return null;
    final origin = Uri(
      scheme: apiBase.scheme,
      host: apiBase.host,
      port: apiBase.hasPort ? apiBase.port : null,
    );

    if (trimmed.startsWith('/')) {
      return origin.resolve(trimmed);
    }

    return origin.resolve('/$trimmed');
  }

  bool _isYouTubePageUri(Uri uri) {
    final host = uri.host.toLowerCase();
    return host.contains('youtube.com') || host.contains('youtu.be');
  }

  Uri _forceHttps(Uri uri) {
    if (uri.scheme.toLowerCase() == 'http') {
      final int? securePort;
      if (!uri.hasPort || uri.port == 80 || uri.port == 443) {
        securePort = null;
      } else {
        securePort = uri.port;
      }

      return uri.replace(scheme: 'https', port: securePort);
    }
    return uri;
  }

  void _disposeController() {
    final c = _controller;
    _controller = null;
    _initializeFuture = null;
    c?.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initializeFuture = _initializeFuture;

    if (_isInitializing) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (controller == null || initializeFuture == null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            _playerError ?? 'Invalid video URL',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return FutureBuilder<void>(
      future: initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError || !controller.value.isInitialized) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                _playerError ?? 'Failed to load video',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            Container(
              height: 56,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFFD88B2F),
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
