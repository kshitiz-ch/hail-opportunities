package `in`.wealthy.android.advisor

import io.flutter.app.FlutterApplication

class Application : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        // Removed deprecated FlutterMain.startInitialization - no longer needed in embedding v2
        
        // Note: Firebase messaging background service and plugin registration
        // is now handled automatically by Flutter's Android embedding v2
        // No manual plugin registration needed
    }

    // Removed deprecated registerWith method - plugin registration is now automatic
    // in Flutter Android embedding v2. Plugins are registered via:
    // - pubspec.yaml dependencies
    // - Automatic plugin registration in GeneratedPluginRegistrant
    // - Plugin-specific initialization in MainActivity if needed
}
