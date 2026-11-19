# Instagram Clone — Flutter

An offline Instagram-style app: sign up / log in, a photo + reel feed, full-screen reels with sound, search, a profile page, likes and comments. Everything is stored on the device.

This document explains **every section of the code, what it does, and what it is implemented with**.

---

## 1. Tech stack — what is used for what

| Technology | Used for | Where |
|---|---|---|
| **Flutter / Dart** | UI and app logic | everywhere |
| **flutter_bloc** (`Bloc`, `BlocBuilder`, `BlocListener`, `RepositoryProvider`) | State management and dependency injection | `presentation/blocs`, `main.dart` |
| **equatable** | Value equality for states and entities (so Blocs only rebuild on real changes) | `domain/entities`, bloc states |
| **shared_preferences** | Local persistence of users, posts and the session (JSON strings) | `data/datasources/local_storage.dart` |
| **path_provider** | App documents folder where reel videos are stored | `data/repositories/media_repository_impl.dart` |
| **image_picker** | Choosing a photo or video from the gallery | `pages/create/*` |
| **video_player** | Playing reels (autoplay, loop, audio) and reading a video's duration | `widgets/reel_player.dart`, `create_reel_page.dart` |
| **fc_native_video_thumbnail** | Generating a JPEG thumbnail from a video | `data/repositories/media_repository_impl.dart` |

---

## 2. Architecture

The project follows **Clean Architecture** with three layers and one strict rule: **dependencies point inward**.

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION   pages · widgets · blocs                      │
│   Flutter UI. Talks to the domain only through Blocs.       │
├─────────────────────────────────────────────────────────────┤
│ DOMAIN         entities · repository interfaces · failures  │
│   Pure Dart. Knows nothing about Flutter or storage.        │
├─────────────────────────────────────────────────────────────┤
│ DATA           repository implementations · data sources ·  │
│                models/mappers                               │
│   Implements the domain interfaces with SharedPreferences,  │
│   the file system and the thumbnail plugin.                 │
└─────────────────────────────────────────────────────────────┘
        CORE (theme, constants, utils) is shared by all layers.
```

**Dependency rule**

- `domain` imports nothing from `data` or `presentation`.
- `data` imports `domain` (to implement its interfaces).
- `presentation` imports `domain` (entities + interfaces), never `data`.
- Only `main.dart` knows the concrete classes and wires them together.

**Why this matters:** to move from local storage to a real backend, you replace the classes in `data/repositories` and change three lines in `main.dart`. No page or Bloc changes.

> **Use cases:** a separate `domain/usecases` folder is intentionally not used. Each operation here is a single repository call, so use-case classes would only be one-line pass-throughs. When business logic grows (for example "post a reel = validate + upload + notify"), add them there and have the Bloc call the use case instead of the repository.

---

## 3. Folder structure

```
lib/
├── main.dart                     Composition root: builds and wires everything
├── app.dart                      MaterialApp (theme + first screen)
│
├── core/                         Shared by all layers
│   ├── constants/app_constants.dart   Splash time, max reel length, min password
│   ├── theme/app_colors.dart          All colours and gradients
│   ├── theme/app_theme.dart           Dark Material 3 ThemeData
│   └── utils/time_ago.dart            "5m", "3h", "2d", "Just now"
│
├── domain/                       Business layer (pure Dart)
│   ├── entities/                      AppUser, Post, Comment, SavedReel
│   ├── failures/auth_exception.dart   User-facing business error
│   └── repositories/                  AuthRepository, PostRepository, MediaRepository (interfaces)
│
├── data/                         Storage layer
│   ├── datasources/local_storage.dart SharedPreferences wrapper (only class that touches it)
│   ├── datasources/seed_data.dart     Demo posts for first launch
│   ├── models/user_model.dart         User + password (storage only)
│   ├── models/post_mapper.dart        Post/Comment <-> JSON
│   └── repositories/                  *_impl.dart for each domain interface
│
└── presentation/                 UI layer
    ├── blocs/auth/                    AuthBloc (+ event, state)
    ├── blocs/feed/                    FeedBloc (+ event, state)
    ├── navigation/open_post.dart      Decides what tapping a tile opens
    ├── widgets/                       Reusable widgets (avatar, ReelPlayer, tiles, ...)
    └── pages/
        ├── splash/ auth/ shell/ home/ reels/ explore/ profile/ create/ comments/
