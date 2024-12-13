
# Chatify - Simple Chat Application

Chatify is a real-time mobile communication application developed using Flutter and Firebase. Designed to provide a simple, intuitive, and efficient communication platform, Chatify includes features like user registration, authentication, real-time messaging, and push notifications.

## Screenshots

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/07bb19a2-dad9-4f43-8b2c-9f3b473c8bf5" alt="Screenshot 1" width="300"></td>
      <td><img src="https://github.com/user-attachments/assets/186d66a8-b500-4e7e-b2ef-6baae00956ba" alt="Screenshot 2" width="300"></td>
      <td><img src="https://github.com/user-attachments/assets/6213869a-2a2d-463f-982f-0ab0208bdd56" alt="Screenshot 3" width="300"></td>
      <td><img src="https://github.com/user-attachments/assets/a47d095a-7220-4d6a-a873-9f06127ed91d" alt="Screenshot 4" width="300"></td>
    </tr>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/a4c89bc4-cd88-42a0-81d8-d3464a2a38ec" alt="Screenshot 5" width="300"></td>
      <td><img src="https://github.com/user-attachments/assets/eb86dc8e-5e9f-4411-9903-71d0d9767476" alt="Screenshot 6" width="300"></td>
      <td><img src="https://github.com/user-attachments/assets/99415c19-5f3b-42ba-9170-2d665bdaa413" alt="Screenshot 7" width="300"></td>
      <td><img src="https://github.com/user-attachments/assets/f717faca-4779-497c-8547-71ee6de845fb" alt="Screenshot 8" width="300"></td>
    </tr>
  </table>
</div>


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
