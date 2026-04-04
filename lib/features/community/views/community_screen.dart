import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // My groups
          Text('My Groups', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _GroupChip(
                  name: 'Due Oct 2026',
                  icon: Icons.pregnant_woman,
                  color: AppColors.primary,
                  members: 1243,
                ),
                _GroupChip(
                  name: 'First-Time Moms',
                  icon: Icons.child_care,
                  color: AppColors.secondary,
                  members: 8521,
                ),
                _GroupChip(
                  name: 'Working Parents',
                  icon: Icons.work_outline,
                  color: AppColors.accent,
                  members: 3102,
                ),
                _GroupChip(
                  name: 'Dads Corner',
                  icon: Icons.man,
                  color: AppColors.stagePrePregnancy,
                  members: 2450,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feed
          Text('Recent Posts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const _PostCard(
            username: 'Sarah M.',
            timeAgo: '2h ago',
            group: 'Due Oct 2026',
            text:
                'Just had my glucose test today! Wasn\'t as bad as I expected. The orange drink is... interesting 😅 Anyone else done theirs yet?',
            likes: 24,
            comments: 18,
          ),
          const SizedBox(height: 12),
          const _PostCard(
            username: 'Dr. Amara K.',
            timeAgo: '5h ago',
            group: 'Ask a Doctor',
            text:
                'Reminder: Iron-rich foods are especially important in the second trimester. Pair them with vitamin C for better absorption! 🥦🍊',
            likes: 89,
            comments: 12,
            isVerified: true,
          ),
          const SizedBox(height: 12),
          const _PostCard(
            username: 'Mike T.',
            timeAgo: '8h ago',
            group: 'Dads Corner',
            text:
                'My wife is 30 weeks and I want to be more involved. What are things I can do to help at this stage? First time dad here.',
            likes: 45,
            comments: 32,
          ),
        ],
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int members;

  const _GroupChip({
    required this.name,
    required this.icon,
    required this.color,
    required this.members,
  });

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
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$members members',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String group;
  final String text;
  final int likes;
  final int comments;
  final bool isVerified;

  const _PostCard({
    required this.username,
    required this.timeAgo,
    required this.group,
    required this.text,
    required this.likes,
    required this.comments,
    this.isVerified = false,
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
                  child: Text(
                    username[0],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '$group · $timeAgo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.textHint),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.favorite_border,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('$likes', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('$comments',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Icon(Icons.bookmark_border,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
