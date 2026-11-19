// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/datasources/seed_data.dart
// Layer   : Data (data source)
// Purpose : Demo posts shown on first launch so the feed is not empty.
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';

List<Post> buildSeedPosts() {
  final now = DateTime.now().millisecondsSinceEpoch;
  const hour = 3600000;

  return [
    Post(
      id: 1,
      user: 'arjun_frames',
      caption: 'Late night coffee & code ☕💻',
      seed: 10,
      timestamp: now - 5 * hour,
      likes: const ['rohan.builds', 'dev_karthik'],
      comments: [
        Comment(user: 'rohan.builds', text: 'The grind never stops 🔥', timestamp: now - 4 * hour),
      ],
    ),
    Post(
      id: 2,
      user: 'rohan.builds',
      caption: 'Monsoon mornings hit different 🌧️🌿',
      seed: 24,
      timestamp: now - 12 * hour,
      likes: const ['arjun_frames'],
      comments: [
        Comment(user: 'dev_karthik', text: 'Need this weather right now!', timestamp: now - 11 * hour),
      ],
    ),
    Post(
      id: 3,
      user: 'dev_karthik',
      caption: 'Weekend beach drive with the boys 🌊🚗',
      seed: 37,
      timestamp: now - 25 * hour,
      likes: const ['arjun_frames', 'rohan.builds', 'vikram_clicks'],
      comments: [
        Comment(user: 'vikram_clicks', text: 'Best weekend ever 🙌', timestamp: now - 23 * hour),
        Comment(user: 'arjun_frames', text: 'Take me next time!', timestamp: now - 22 * hour),
      ],
    ),
    Post(
      id: 4,
      user: 'vikram_clicks',
      caption: 'Chasing city lights after sunset ✨🌃',
      seed: 42,
      timestamp: now - 48 * hour,
      likes: const ['rohan.builds'],
    ),
  ];
}