```

---

## 4. Section-by-section walkthrough

### 4.1 App start-up — `main.dart`, `app.dart`
- `main.dart` creates `LocalStorage`, then the three repository implementations, and exposes them as their **interfaces** through `MultiRepositoryProvider`. It then creates `AuthBloc` and `FeedBloc` with `MultiBlocProvider`.
- Providers sit **above** `MaterialApp`, so every pushed route (reel viewer, create pages, sheets) can read them. No per-route `BlocProvider.value` is needed.
- `app.dart` builds the `MaterialApp` with `AppTheme.dark` and `AuthGate` as home.

### 4.2 Core
- **`AppColors`** holds every colour/gradient, replacing the old scattered `kBg`, `kBtn`, … constants and raw hex values.
- **`AppConstants`** holds the splash duration, 90-second reel limit and minimum password length.
- **`time_ago.dart`** formats timestamps; `shortAgo` is used in comments, `longAgo` in the post footer (fixes the old "now ago" text).

### 4.3 Domain
- **Entities** are immutable `Equatable` classes. `AppUser` deliberately has **no password**. `Post` has `isReel` and `isLikedBy()` helpers.
- **A reel `Post`** stores the video *file name* in `video` and a base64 JPEG *thumbnail* in `image`.
- **Repository interfaces** define what the app needs (login, toggle like, save reel, …). Blocs depend only on these.
- **`AuthException`** carries a message that is safe to show in a SnackBar.

### 4.4 Data
- **`LocalStorage`** reads/writes three keys: `users`, `posts`, `current` (session). JSON keys are unchanged from the old version, so existing saved data still loads.
- **`AuthRepositoryImpl`** validates input, keeps the user list and session, and returns password-free `AppUser`s.
- **`PostRepositoryImpl`** caches posts in memory and writes through on every change. On first load it **back-fills thumbnails for old reels** that were saved before thumbnails existed.
- **`MediaRepositoryImpl`** copies a picked video into the documents folder (keeping its extension), generates a 480 px JPEG thumbnail, and resolves stored file names back to `File`s.
- **`seed_data.dart`** supplies four demo posts on first launch.

### 4.5 Blocs
| Bloc | Events | State | Purpose |
|---|---|---|---|
| `AuthBloc` | `AuthStarted`, `LoginRequested`, `SignUpRequested`, `LoggedOut`, `ProfileUpdated` | `user`, `error`, `stamp` | Session and profile |
| `FeedBloc` | `FeedStarted`, `LikeToggled`, `CommentAdded`, `PostCreated` | `posts`, `isLoading` | Feed, likes, comments, new posts |

Each Bloc is split into `*_bloc.dart`, `*_event.dart`, `*_state.dart` (linked with `part`). Events carry the acting username, so `FeedBloc` does not depend on `AuthBloc`. `AuthState.stamp` changes on every attempt so a repeated error still shows a SnackBar.

### 4.6 Pages
| Page | File | What it does | Built with |
|---|---|---|---|
| Splash | `splash/splash_page.dart` | Logo + "from Meta" | `IgLogo`, `ShaderMask` |
| Auth gate | `auth/auth_gate.dart` | Splash → Login or Shell | `BlocBuilder<AuthBloc>` |
| Login / Sign-up | `auth/login_page.dart` | One form that toggles modes; shows errors | `BlocListener`, `TextField` |
| Shell | `shell/app_shell.dart` | 5 tabs + bottom bar | `IndexedStack`, `TickerMode` |
| Home | `home/home_tab.dart`, `post_card.dart` | Stories strip + feed | `BlocBuilder<FeedBloc>`, `ListView` |
| Reels tab | `reels/reels_tab.dart` | Full-screen reels pager | `ReelsPager` |
| Reel viewer | `reels/reels_viewer_page.dart` | Opens a tapped reel full-screen | `Navigator.push`, `ReelsPager` |
| Search | `explore/explore_tab.dart` | Search by user/caption + grid | `GridView`, `PostTile` |
| Profile | `profile/profile_tab.dart` | Header, Posts/Reels tabs, grid, edit, logout | `BlocBuilder` ×2, `GridView` |
| Create | `create/*` | Create menu, photo post, reel | `image_picker`, `video_player`, `MediaRepository` |
| Comments | `comments/comments_sheet.dart` | Comment list + input | `showModalBottomSheet` |

### 4.7 Shared widgets (`presentation/widgets`)
- **`ReelPlayer`** – the one widget that plays video (see section 6).
- **`PostImage`** – static image of a post (photo or reel thumbnail) with a gradient fallback. Decodes base64 once, not on every rebuild.
- **`PostTile`** – grid thumbnail with a play badge for reels.
- **`PostMedia`** – feed media: image with double-tap-like, or inline `ReelPlayer`.
- **`DoubleTapHeart`** – single gesture handler for tap + double-tap and the heart animation.
- **`Avatar`**, **`IgLogo`** – drawn with plain containers/gradients, no image assets.

---

## 5. Data-flow examples

**Liking a post**
```
PostCard (tap) → FeedBloc.add(LikeToggled) → PostRepository.toggleLike()
   → PostRepositoryImpl updates cache + LocalStorage.writePosts()
   → FeedBloc emits FeedState(posts) → BlocBuilder rebuilds the UI
```

**Sharing a reel**
```
CreateReelPage → pick video → check ≤ 90 s → thumbnail preview
Share → MediaRepository.saveReel()  (copy file + make JPEG thumbnail)
      → FeedBloc.add(PostCreated(video: fileName, image: thumbnail))
      → PostRepository.createPost() → feed + grids update
```

---

## 6. Video playback — how it works (and what was fixed)

### Behaviour
- Tapping a reel in **Search** or **Profile** opens `ReelsViewerPage`, which **autoplays with sound**, loops, and lets you swipe to the next reel.
- The **Reels tab** also autoplays with sound.
- **Inline reels in the home feed** autoplay **muted** (so several never play audio at once); tap the speaker button to hear one.
- Tap = pause/resume · double-tap = like (heart animation) · speaker button = mute/unmute.

### Root causes that were fixed
| Problem | Cause | Fix |
|---|---|---|
| Video would not play after opening Search/Profile | Every grid tile created its own `VideoPlayerController` just to show a thumbnail. Devices have only a few hardware decoders, so the real player could not get one. | Reels now store a **JPEG thumbnail**. Grids use `PostImage` (no decoder). Only the visible reel has a controller. |
| Tapping a tile sometimes did nothing | `GestureDetector` used the default hit-test, which ignores the video texture. | `HitTestBehavior.opaque` on tiles and the player. |
| No audio | Player was hard-coded to `muted = true`. | Full-screen reels start unmuted. |
| Double-tap-like failed on reels in the feed | The inner `GestureDetector` swallowed the outer double-tap. | One `DoubleTapHeart` handles both tap and double-tap. |
| Blank frame when a video failed | `initialize()` errors were swallowed. | Error placeholder ("Video unavailable") + loading spinner. |
| Videos from other tabs kept playing | Reliance on implicit `IndexedStack` behaviour. | Explicit `TickerMode(enabled: selected)` per tab. |

### Playback rule inside `ReelPlayer`
A video plays only when **all** are true: it is the current page in the pager · its tab/route is visible (`TickerMode`) · the app is in the foreground · the user has not paused it. Swiping away pauses it; returning restarts from the beginning.

---

## 7. Coding standards used in this project

1. **One public class per file**; file name = class name in `snake_case`.
2. **Header comment on every file** with: path, layer, purpose, and who uses it / what it dispatches.
3. **Layering rule** (section 2) — presentation never imports `data`.
4. **No magic values** — colours in `AppColors`, numbers in `AppConstants`.
5. **Immutable entities** with `Equatable`; state classes are immutable too.
6. **Named parameters** for anything with more than one argument (`login(username:, password:)`).
7. **Dispose everything** — every `TextEditingController`, `PageController`, `AnimationController` and `VideoPlayerController` is disposed.
8. **Check `mounted`** after every `await` that is followed by `setState` or navigation.
9. **`const`** constructors wherever possible.
10. **Small private widgets** (`_TopBar`, `_Header`, …) instead of giant `build` methods or helper functions that return widgets.

### Adding a new feature (checklist)
1. Add/extend an **entity** and a **repository interface** in `domain`.
2. Implement it in `data/repositories`; register it in `main.dart`.
3. Add events/state/Bloc in `presentation/blocs`.
4. Build the page in `presentation/pages/<feature>` with the standard header comment.

---

## 8. Setup

```bash
flutter pub add flutter_bloc equatable shared_preferences path_provider \
                image_picker video_player fc_native_video_thumbnail
flutter pub get
flutter run
```

`fc_native_video_thumbnail` is the **only new dependency** compared with the previous version. (The older `video_thumbnail` package is *not* used: it still relies on `jcenter()` and fails on Gradle 9 / AGP 9.)

**Permissions**
- **iOS** (`ios/Runner/Info.plist`): `NSPhotoLibraryUsageDescription`.
- **Android**: no extra setup for gallery picking on modern versions.

---

## 9. Known limitations / next steps
- **Passwords are stored in plain text** in SharedPreferences. Acceptable for an offline demo only; hash them (or use a backend) for real use.
- Thumbnails and photos are stored as base64 inside SharedPreferences, which is fine for a small demo but should move to files or a database as data grows.
- Followers, following, Messages, Stories, Edits, Highlights and Live are UI placeholders.
- No automated tests yet. The repository interfaces make Blocs easy to test with fakes (`bloc_test` + `mocktail`).

## 10. Troubleshooting
| Symptom | Check |
|---|---|
| `Target of URI doesn't exist: fc_native_video_thumbnail` | Run the `flutter pub add` command above. |
| Old reels show a grey gradient instead of a thumbnail | Thumbnail generation failed for that file (unsupported codec or the file was deleted); the reel itself still plays if the file exists. |
| Gradle error mentioning `video_thumbnail` / `jcenter()` | Remove the old package (`flutter pub remove video_thumbnail`), then `flutter clean && flutter pub get`. |
| `Starting AGP 9+, only the new DSL interface will be read` | Run `flutter upgrade`, or add `android.newDsl=false` to `android/gradle.properties`. |
| "Video unavailable" in the viewer | The video file is missing from app storage or the device cannot decode that format. |
| No sound | Check the speaker button on the reel and the phone's media volume / silent switch. |