import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

/** True when building a release artifact (APK/AAB). Play Console rejects debug-signed uploads. */
val releaseArtifactTaskRequested =
    gradle.startParameter.taskNames.any { task ->
        task.contains("assembleRelease", ignoreCase = true) ||
            task.contains("bundleRelease", ignoreCase = true)
    }

if (!keystorePropertiesFile.exists() && releaseArtifactTaskRequested) {
    throw GradleException(
        "Release signing is not configured: missing android/key.properties. " +
            "Copy android/key.properties.example to android/key.properties, add your upload keystore " +
            "(storeFile, storePassword, keyPassword, keyAlias), put the .jks file in android/, then rebuild. " +
            "Google Play does not accept debug-signed bundles."
    )
}

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
    val storePath = keystoreProperties.getProperty("storeFile")
    val storeFile = storePath?.let { rootProject.file(it) }
    if (storeFile == null || !storeFile.isFile) {
        throw GradleException(
            "Release signing: key.properties storeFile must point to an existing keystore file. " +
                "storeFile=$storePath resolved=${storeFile?.absolutePath}"
        )
    }
    listOf("keyAlias", "keyPassword", "storePassword").forEach { key ->
        if (keystoreProperties.getProperty(key).isNullOrBlank()) {
            throw GradleException("Release signing: key.properties is missing or empty: $key")
        }
    }
}

android {
    namespace = "com.vsoftai.coloros"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vsoftai.coloros"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Required for mobile_scanner plugin
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storePassword = keystoreProperties.getProperty("storePassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { storePath ->
                    rootProject.file(storePath)
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}
