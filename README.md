# ColorFlow: Sort Master 🧪💧

> **ColorFlow: Sort Master** is a tactile liquid color-sorting puzzle game built with **Flutter (3.24.5)** and **Dart**, featuring fluid pouring animations, 50 solvable levels, customizable vessel skins and liquid palettes, tactile synthesized audio & haptics, local persistence, global leaderboard ranks, and **Google AdMob** monetization with UMP GDPR consent.

---

## ✨ Features

- **Fluid Color-Sorting Gameplay:**
  - Multi-layer consecutive pouring mechanics (`canPour`, `executePour`) with smooth tube lift, tilt, liquid surface wave, and pouring stream animations.
  - **50 Progressive Levels:** Handcrafted preset stages combined with deterministic level generation (`3` to `6` active liquid colors, Easy / Normal / Hard tiers) and `1–3` star ratings based on par moves.
  - **Smart Hint & Deadlock Detection:** Built-in AI hint solver (`findBestHintMove`) and automatic deadlock detection (`hasValidMoves`).
  - **Gameplay Boosters:** `Undo` move stack (starts with 3, refillable via rewarded ads or the shop), `+1 Tube` bonus empty vessel, `Restart`, and `Hint`.

- **Shop, Customization & Progression:**
  - **4 Vessel Skins:** *Classic Lab Vials*, *Crystal Flacons*, *Royal Golden Tubes*, and *Cyber Prism Vials*.
  - **3 Liquid Palettes:** *Vibrant Pastel Fluids*, *Neon Glow Fluids*, and *Ocean & Gems Palette*.
  - **Power-ups & Rewards:** *Undo Master (+10)* pack and *Free +100 Coins* rewarded chest.
  - **Levels & Global Ranks:** 50-level progression grid (`150` total stars) and a dynamic Top-3 podium & leaderboard (`RanksScreen`).
  - **Accessibility & Profile:** Color-blind symbol overlay mode, Sound FX & Haptics toggles, customizable player nickname and avatar, and progress reset in `SettingsModal` / `ProfileModal`.

- **Synthesized Audio & Haptics:**
  - Pre-synthesized 44.1 kHz PCM `.wav` effects in `assets/sounds/` (`pour`, `tap`, `tube_complete`, `invalid`, `win`, `click`) played via `just_audio` alongside native `HapticFeedback`.

- **Google AdMob & UMP GDPR Consent:**
  - Managed via `AdService` (`google_mobile_ads`) with Google User Messaging Platform (`ConsentInformation` / `ConsentForm`) initialization.
  - Automatically uses Google's official test ad unit IDs in debug/profile/test builds (`!kReleaseMode`) and production Android unit IDs in release builds (`kReleaseMode`), with optional `--dart-define` overrides (`ADMOB_BANNER_ANDROID_ID`, `ADMOB_REWARDED_ANDROID_ID`, `ADMOB_INTERSTITIAL_ANDROID_ID`, and iOS equivalents).
  - **Banner Ad:** Anchored cleanly above the bottom navigation bar.
  - **Rewarded Ads:** `+1 Extra Tube`, `Refill +3 Undos`, `3x Victory Coins`, and `Free +100 Coins` (with an interactive fallback modal on unsupported/test platforms).
  - **Interstitial Ads:** Preloaded and displayed every 3 standard `Next Level (1x)` completions (guarded so it never interrupts Rewarded Ad flows).

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter `3.24.5` (Dart `3.5.4`), Material Design 3
- **State Management:** `provider` (`GameProvider` + `AdService`)
- **Typography & Styling:** `google_fonts` (`Plus Jakarta Sans` & `Nunito`), custom glassmorphism cards & tactile 3D buttons
- **Audio & Storage:** `just_audio`, `shared_preferences`
- **Monetization:** `google_mobile_ads` (`^5.3.1`)
- **Android Build:** Package `com.colorflow.sortmaster`, Gradle `8.3`, AGP `8.1.0`, Kotlin `1.8.22`, `compileSdk 35`, `minSdk 21`, `targetSdk 35`

### Project Layout

```text
lib/
├── main.dart                  # App entrypoint, providers & modal wiring
├── models/game_models.dart    # Tube, LevelData, SavedProgress, ShopCatalogItem, enums
├── logic/
│   ├── game_engine.dart       # Pour rules, deadlock checks, AI hint solver, star/coin math
│   └── levels.dart            # Preset levels & deterministic 50-level generator
├── providers/game_provider.dart
├── services/
│   ├── ad_service.dart        # UMP consent, Banner, Rewarded & Interstitial lifecycle
│   ├── audio_service.dart     # just_audio WAV player & haptic feedback
│   └── storage_service.dart   # SharedPreferences persistence
├── theme/                     # AppColors, AppTypography, AppShadows
├── screens/                   # GameScreen, LevelsScreen, ShopScreen, RanksScreen
└── widgets/                   # TestTube, LiquidLayer, FluidStream, HUD, Modals, Nav & Ads
test/
├── game_engine_test.dart
├── levels_test.dart
├── game_provider_test.dart
├── ad_service_test.dart
└── widget_test.dart
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK 3.24.5](https://docs.flutter.dev/get-started/install) (with Dart 3.5+)
- Android SDK (`compileSdk 35`, `minSdk 21`) & JDK 17 for Android builds

### Install & Run

```bash
git clone https://github.com/Math-ieu/colorflow-sort-master.git
cd colorflow-sort-master

flutter pub get
flutter run
```

### Static Analysis & Tests

```bash
flutter analyze
flutter test
```

### Android Play Store Release Build (`.aab`)

Release signing reads `android/key.properties` (git-ignored) and falls back to debug signing when `key.properties` is absent.

1. Create `android/key.properties` locally (do **not** commit this file or your `.jks` keystore):

   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=<your-key-alias>
   storeFile=../../upload-keystore.jks
   ```

2. Build the R8-minified & resource-shrunk Android App Bundle:

   ```bash
   flutter build appbundle --release
   ```

   Output bundle: `build/app/outputs/bundle/release/app-release.aab`.

---

## 📜 License

MIT License — see [LICENSE](LICENSE).
