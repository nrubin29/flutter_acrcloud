group = "com.noahzrubin.flutter_acrcloud"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "com.noahzrubin.flutter_acrcloud"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24

        // The ACRCloud SDK resolves JNI methods by name, so consumers must not
        // let R8 rename them. Shipping the rules here applies them automatically.
        consumerProguardFiles("consumer-rules.pro")
    }

    packaging {
        // Keep the .so files uncompressed and page-aligned. The bundled SDK is
        // built against NDK 29 with 16 KB alignment, which Android 16 requires.
        jniLibs.useLegacyPackaging = false
    }

}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // ACRCloud Universal SDK. The matching libACRCloudUniversalEngine.so files
    // live in src/main/jniLibs/<abi>/.
    implementation(files("libs/acrcloud-universal-sdk-1.3.33.jar"))
}
