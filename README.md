# Olly App# 

Olly App - Flutter Weather App with Secure Authentication

A Flutter weather app built for a technical assessment. It features secure user authentication and displays real-time weather information based on your current location.A production-ready Flutter application demonstrating secure user authentication and real-time weather information. Built as a technical assessment showcasing best practices in mobile and web development.


The weather feature uses the OpenWeatherMap API to fetch real-time data based on GPS location. The app automatically detects whether it's day or night using sunrise/sunset times and adjusts the theme accordingly. Users can also search for weather in any city worldwide. I've built this with Flutter's Material Design 3, making it responsive and functional on both web browsers and mobile devices. The codebase follows clean architecture principles with clear separation between authentication, data models, services, and UI components.



## Running the App
### Authentication System

- **Dual Authentication Options:**

```bash  - **Cloud-Based**: Supabase integration with bcrypt password hashing

# clone and install dependencies  - **Local Authentication**: Custom SHA-256 implementation with salt (10,000 iterations)

git clone <your-repo-url>- **Secure Password Management**: Industry-standard hashing with constant-time comparison

cd olly_app- **Session Management**: Persistent login with automatic session handling

flutter pub get- **Complete Auth Flow**: Registration, login, logout with validation



# Run on web

flutter run -d chrome- **Real-Time Weather Data**: OpenWeatherMap API integration (v2.5)

- **Location-Based**: Automatic GPS detection of user's current location

# Run tests (19 tests, all passing)- **City Search**: Manual location search functionality

flutter test- **Dynamic Theming**: Day/night mode based on sunrise/sunset times

```- **Comprehensive Display**:

  - Current temperature (Celsius)

