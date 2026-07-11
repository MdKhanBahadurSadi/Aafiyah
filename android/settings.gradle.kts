pluginManagement {
    try {
        val pe = Class.forName("java.lang.ProcessEnvironment")
        val envField = pe.getDeclaredField("theCaseInsensitiveEnvironment")
        envField.isAccessible = true
        (envField.get(null) as? MutableMap<String, String>)?.apply {
            remove("ANDROID_PREFS_ROOT")
            remove("ANDROID_SDK_HOME")
        }
    } catch (e: Exception) {}
    System.setProperty("ANDROID_HOME", "C:\\Users\\MDKHAN~1\\AppData\\Local\\Android\\Sdk")
    System.setProperty("ANDROID_SDK_ROOT", "C:\\Users\\MDKHAN~1\\AppData\\Local\\Android\\Sdk")
    System.setProperty("user.home", "C:\\Users\\Md Khan Bahadur Sadi")
    System.setProperty("android.signing.debug.storeFile", "D:\\Aafiyah\\android\\app\\debug.keystore")
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.3.2" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}

include(":app")
