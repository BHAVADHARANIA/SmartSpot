plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.smartspot.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enables core library desugaring for compatibility
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.smartspot.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // No signingConfig lines here. GitHub Actions will handle signing.
        }
    }
    
    dependencies {
        // Required dependency library for core desugaring to function
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    }
}

flutter {
    source = "../.."
}
