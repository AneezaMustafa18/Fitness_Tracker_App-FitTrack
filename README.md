# 🏋️ FitTrack – Fitness Tracker App

A Flutter-based fitness tracking app designed to help users track **workouts, nutrition, hydration, daily activity, and fitness progress** in one place.

FitTrack also provides **AI-powered fitness guidance and food analysis** to make fitness tracking more personalized and informative.

---

## 📱 App Screenshots

<p align="center">
  <img src="screenshots/onboarding.png" width="180"/>
  <img src="screenshots/login.png" width="180"/>
  <img src="screenshots/home.png" width="180"/>
  <img src="screenshots/activity.png" width="180"/>
</p>

<p align="center">
  <img src="screenshots/nutrition.png" width="180"/>
  <img src="screenshots/hydration.png" width="180"/>
  <img src="screenshots/progress.png" width="180"/>
  <img src="screenshots/profile.png" width="180"/>
</p>

<p align="center">
  <img src="screenshots/ai_coach.png" width="180"/>
  <img src="screenshots/food_scanner.png" width="180"/>
</p>

---

## ✨ Features

### 🔐 Authentication

* User registration and login
* Firebase Authentication
* OTP verification
* Forgot password functionality
* Google and Facebook sign-in

### 🏃 Activity & Workout Tracking

* Track daily activity
* Steps tracking
* Calories tracking
* Distance tracking
* Workout logging
* Activity history
* Live activity tracking

### 🍎 Nutrition Tracking

* Log daily meals
* Track calories and nutrition
* Protein, carbohydrates, and fats tracking
* Nutrition history
* Food analysis

### 💧 Hydration Tracking

* Add daily water intake
* Quick water logging
* Hydration tracking
* Hydration guidance

### 📊 Progress Tracking

* Monitor fitness progress
* Activity history
* Progress analysis
* Performance overview
* Fitness statistics

### 🤖 AI Fitness Coach

* AI-powered fitness guidance
* Personalized diet guidance
* Workout guidance
* Hydration guidance
* Progress analysis
* AI chat interface

### 📸 Food Scanner

* Analyze food through images
* Display food analysis results
* Nutrition-related information

### 👤 Profile Management

* View user profile
* Edit profile information
* Real-time profile synchronization
* Firebase Firestore integration

---

## 🛠️ Tech Stack

<p align="left">
  <img src="https://skillicons.dev/icons?i=flutter,dart,firebase,git,github" />
</p>

### Technologies & Tools

* **Flutter**
* **Dart**
* **Firebase Authentication**
* **Cloud Firestore**
* **Firebase Storage**
* **Provider**
* **Clean Architecture**
* **REST APIs**
* **JSON**
* **Git & GitHub**
* **DevicePreview**

---

## 🏗️ Architecture

FitTrack follows a **Clean Architecture** approach to keep the application modular, maintainable, and scalable.

The project is organized into:

```text
Presentation
      ↓
   Domain
      ↓
    Data
```

### Presentation Layer

Contains:

* Screens
* Widgets
* Providers
* UI-related logic

### Domain Layer

Contains:

* Entities
* Repository contracts
* Use cases

### Data Layer

Contains:

* Models
* Data sources
* Repository implementations
* API/Firebase communication

---

## 📂 Project Structure

```text
lib/
│
├── app/
│   ├── app.dart
│   ├── router/
│   └── themes/
│
├── core/
│   ├── constant/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/
│
├── features/
│   │
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── activity/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── ai_coach/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── dashboard/
│   │   └── data/
│   │
│   ├── diet/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── water/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

---

## 🔥 Firebase Integration

FitTrack uses Firebase for several core application features:

* 🔐 Firebase Authentication
* ☁️ Cloud Firestore
* 📁 Firebase Storage
* 🔄 Real-time data synchronization
* 👤 User profile management
* 📊 Fitness and activity data storage

---

## 📱 Responsive UI

The application is designed with responsive layouts to provide a consistent experience across different screen sizes.

**DevicePreview** is also used during development to test the UI across different device dimensions.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Android Emulator or physical Android device
* Git

### Installation

Clone the repository:

```bash
git clone https://github.com/AneezaMustafa18/Fitness_Tracker_App-FitTrack.git
```

Navigate to the project:

```bash
cd Fitness_Tracker_App-FitTrack
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## 🔧 Firebase Configuration

To run the project with your own Firebase project:

1. Create a Firebase project.
2. Add your Android/iOS applications.
3. Configure Firebase Authentication.
4. Configure Cloud Firestore.
5. Configure Firebase Storage.
6. Add the required Firebase configuration files.
7. Run:

```bash
flutter pub get
flutter run
```

> **Note:** Firebase configuration files and API credentials should be handled securely and should not be exposed publicly.

---

## 📌 Project Highlights

* 📱 Cross-platform Flutter application
* 🏗️ Clean Architecture
* 🔥 Firebase integration
* 🔐 Authentication
* 📊 Fitness and activity tracking
* 🍎 Nutrition tracking
* 💧 Hydration tracking
* 🤖 AI-powered fitness guidance
* 📸 Food analysis
* 🔄 Real-time data synchronization
* 📱 Responsive UI

---

## 🔮 Future Enhancements

Possible future improvements include:

* More advanced fitness analytics
* Personalized workout plans
* More detailed nutrition insights
* Improved AI recommendations
* Additional health and fitness metrics
* Enhanced progress visualization
* More customization options

---

## 👩‍💻 Developer

**Aneeza Mustafa**

Flutter Developer | Web Developer

Building cross-platform applications with Flutter and Dart.

### Connect

<p align="left">
  <a href="https://github.com/AneezaMustafa18">
    <img src="https://img.shields.io/badge/GitHub-AneezaMustafa18-black?style=for-the-badge&logo=github" />
  </a>
  <a href="https://www.linkedin.com/in/ms-developer-9bb686418/">
    <img src="https://img.shields.io/badge/LinkedIn-Aneeza%20Mustafa-blue?style=for-the-badge&logo=linkedin" />
  </a>
</p>

---

## ⭐ Show Your Support

If you find this project useful or interesting, consider giving it a ⭐ on GitHub.
