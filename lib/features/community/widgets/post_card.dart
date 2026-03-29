import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(post.author),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (onEdit != null)
                            GestureDetector(
                              onTap: onEdit,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFE39D41)),
                              ),
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (post.courseName != null && post.courseName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          post.courseName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE39D41),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      if (post.image != null && post.image!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.image!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(AuthorModel author) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF6A7554),
        shape: BoxShape.circle,
        image: author.profilePicture != null
            ? DecorationImage(
                image: NetworkImage(author.profilePicture!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: author.profilePicture == null
          ? Text(
              author.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onLikeToggle,
              child: Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: post.isLiked ? Colors.red : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${post.likesCount}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              '${post.repliesCount} replies',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        Text(
          DateFormat('dd MMM').format(post.createdAt),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}
