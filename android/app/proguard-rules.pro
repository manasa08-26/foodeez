# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Socket.IO
-keep class io.socket.** { *; }
-keep class com.github.nkzawa.** { *; }

# Encrypt / Bouncy Castle
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Google Fonts
-keep class com.google.android.gms.** { *; }

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Google Play Core (deferred components / dynamic delivery)
# Flutter references these at compile time even when deferred components
# are not used. Suppress the R8 "missing class" errors.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# General
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
