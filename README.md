# ColorFlow: Sort Master 🧪💧

> **ColorFlow: Sort Master** is a premium, addictive liquid puzzle game built with **React Native**, **Expo (SDK 58)**, and **TypeScript**, featuring fluid color-sorting mechanics, progressive level generation, customizable test tubes and palettes, and complete **Google AdMob** monetization.

---

## ✨ Features

- **Fluid Color Sorting Mechanics:**
  - Dynamic pouring physics with transfer rate calculation and multi-layer pour logic.
  - Undo stack booster with instant rollback.
  - Sealed tubes, mystery layer reveals (`?`), and deadlock auto-detection with smart hint suggestion.

- **50 Handcrafted & Calibrated Levels:**
  - Progressive difficulty from 2-tube tutorial to 12-tube complex multi-color puzzles.
  - Star rating system (1, 2, or 3 stars based on move efficiency).
  - Level select screen with progress tracking and level restart.

- **Shop & Customization:**
  - **Vessel Skins:** Classic Laboratory, Modern Crystal, Antique Apothecary.
  - **Fluid Palettes:** Neon Cyberpunk, Pastel Dream, Marine Ocean, Classic Laboratory.
  - Consumables shop for purchasing Extra Undos and Coins.

- **Monetization & AdMob Integration:**
  - Native integration via `react-native-google-mobile-ads` with web-fallback simulation.
  - **Banner Ad:** Adaptive banner positioned cleanly under the puzzle board.
  - **Rewarded Video Ads:**
    - `+1 Extra Tube` when stuck on a challenging level.
    - `Refill +3 Undos` when running low on undos.
    - `3x Level Coins Multiplier` upon victory.
    - `Free +100 Coins` in the Shop.

- **Audio & Haptics:**
  - Synthetic Web Audio API & React Native sound engine for clicks, pours, wins, and error feedback.

---

## 🛠️ Tech Stack

- **Framework:** [Expo](https://expo.dev/) (SDK 58), [React Native](https://reactnative.dev/) (0.88), React 19
- **Language:** TypeScript 6
- **Monetization:** `react-native-google-mobile-ads`
- **Icons & UI:** `@expo/vector-icons`
- **Testing:** Unit test suite with TSX/Node runner (100% engine test coverage)

---

## 🚀 Getting Started

### Prerequisites

- Node.js (v18+)
- npm or yarn

### Installation

```bash
# Clone the repository
git clone https://github.com/Math-ieu/colorflow-sort-master.git
cd colorflow-sort-master

# Install dependencies
npm install
```

### Running the App

```bash
# Start Web browser version
npm run web

# Start Android development build
npm run android

# Start iOS development build
npm run ios

# Run engine unit tests
npm run test
```

---

## 📜 License

MIT License.
