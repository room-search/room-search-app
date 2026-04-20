<p align="center">
  <img src="assets/images/app_icon_transparent.png" width="128" height="128" alt="방서치 Logo" />
</p>

<h1 align="center">Room Search</h1>

<p align="center">
  An escape-room discovery app that finds the theme that fits you.<br>
</p>

[한국어](README.ko.md)

---

## Key Features

### Search Every Theme

Browse a nationwide database of escape-room themes. Filter by difficulty, fear, activity, story, puzzle, and interior scores — plus playtime, price, and region. Sort by satisfaction, difficulty, fear level, or whatever dimension matters most to you right now.

### Find Your Perfect Match

Don't know what you want? Let the Finder do it. Two modes for two moods:

- **Wizard** — A 5-step guided flow: region → fear tolerance → difficulty & activity → story & puzzles → time & budget. Each step only shows tappable choices, no sliders to fiddle with.
- **Dashboard** — Every filter on one screen with a live match counter. Tweak any dial and watch the count update instantly.

Both modes feed a scoring engine that ranks themes 0–100 based on how closely they match your preferences, weighted by the dimensions you care about most.

### Explore on a Map

Open the map view to see every escape-room cafe plotted by location. Pan and zoom to any neighborhood, then tap **"Search This Area"** to reload only the cafes inside your current view. Tap a pin to peek at the cafe, or swipe the bottom card rail to browse nearby options.

### See Scores at a Glance

Every theme has an 8-axis radar chart covering difficulty, fear, activity, story, puzzle, interior, acting, and satisfaction. Spot a theme's personality in a single look — is it a story-heavy slow-burner or a high-activity scream-fest?

### Save Your Favorites

Tap the heart on any theme or cafe to save it. Favorites are stored locally on your device and sync live across the app — the list updates the moment you add or remove something, no refresh needed.

### Region-Aware Browsing

Pick one region or several. Filter by top-level area (Seoul, Gyeonggi, etc.) or drill down to specific neighborhoods (Gangnam, Hongdae, Konkuk, etc.). Your selection carries across the Finder, the theme list, and the map.

### Smart Experience Hints

Tell the Finder you're a first-timer and it caps difficulty at a beginner-friendly range. Say you're with family and it clamps fear and activity to safe levels. Say you're a horror fan and it biases toward the scariest themes available. The matching algorithm adapts its weights based on the hints you give.

---

## Getting Started

1. **Clone the repo** and open it in your IDE
2. **Install Flutter** (3.35 or higher, Dart SDK 3.9.2+)
3. **Install dependencies** — `flutter pub get`
4. **Add a Naver Maps API key** to your environment configuration (required for the map view)
5. **Run the app** — `flutter run`

That's it — the app launches straight into the theme list. No account, no login.

---

## Supported Platforms

| Platform | Support |
|----------|:-------:|
| Android  |    O    |
| iOS      |    O    |

---

## Tech Stack

- **Flutter** 3.35+ with Dart ^3.9.2
- **Riverpod** for state management
- **go_router** for nested tab navigation
- **Dio** for the REST client with envelope, auth, and rate-limit interceptors
- **Hive CE** for local storage of favorites
- **Naver Map** for the map view
- **flutter_animate** + **staggered_animations** + **skeletonizer** for the look and feel

---

## Privacy

- Favorites are stored only on your device via Hive
- Network calls go to the 방서치 backend for theme/cafe data and to Naver for map tiles
- No account, no tracking, no analytics SDK

---

## Requirements

- Android 7.0 (API 24) or higher / iOS 12 or higher
- An internet connection for theme data and map tiles

---

## License

MIT License — see [LICENSE](LICENSE).
