# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Drift / SQLite ProGuard Rules
-keep class sqlite3.** { *; }
-keep class com.simonbinder.sqlite3_flutter_libs.** { *; }

# Home Widget ProGuard Rules
-keep class es.antonborri.home_widget.** { *; }
-keep class com.haider.surrah.** { *; }

# AndroidX and Material
-dontwarn androidx.**
-dontwarn com.google.android.play.core.**
-keep class androidx.lifecycle.DefaultLifecycleObserver
