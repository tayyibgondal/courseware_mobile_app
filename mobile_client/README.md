# National Open Courseware Mobile App

A Flutter mobile application for the National Open Courseware platform.

## Features

- **Authentication**: Login and registration functionality
- **Courses**: Browse, search, and view course details
- **Books**: Access the library of educational books
- **Career Paths**: Explore different career path options
- **FAQs**: Find answers to frequently asked questions
- **Contact**: Get in touch with the platform administrators

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode for emulators
- A running instance of the National Open Courseware backend server

### Installation

1. Clone the repository
2. Navigate to the `mobile_client` directory
3. Run `flutter pub get` to install dependencies
4. Update the API base URL in `lib/services/api_service.dart` if needed
   - For Android emulator: `http://10.0.2.2:4000`
   - For iOS simulator: `http://localhost:4000`
   - For physical device: Use the actual IP address of your server

### Running the App

```bash
flutter run
```

## Project Structure

- `lib/models/`: Data models
- `lib/providers/`: State management using Provider
- `lib/screens/`: UI screens
- `lib/services/`: API services
- `lib/utils/`: Utility functions
- `lib/widgets/`: Reusable UI components

## Connecting to the Backend

The mobile app connects to the National Open Courseware backend server, which should be running on port 4000. Make sure the backend server is running before using the mobile app.

## Authentication

The app uses JWT tokens for authentication, which are stored securely using Flutter Secure Storage.

## Dependencies

- `provider`: State management
- `dio`: HTTP client
- `flutter_secure_storage`: Secure storage for tokens
- `cached_network_image`: Image caching
- `flutter_markdown`: Markdown rendering
- `intl`: Internationalization and formatting 