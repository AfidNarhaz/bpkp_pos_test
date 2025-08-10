##################################################
# ProGuard Rules untuk BPKP POS App
##################################################

# ========== Flutter Core ==========
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Jaga MainActivity agar tidak dihapus/rename
-keep class com.example.bpkp_pos_test.MainActivity { *; }

# ========== WorkManager & Background Task ==========
-keep class androidx.work.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }

# ========== Database Lokal (sqflite / sqlite) ==========
# Hindari obfuscate SQLite database helper & model
-keep class android.database.sqlite.** { *; }
-keepclassmembers class * extends android.database.sqlite.SQLiteOpenHelper { *; }
-keep class com.example.bpkp_pos_test.database.** { *; }

# ========== JSON Parsing (Gson / Manual Decode) ==========
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class com.google.gson.annotations.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ========== Optional: Firebase (jaga-jaga) ==========
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ========== Hindari Warning ==========
-dontwarn io.flutter.embedding.**
-dontwarn com.google.gson.**
-dontwarn androidx.work.**
-dontwarn android.database.sqlite.**