The app uses Supabase for authentication (you'll need to add your own credentials in `lib/main.dart`) and OpenWeatherMap for weather data. Both services offer free tiers. If you want to see the custom password hashing implementation in action, check out `LOCAL_AUTH_USAGE.md` for instructions on switching to local authentication.  - Weather conditions with icons

  - Location (city, country)
  - "Feels like" temperature
  - Humidity and wind speed


## Technical Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart 3.x** | Programming language |
| **Supabase** | Backend-as-a-Service (authentication) |
| **OpenWeatherMap API** | Weather data provider |
| **Geolocator** | GPS location services |
| **Geocoding** | City search and coordinates |
| **Crypto** | SHA-256 password hashing |
| **SharedPreferences** | Local data persistence |

## Assessment Requirements

### User Authentication
- **Implementation**: Two approaches demonstrating versatility
  1. **Supabase Backend** (Active): Production-ready cloud authentication
  2. **Local Authentication**: Custom password hashing implementation
- **Password Security Best Practices**:
  - No plaintext password storage
  - Cryptographically secure hashing (SHA-256 + salt)
  - High iteration count (10,000) for brute-force resistance
  - Random 256-bit salt per password
  - Constant-time comparison (timing attack prevention)
  - Secure session management

### Weather Display
- **Location Detection**: Automatic GPS-based weather for user's current location
- **API Integration**: OpenWeatherMap API v2.5 with error handling
- **Real-Time Data**: Live weather updates with temperature, conditions, and more
- **User Experience**: Clean, informative display with visual weather icons

### Web & Mobile Design
- **Web Support**: Fully functional in Chrome, Firefox, Safari, Edge
- **Mobile Support**: iOS and Android native apps
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Cross-Platform Compatibility**: Material Icons instead of emojis for consistent rendering

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for mobile development)
- Chrome (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/olly_app.git
   cd olly_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase** (Optional - for cloud auth)
   - Create a free account at [supabase.com](https://supabase.com)
   - Create a new project
   - Update `lib/main.dart` with your credentials:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

4. **Configure Weather API** (Optional - demo API key included)
   - Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
   - Update `lib/services/service.dart`:
   ```dart
   static const String apiKey = 'YOUR_API_KEY';
   ```

### Running the App

**Web:**
```bash
flutter run -d chrome
```

**Mobile (iOS Simulator):**
```bash
flutter run -d ios
```

**Mobile (Android Emulator):**
```bash
flutter run -d android
```

**Build for Production:**
```bash
# web
flutter build web

# iOS
flutter build ios --release

# android
flutter build apk --release
```

## Project Structure

```
olly_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── auth/
│   │   ├── auth_gate.dart           # Authentication routing
│   │   ├── auth_service.dart        # Supabase authentication
│   │   ├── local_auth_service.dart  # Local authentication
│   │   └── password_hasher.dart     # Custom password hashing
│   ├── model/
│   │   └── weather_model.dart       # Weather data model
│   ├── pages/
│   │   ├── login_page.dart          # Login screen
│   │   ├── register_page.dart       # Registration screen
│   │   └── weather_page.dart        # Main weather display
│   └── services/
│       └── service.dart             # Weather API service
├── test/
│   ├── unit/
│   │   ├── password_hasher_test.dart  # Password hashing tests (10 tests)
│   │   └── weather_model_test.dart    # Weather model tests (7 tests)
│   └── widget/
│       └── login_page_test.dart       # Widget tests (2 tests)
├── assets/                          # App assets (logos, images)
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## Security Implementation

### Password Hashing Architecture

The app demonstrates two secure authentication approaches:

#### 1. Supabase Authentication (Active)
- **Server-Side Hashing**: Passwords hashed with bcrypt on Supabase servers
- **HTTPS Transport**: Secure transmission of credentials
- **Built-in Security**: Industry-standard authentication service
- **Session Management**: JWT-based authentication tokens

#### 2. Local Authentication (Demonstration)
Custom implementation showcasing cryptographic knowledge:

```dart
// password Hashing Process
1. Generate random 256-bit salt
2. Combine password + salt
3. Apply SHA-256 hash 10,000 times (PBKDF2-like)
4. Store: "salt:hashedPassword"

// password Verification Process
1. Extract salt from stored hash
2. Hash entered password with same salt + iterations
3. Constant-time comparison to prevent timing attacks
```

**Security Features:**
- **No Plaintext Storage**: Passwords never stored in readable form
- **Unique Salts**: Each password gets cryptographically random salt
- **Slow Hashing**: 10,000 iterations slow down brute-force attacks
- **Timing Attack Prevention**: Constant-time comparison
- **Industry Standards**: SHA-256 (FIPS 180-4 compliant)

### Testing Coverage

**19 Total Tests** - All Passing 

```bash
flutter test
```


**Demo Credentials:**
```
Register your own account to test the authentication system!
```

## Switching Authentication Methods

The app supports both cloud (Supabase) and local authentication. To switch:

### Current: Supabase (Cloud)
- Multi-device sync
- Password recovery
- Scalable infrastructure

### Alternative: Local Authentication
See `LOCAL_AUTH_USAGE.md` for detailed instructions on switching to the custom password hashing implementation.

## Testing

Run all tests:
```bash
flutter test
```

Run specific test suite:
```bash
# password hashing tests
flutter test test/unit/password_hasher_test.dart

# weather model tests
flutter test test/unit/weather_model_test.dart
```

Run with coverage:
```bash
flutter test --coverage
```

## API Documentation

### Weather Service
```dart
// fetch weather by coordinates
final weather = await WeatherService.fetchWeatherByLocation(latitude, longitude);

// fetch weather by city name
final weather = await WeatherService.fetchWeatherByCity(cityName);
```

### Authentication Service (Supabase)
```dart
// register
await authService.signUpWithEmailPassword(email, password);

// login
await authService.signInWithEmailPassword(email, password);

// logout
await authService.signOut();

// get current user
final email = authService.getCurrentUserEmail();
```

### Local Authentication Service
```dart
// register
await localAuth.register(email, password);

// login
await localAuth.login(email, password);

// logout
await localAuth.logout();

// get current user
final email = await localAuth.getCurrentUser();
```
