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

        UNUserNotificationCenter.current().delegate = self

        // Actions de notification
        let validateAction = UNNotificationAction(
            identifier: "validate_action",
            title: "Ce soir ça turn",
            options: []
        )

        let cancelAction = UNNotificationAction(
            identifier: "cancel_action",
            title: "Dodo ce soir",
            options: []
        )

        // Catégorie de notification
        let category = UNNotificationCategory(
            identifier: "longPressCategory",
            actions: [validateAction, cancelAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Enregistrer la catégorie
        UNUserNotificationCenter.current().setNotificationCategories([category])

        // Initialisation de FlutterMethodChannel
        if let controller = window?.rootViewController as? FlutterViewController {
            flutterChannel = FlutterMethodChannel(
                name: "notifications_channel",
                binaryMessenger: controller.binaryMessenger
            )

            // Gestion des appels Flutter
            flutterChannel?.setMethodCallHandler { [weak self] (call, result) in
                if call.method == "scheduleNotification" {
                    self?.scheduleNotification()
                    result("Notification planifiée avec succès")
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        // API Google Places
        GMSPlacesClient.provideAPIKey("AIzaSyA65gP0gnZAjqrrSkQTZB60svG86LJqMDE")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Méthode pour planifier la notification
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Ca turn ce soir ?"
        content.body = "Restes longtemps appuyé pour répondre"
        content.categoryIdentifier = "longPressCategory" // Utilisation de la catégorie définie
        content.sound = .default

        // Déclenchement après 5 secondes
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Demande de notification
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Erreur de planification de notification : \(error.localizedDescription)")
            } else {
                print("Notification planifiée avec succès")
            }
        }
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "validate_action":
            print("Action de validation déclenchée")
            flutterChannel?.invokeMethod("validate_action", arguments: nil)
        case "cancel_action":
            print("Action d'annulation déclenchée")
            flutterChannel?.invokeMethod("cancel_action", arguments: nil)
        case UNNotificationDefaultActionIdentifier:
            print("Corps de la notification cliqué - Ignoré")
        default:
            print("Aucune action personnalisée déclenchée")
        }
        completionHandler()
    }
}
