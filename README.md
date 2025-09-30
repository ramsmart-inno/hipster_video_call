# 🎥 Hipster Video Call - Flutter Video Calling App

A professional, store-ready Flutter video calling application built with modern architecture and industry best practices. Features real-time video calling, user management, and a Google Meet-like experience.

## ✨ Features

### 🔐 Authentication & Security
- **Secure Authentication** with ReqRes.in API integration
- **JWT Token Management** with automatic refresh
- **Secure Storage** using flutter_secure_storage
- **API Key Authentication** for enhanced security

### 📹 Video Calling
- **Real-time Video Calls** powered by Agora SDK
- **HD Video Quality** with adaptive bitrate
- **Audio/Video Controls** (mute, camera toggle, screen sharing)
- **Professional UI** similar to Google Meet
- **Multi-participant Support** ready for scaling

### 👥 User Management
- **Team Members List** with offline caching
- **User Profiles** with avatars and details
- **Offline Support** with intelligent data caching
- **Pull-to-refresh** for latest data

### 🎨 Modern UI/UX
- **Material Design 3** with custom theming
- **Consistent Color Scheme** across all screens
- **Smooth Animations** and transitions
- **Professional Splash Screen** (Flutter-based)
- **Responsive Design** for all screen sizes
- **Progressive Web App** (PWA) support
- **Cross-platform Compatibility** (Mobile, Web, Desktop-ready)

### 🏗️ Architecture & Code Quality
- **BLoC Pattern** for state management
- **Dependency Injection** with get_it
- **Clean Architecture** with separation of concerns
- **Error Handling** with Sentry integration
- **Professional Logging** throughout the app
- **Null Safety** and modern Dart features

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio / VS Code
- Android device or emulator
- **⚠️ Agora.io account with valid App ID** (required for video calling)
- Internet connection

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hipster_video_call
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   Create a `.env` file in the root directory:
   ```env
   AGORA_APP_ID=your_agora_app_id_here
   SENTRY_DSN=your_sentry_dsn_here
   API_BASE_URL=https://reqres.in/api
   ```

4. **Run the app**
   ```bash
   # Mobile (Android/iOS)
   flutter run

   # Web
   flutter run -d web-server --web-port=8080
   # Then open http://localhost:8080 in your browser
   ```

5. **Test the app**
   Use these test credentials to login:
   ```
   Email: eve.holt@reqres.in
   Password: cityslicka
   ```

### Build for Production

#### **Quick Build Commands**

```bash
# Android APK (Universal - includes all architectures)
flutter build apk --release
# Result: app-release.apk (152.2MB)

# Android APK (Optimized - Split by architecture)
flutter build apk --release --split-per-abi
# Results:
# - app-arm64-v8a-release.apk (50.1MB)
# - app-armeabi-v7a-release.apk (46.1MB)

# Android App Bundle (Recommended for Play Store)
flutter build appbundle --release

# Web Build
flutter build web --release

# Run Web Development Server
flutter run -d web-server --web-port=8080
```

**📱 APK Size Comparison:**
| Build Type | Size | Use Case |
|------------|------|----------|
| **Universal APK** | 152.2MB | Single APK for all devices |
| **arm64-v8a APK** | 50.1MB | Modern 64-bit devices (recommended) |
| **armeabi-v7a APK** | 46.1MB | Older 32-bit devices |

**💡 Recommendation**: Use `--split-per-abi` for 70% smaller downloads

## 🔐 Android Release Build Setup

### **1. App Signing Configuration**

#### **Option A: Debug Signing (Development/Testing)**
The project is pre-configured with debug signing for easy testing:

```bash
# Uses debug keystore (already configured)
flutter build apk --release
flutter build appbundle --release
```

#### **Option B: Production Signing (Play Store)**

1. **Generate a signing key:**
   ```bash
   # Create keystore directory
   mkdir -p android/app/keystore

   # Generate release keystore
   keytool -genkey -v -keystore android/app/keystore/release.keystore \
           -alias release -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Create `android/key.properties`:**
   ```bash
   # Copy template and edit
   cp android/key.properties.example android/key.properties
   # Then edit with your actual passwords
   ```

   Or create manually:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=release
   storeFile=keystore/release.keystore
   ```

   **🔒 Security Note**: Never commit `key.properties` or keystore files to version control!

