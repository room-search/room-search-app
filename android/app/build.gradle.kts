plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseStoreFileEnv: String? = System.getenv("RELEASE_STORE_FILE")
val releaseStorePasswordEnv: String? = System.getenv("RELEASE_STORE_PASSWORD")
val releaseKeyAliasEnv: String? = System.getenv("RELEASE_KEY_ALIAS")
val releaseKeyPasswordEnv: String? = System.getenv("RELEASE_KEY_PASSWORD")
val hasReleaseKeystore: Boolean =
    !releaseStoreFileEnv.isNullOrBlank() &&
    !releaseStorePasswordEnv.isNullOrBlank() &&
    !releaseKeyAliasEnv.isNullOrBlank() &&
    !releaseKeyPasswordEnv.isNullOrBlank()

android {
    namespace = "dev.roomsearch.room_search"
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
        applicationId = "dev.roomsearch.room_search"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        val kakaoNativeAppKey: String =
            (project.findProperty("kakao.native.app.key") as? String)
                ?: System.getenv("KAKAO_NATIVE_APP_KEY")
                ?: ""
        manifestPlaceholders["kakaoNativeAppKey"] = kakaoNativeAppKey
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(releaseStoreFileEnv!!)
                storePassword = releaseStorePasswordEnv
                keyAlias = releaseKeyAliasEnv
                keyPassword = releaseKeyPasswordEnv
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
