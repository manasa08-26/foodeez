plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.foodeez.foodeez_flutter"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.foodeez.foodeez_flutter"
        minSdk = flutter.minSdkVersion        // flutter_secure_storage requires 23+
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Required for file_picker on older Android
        multiDexEnabled = true
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isDebuggable = true
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Use debug signing for now — replace with keystore for production
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Provides the Play Core split-install classes Flutter references
    // during R8 minification (deferred components shim).
    implementation("com.google.android.play:core:1.10.3")
}

flutter {
    source = "../.."
}
