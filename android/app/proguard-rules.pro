# Flutter Local Notifications plugin
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keep class com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin { *; }

# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class com.google.gson.stream.** { *; }
-keep class com.google.gson.internal.** { *; }
-keep class com.google.gson.annotations.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# Prevent R8 from obfuscating the notification model classes
-keep class com.dexterous.flutterlocalnotifications.models.NotificationDetails { *; }
-keep class com.dexterous.flutterlocalnotifications.models.NotificationChannelDetails { *; }
-keep class com.dexterous.flutterlocalnotifications.models.NotificationChannelAction { *; }
-keep class com.dexterous.flutterlocalnotifications.models.NotificationChannelGroupDetails { *; }
-keep class com.dexterous.flutterlocalnotifications.models.PersonDetails { *; }
-keep class com.dexterous.flutterlocalnotifications.models.StyleInformation { *; }
-keep class com.dexterous.flutterlocalnotifications.models.BigTextStyleInformation { *; }
-keep class com.dexterous.flutterlocalnotifications.models.BigPictureStyleInformation { *; }
-keep class com.dexterous.flutterlocalnotifications.models.InboxStyleInformation { *; }
-keep class com.dexterous.flutterlocalnotifications.models.MessagingStyleInformation { *; }
-keep class com.dexterous.flutterlocalnotifications.models.MessageDetails { *; }