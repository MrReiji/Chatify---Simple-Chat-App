
# Chatify - Simple Chat Application

Chatify is a real-time mobile communication application developed using Flutter and Firebase. Designed to provide a simple, intuitive, and efficient communication platform, Chatify includes features like user registration, authentication, real-time messaging, and push notifications.

## Features

- **User Authentication**
  - Email and password-based registration and login using Firebase Authentication.
  - Real-time data validation for secure user experience.

- **Real-Time Messaging**
  - Firebase Realtime Database enables instant message synchronization.
  - Support for both private and group chats.

- **Push Notifications**
  - Notifications for new messages using Firebase Cloud Messaging (FCM).

- **User-Friendly Interface**
  - Screens for login, chat list, conversations, and settings.

- **Additional Features**
  - Add users to chats via email or nickname.
  - Group creation and management.

## Technologies

- **Frontend**: Flutter
- **Backend**: Firebase services for authentication, real-time database, and cloud messaging.

## Folder Structure

```plaintext
lib/
├── blocs/                   # Business Logic Components
├── constants/               # Global constants and themes
├── design_widgets/          # Reusable UI components
├── models/                  # Data models for chats and messages
├── screens/                 # Application screens
└── utils/                   # Utility services (e.g., notifications)
```

## Run the Application

1. Clone the repository:
   ```bash
   git clone https://github.com/MrReiji/Chatify---Simple-Chat-App
   cd Chatify---Simple-Chat-App
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Roadmap

- **Planned Features**:
  - Media sharing (images, videos) in chats.
  - Advanced search functionalities.
  - Two-factor authentication (2FA).

- **Scalability Enhancements**:
  - More Cloud Functions for backend tasks.
  - Load balancing and performance monitoring.
