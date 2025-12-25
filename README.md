# 🏥 MedVault - Your Personal Health Companion

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**MedVault** is a sophisticated mobile healthcare platform built with Flutter. It serves as a secure digital vault for all your medical information, helping you stay on top of your health with intuitive tools and data-driven insights.

---

## ✨ Key Features

### 🔐 Secure Access

- **Firebase Authentication**: Secure sign-up/login using email and password.
- **Password Recovery**: Integrated forgot password flow with OTP verification.
- **Biometric-Ready**: Built with privacy in mind.

### 🩺 Comprehensive Health Tracking

- **Diagnosis Dashboard**: Log and track medical conditions with detailed history and related documents.
- **Medication Management**: Add and organize medications, dosage info, and frequency.
- **Medication Reminders**: Stay consistent with your treatment using built-in reminder systems.

### 📅 Smart Appointment Scheduling

- **Appointment Dashboard**: View upcoming and past consultations.
- **Schedule Management**: Easily add, edit, or reschedule appointments with specialized doctors.

### 👤 Personalized Experience

- **Detailed Onboarding**: Guided flow to capture health metrics (weight, height, blood type), emergency contacts, and medical history.
- **Profile Customization**: Manage personal information and upload profile photos.
- **🎨 Dynamic Theming**: Full support for **Dark Mode** and **Light Mode**, optimized for readability and reduced eye strain.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Core)
- **State Management**: Stateful Widgets & ThemeProviders
- **Icons & UI**: `flutter_svg`, `font_awesome_flutter`, `cupertino_icons`
- **Media**: `image_picker` for medical records and profile photos.
- **Typography**: Custom fonts — **Poppins** for headings and **Inter** for body text.

---

## 📂 Project Structure

```text
lib/
├── main.dart                 # App entry point & Theme Configuration
├── firebase_options.dart     # Auto-generated Firebase config
└── screens/                  # Feature-organized screens
    ├── Appointment screens/  # Appointment management
    ├── Diagnosis screens/    # Diagnosis tracking
    ├── meds screen/          # Medication & Reminders
    ├── Profile screen/       # User profile & settings
    ├── dashboard flow/       # Main navigation and overview
    ├── user setup flow/      # Onboarding & health metrics
    └── ...                   # Auth & Splash screens
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- A Firebase Project

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/medvault.git
   cd medvault
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**

   - Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from the Firebase Console.
   - Place them in the respective directories (`android/app/` and `ios/Runner/`).

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🎨 Theme System

MedVault features a robust design system defined in `main.dart`.

- **Light Mode**: Clean, white background with professional Blue primary accents (`#277AFF`).
- **Dark Mode**: High-contrast Slate Blue background (`#152034`) designed for night-time usage.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

---

**MedVault** — _Your health, organized._
