import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _searchQuery = '';
  bool _showSearch = false;

  // Demo posts with mutable state
  late final List<_PostData> _posts = [
    _PostData(
      username: 'Sarah M.',
      timeAgo: '2h ago',
      group: 'Due Oct 2026',
      text: 'Just had my glucose test today! Wasn\'t as bad as I expected. The orange drink is... interesting. Anyone else done theirs yet?',
      likes: 24,
      comments: 18,
    ),
    _PostData(
      username: 'Dr. Amara K.',
      timeAgo: '5h ago',
      group: 'Ask a Doctor',
      text: 'Reminder: Iron-rich foods are especially important in the second trimester. Pair them with vitamin C for better absorption!',
      likes: 89,
      comments: 12,
      isVerified: true,
    ),
    _PostData(
      username: 'Mike T.',
      timeAgo: '8h ago',
      group: 'Dads Corner',
      text: 'My wife is 30 weeks and I want to be more involved. What are things I can do to help at this stage? First time dad here.',
      likes: 45,
      comments: 32,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _searchQuery.isEmpty
        ? _posts
        : _posts.where((p) =>
            p.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.group.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: L.of(context).searchCommunity,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(L.of(context).community),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreatePost(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // My groups
          Text(L.of(context).myGroups, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _GroupChip(name: 'Due Oct 2026', icon: Icons.pregnant_woman, color: AppColors.primary, members: 1243),
                _GroupChip(name: 'First-Time Moms', icon: Icons.child_care, color: AppColors.secondary, members: 8521),
                _GroupChip(name: 'Working Parents', icon: Icons.work_outline, color: AppColors.accent, members: 3102),
                _GroupChip(name: 'Dads Corner', icon: Icons.man, color: AppColors.stagePrePregnancy, members: 2450),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(L.of(context).recentPosts, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (filteredPosts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  L.of(context).noPostsFound,
                  style: TextStyle(color: AppColors.textHint),
                ),
              ),
            )
          else
            ...filteredPosts.map((post) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PostCard(
                    post: post,
                    onLike: () => setState(() => post.isLiked ? post.unlike() : post.like()),
                    onComment: () => _showComments(context, post),
                    onBookmark: () => setState(() => post.isBookmarked = !post.isBookmarked),
                    onMore: () => _showPostOptions(context, post),
                  ),
                )),
        ],
      ),
    );
  }

  void _showCreatePost(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L.of(context).createPost, style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              autofocus: true,
              decoration: InputDecoration(
                hintText: L.of(context).whatsOnYourMind,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  setState(() {
                    _posts.insert(0, _PostData(
                      username: 'You',
                      timeAgo: 'Just now',
                      group: 'Due Oct 2026',
                      text: controller.text.trim(),
                      likes: 0,
                      comments: 0,
                    ));
                  });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(L.of(context).postPublished), behavior: SnackBarBehavior.floating),
                  );
                },
                child: Text(L.of(context).post),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context, _PostData post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final controller = TextEditingController();
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${L.of(context).commentsTitle} (${post.comments})', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(L.of(context).commentsPlaceholder, style: TextStyle(color: AppColors.textHint)),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: L.of(context).writeComment,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        setState(() => post.comments++);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(L.of(context).commentPosted), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, _PostData post) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(L.of(context).reportPost),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(L.of(context).postReported), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            if (post.username == 'You')
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(L.of(context).deletePost, style: const TextStyle(color: AppColors.error)),
                onTap: () {
                  setState(() => _posts.remove(post));
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PostData {
  final String username;
  final String timeAgo;
  final String group;
  final String text;
  int likes;
  int comments;
  final bool isVerified;
  bool isLiked;
  bool isBookmarked;

  _PostData({
    required this.username,
    required this.timeAgo,
    required this.group,
    required this.text,
    required this.likes,
    required this.comments,
    this.isVerified = false,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  void like() {
    isLiked = true;
    likes++;
  }

  void unlike() {
    isLiked = false;
    likes--;
  }
}

class _GroupChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int members;

  const _GroupChip({required this.name, required this.icon, required this.color, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('$members ${L.of(context).members}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final _PostData post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onMore;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(post.username[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (post.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                          ],
                        ],
                      ),
                      Text('${post.group} · ${post.timeAgo}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_horiz, color: AppColors.textHint), onPressed: onMore),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.text, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: post.isLiked ? AppColors.error : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likes}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onComment,
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${post.comments}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onBookmark,
                  child: Icon(
                    post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: post.isBookmarked ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
