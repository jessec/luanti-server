# Keep application classes that might be used by reflection
-keep class vip.eduquest.educraft.** { *; }

# Example: Keep native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Add library-specific keep rules if you use libraries that rely on reflection (e.g., Gson, OkHttp, etc.)
