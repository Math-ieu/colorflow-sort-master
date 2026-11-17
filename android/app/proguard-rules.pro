# Flutter Proguard Rules for ColorFlow Sort Master
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.**

# Keep Flutter Activity & Application
-keep public class * extends io.flutter.embedding.android.FlutterActivity
-keep public class * extends io.flutter.embedding.android.FlutterApplication
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep ColorFlow Sort Master main entrypoint
-keep class com.colorflow.sortmaster.** { *; }
