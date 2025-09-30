# Flutter ProGuard Rules for Hipster Video Call

# Keep Flutter Engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep Agora SDK
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Keep Dart VM
-keep class com.google.dart.** { *; }
-dontwarn com.google.dart.**

# Keep Android Support Libraries
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep JSON serialization
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Aggressive optimization for smaller APK
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Remove unused code more aggressively
-dontwarn **
-ignorewarnings

# Shrink more aggressively
-repackageclasses ''
-allowaccessmodification