3. **Update `android/app/build.gradle`:**
   ```gradle
   // Add before android block
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       // ... existing configuration

       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }

       buildTypes {
           release {
               signingConfig signingConfigs.release
               minifyEnabled true
               shrinkResources true
               proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
           }
       }
   }
   ```

### **2. Release Build Optimization**

#### **Current Optimizations (Already Applied)**
✅ **Code Shrinking**: R8/ProGuard enabled
✅ **Resource Shrinking**: Unused resources removed
✅ **Architecture Splitting**: Separate APKs for different CPUs
✅ **Icon Tree-shaking**: Font assets optimized (99.7% reduction)

#### **Additional Optimizations**

1. **Enable additional optimizations in `android/app/build.gradle`:**
   ```gradle
   android {
       buildTypes {
           release {
               // Existing configuration...

               // Additional optimizations
               debuggable false
               jniDebuggable false
               renderscriptDebuggable false
               zipAlignEnabled true
               crunchPngs true
           }
       }
   }
   ```

2. **Optimize Gradle build in `android/gradle.properties`:**
   ```properties
   # Performance optimizations (already applied)
   org.gradle.parallel=true
   org.gradle.caching=true
   org.gradle.configureondemand=true

   # Additional optimizations
   org.gradle.daemon=true
   org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
   ```

### **3. Play Store Preparation**

#### **App Bundle (Recommended)**
```bash
# Build optimized App Bundle for Play Store
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Size: 153.6MB (Play Store optimizes to ~50-70MB per device)
```

#### **APK for Direct Distribution**
```bash
# Build split APKs for direct distribution
flutter build apk --release --split-per-abi

# Outputs:
# - app-arm64-v8a-release.apk (50.1MB) - Most devices
# - app-armeabi-v7a-release.apk (46.1MB) - Older devices
```

### **4. Version Management**

#### **Update App Version**
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+buildNumber
# For new release: 1.0.1+2, 1.1.0+3, etc.
```

#### **Update Android Version**
The version is automatically synced from `pubspec.yaml`, but you can override in `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        versionCode flutterVersionCode.toInteger()  // Auto from pubspec.yaml
        versionName flutterVersionName              // Auto from pubspec.yaml

        // Or manually set:
        // versionCode 2
        // versionName "1.0.1"
    }
}
```

### **5. Release Build Commands**

#### **For Play Store (Recommended)**
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build App Bundle
flutter build appbundle --release

# Verify build
ls -la build/app/outputs/bundle/release/
```

#### **For Direct Distribution**
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build split APKs
flutter build apk --release --split-per-abi

# Verify builds
ls -la build/app/outputs/flutter-apk/
```

### **6. Release Checklist**

#### **Pre-Release**
- [ ] Update version in `pubspec.yaml`
- [ ] Test on real devices (not emulator)
- [ ] Verify Agora App ID is correct
- [ ] Test video calling functionality
- [ ] Test offline user list caching
- [ ] Check app permissions work correctly
- [ ] Verify app icons and splash screen

#### **Build**
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build with `flutter build appbundle --release`
- [ ] Verify file size is reasonable (~50-70MB)

#### **Post-Build**
- [ ] Test install on clean device
- [ ] Verify app launches correctly
- [ ] Test core functionality
- [ ] Check for crashes or errors

### **7. Troubleshooting Release Builds**

#### **Build Fails**
```bash
# Clean everything and rebuild
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter build appbundle --release
```

#### **Signing Issues**
```bash
# Verify keystore exists
ls -la android/app/keystore/

# Check key.properties format
cat android/key.properties
```

#### **Size Issues**
```bash
# Analyze APK size
flutter build apk --release --analyze-size

