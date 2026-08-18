# ACRCloud Universal SDK.
#
# The SDK resolves its native methods through JNI, which looks classes and
# methods up by their fully qualified names at runtime. If R8 renames them the
# app crashes with UnsatisfiedLinkError — and only in release builds, so it is
# easy to ship by accident. The config classes are public-field bags that the
# obfuscated engine reads, so keep the whole package.
-keep class com.acrcloud.rec.** { *; }
-keepclassmembers class com.acrcloud.rec.** {
    native <methods>;
}
-dontwarn com.acrcloud.rec.**
