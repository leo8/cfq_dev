import Flutter
import UIKit
import GooglePlaces
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    var flutterChannel: FlutterMethodChannel? // Déclaration de flutterChannel

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // API Google Places
        GMSPlacesClient.provideAPIKey("AIzaSyA65gP0gnZAjqrrSkQTZB60svG86LJqMDE")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