# Build split APKs instead
flutter build apk --release --split-per-abi
```

## 📱 App Flow

1. **Splash Screen** → Professional animated loading
2. **Authentication** → Login with email/password
3. **Home Screen** → Main dashboard with quick actions
4. **Users List** → Browse team members
5. **Video Call** → High-quality video calling experience

## 🌐 Multi-Platform Support

### 📱 Mobile (Android & iOS)
- **Native Performance** with platform-specific optimizations
- **Camera & Microphone** access with proper permissions
- **Background Processing** for incoming calls
- **Push Notifications** support ready

### 💻 Web (Progressive Web App)
- **Cross-browser Compatibility** (Chrome, Firefox, Safari, Edge)
- **WebRTC Support** for real-time video calling
- **Responsive Design** that works on desktop and mobile browsers
- **PWA Features** - installable, offline-capable
- **Browser Permissions** for camera and microphone access
- **No Installation Required** - runs directly in browser

### 🖥️ Desktop (Future Support)
- Ready for Windows, macOS, and Linux deployment
- Same codebase across all platforms

## 🛠️ Technical Stack

### Core Technologies
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language with null safety
- **Agora SDK** - Real-time video calling
- **BLoC** - State management pattern

### Key Dependencies
- `flutter_bloc` - State management
- `agora_rtc_engine` - Video calling SDK
- `go_router` - Navigation and routing
- `get_it` - Dependency injection
- `flutter_secure_storage` - Secure data storage
- `dio` - HTTP client with interceptors
- `cached_network_image` - Image caching
- `sentry_flutter` - Error monitoring

### Development Tools
- `flutter_lints` - Code quality rules
- `build_runner` - Code generation
- `mockito` - Testing framework
- `integration_test` - End-to-end testing

## 🎯 Key Improvements Made

### 1. **Fixed Critical Issues**
- ✅ Resolved navigation problems between screens
- ✅ Fixed video call initialization and display
- ✅ Eliminated loading indicator issues
- ✅ Proper error handling and recovery

### 2. **Enhanced UI/UX**
- ✅ Consistent theming across all screens
- ✅ Professional color scheme and typography
- ✅ Improved user list with modern card design
- ✅ Better dialogs and user interactions
- ✅ Removed duplicate splash screens

### 3. **Architecture Improvements**
- ✅ Industry-standard code organization
- ✅ Proper error handling and logging
- ✅ Secure API integration
- ✅ Offline data caching
- ✅ Professional state management

## 📋 API Integration

### Authentication Endpoints
- `POST /login` - User authentication
- `GET /users` - Fetch user list with pagination

### API Features
- **Automatic retry** on network failures
- **Request/response logging** for debugging
- **Error handling** with user-friendly messages
- **Offline caching** for better user experience

## 🔧 Configuration

### Agora SDK Setup (Detailed Steps)

#### 1. Create Agora Account
1. Visit [Agora.io](https://agora.io) and create a free account
2. Navigate to the **Console** → **Projects**
3. Click **Create** to create a new project
4. Choose **Secured mode: APP ID + Token** for production
5. Copy your **App ID** from the project dashboard

#### 2. Configure Environment Variables
1. **Create `.env` file** in the project root with the following configuration:
   ```env
   # Environment Configuration for Hipster Video Call App

   # API Configuration
   BASE_URL=https://reqres.in/api
   API_TIMEOUT=30000
   API_KEY=reqres-free-v1

   # Agora Configuration
   AGORA_APP_ID=YOUR_ACTUAL_AGORA_APP_ID_HERE
   AGORA_TOKEN=

   # Sentry Configuration (for error monitoring)
   SENTRY_DSN=https://your-sentry-dsn-here

   # App Configuration
   APP_NAME=Hipster Video Call
   APP_VERSION=1.0.0
   DEBUG_MODE=true

   # Cache Configuration
   CACHE_EXPIRY_HOURS=24
   MAX_CACHE_SIZE_MB=50
   ```

2. **⚠️ IMPORTANT**: Replace `YOUR_ACTUAL_AGORA_APP_ID_HERE` with your real Agora App ID
   - **Without a valid App ID, video calling will NOT work**
   - Get your App ID from [Agora Console](https://console.agora.io)
   - **Example**: `AGORA_APP_ID=fd7758b56e414cf28b3b17633186fa69`

3. **Alternative**: Copy from `.env.example` if available:
   ```bash
   cp .env.example .env
   # Then edit .env with your actual Agora App ID
   ```

4. **📝 Note**: The project includes a pre-configured `.env` file with a sample Agora App ID
   - **For testing**: The included App ID should work for basic testing
   - **For production**: Replace with your own App ID from [Agora Console](https://console.agora.io)

#### 3. Platform-Specific Configuration

**Android:**
- Permissions are already configured in `android/app/src/main/AndroidManifest.xml`
- Minimum SDK version: 21 (Android 5.0)

**iOS:**
- Permissions configured in `ios/Runner/Info.plist`
- Minimum iOS version: 9.0

**Web:**
- HTTPS required for camera/microphone access
- Modern browser with WebRTC support needed

### Permissions Required

#### Mobile (Android/iOS)
- `CAMERA` - Video calling
- `RECORD_AUDIO` - Audio in calls
- `INTERNET` - Network access
- `ACCESS_NETWORK_STATE` - Network status

#### Web Browser
- **Camera Permission** - Requested through browser API
- **Microphone Permission** - Requested through browser API
- **Notification Permission** - For incoming call alerts (optional)
- **HTTPS Required** - WebRTC requires secure context

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

## 📦 Build & Deployment

### Android
1. Configure signing in `android/app/build.gradle`
2. Build release APK: `flutter build apk --release`
3. Upload to Google Play Console

### Web Deployment
1. Build for production: `flutter build web --release`
2. Deploy `build/web` folder to any web server
3. Ensure HTTPS for WebRTC functionality
4. Configure CORS if needed for API calls

#### Deployment Options:
- **Firebase Hosting**: `firebase deploy`
- **Netlify**: Drag and drop `build/web` folder
- **Vercel**: Connect GitHub repository
- **GitHub Pages**: Deploy from `build/web` folder
- **Any Web Server**: Upload `build/web` contents

### Store Readiness Checklist
- ✅ App icons and splash screen
- ✅ Proper permissions configuration
- ✅ Release signing setup
- ✅ Privacy policy and terms
- ✅ App store descriptions
- ✅ Screenshots and promotional materials
- ✅ Web PWA manifest configured
- ✅ HTTPS deployment for web version

## 📋 Assumptions & Limitations

### **Assumptions Made:**
- **Network Connectivity**: App assumes stable internet connection for video calls
- **Device Capabilities**: Modern devices with camera and microphone support
- **API Availability**: ReqRes.in API remains accessible for user data
- **Agora Service**: Agora.io service availability and API compatibility
- **Platform Support**: Flutter SDK 3.0+ with latest stable channel
- **Development Environment**: Android Studio/VS Code with Flutter plugin

### **Current Limitations:**
- **Video Call Capacity**: Currently optimized for 1-on-1 calls (can be extended)
- **Authentication**: Uses mock API (ReqRes.in) - not production-ready auth
- **Push Notifications**: Structure ready but not fully implemented
- **Offline Video**: Video calls require internet connection
- **File Sharing**: Not implemented in current version
- **Call Recording**: Not implemented (can be added with Agora Cloud Recording)
- **Screen Sharing**: Basic implementation (mobile-focused)

### **Known Issues:**
- **iOS Simulator**: Video calling may not work properly (use real device)
- **Web HTTPS**: Local development requires HTTPS for camera access
- **Large APK Size**: Universal APK ~152MB, Split APKs ~50MB each (due to Agora SDK native libraries)

## 🔧 Troubleshooting

### **Common Issues & Solutions:**

#### **Build Issues:**
```bash
# Clean and rebuild if facing build errors
flutter clean
flutter pub get
flutter build apk --release
```

#### **Video Call Not Working:**
- ✅ **Check Agora App ID in `.env` file** (most common issue)
  ```bash
  # Verify your .env file contains a valid App ID
  cat .env | grep AGORA_APP_ID
  # Should show: AGORA_APP_ID=your_32_character_app_id
  ```
- ✅ **Verify App ID is valid** (32 characters, alphanumeric)
- ✅ **Restart app after changing `.env`** file
- ✅ Verify internet connection
- ✅ Ensure camera/microphone permissions granted
- ✅ Use real device instead of emulator for testing

#### **Web Version Issues:**
- ✅ Ensure HTTPS (required for WebRTC)
- ✅ Use modern browser (Chrome, Firefox, Safari, Edge)
- ✅ Allow camera/microphone permissions when prompted

#### **Authentication Issues:**
- ✅ Use test credentials: `eve.holt@reqres.in` / `cityslicka`
- ✅ Check network connection to ReqRes.in API

#### **APK Size Too Large:**
```bash
# Build architecture-specific APKs (70% smaller)
flutter build apk --release --split-per-abi

# Results:
# Universal: 152.2MB → Split: 46-50MB each
```

### **Getting Help:**
- Check [Flutter Documentation](https://docs.flutter.dev)
- Review [Agora Flutter SDK Guide](https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter)
- Open an issue in the project repository

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Agora.io** for the excellent video calling SDK
- **Flutter Team** for the amazing framework
- **ReqRes.in** for the mock API service
- **Material Design** for the design system

---

**Built with ❤️ using Flutter**