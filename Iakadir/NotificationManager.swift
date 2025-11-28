//
//  NotificationManager.swift
//  Iakadir
//

import Foundation
import UserNotifications
import UIKit

final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    /// Flag observé par les vues pour ouvrir le Paywall après un tap sur notif
    @Published var navigateToPaywallFromNotification: Bool = false

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Autorisation

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erreur autorisation notifs:", error)
            } else {
                print("Notifications granted: \(granted)")
            }
        }
    }

    // MARK: - DEBUG rapide (optionnel)

    func sendDebugNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test iakadir PRO"
        content.body = "Si tu vois cette notif, les notifs locales fonctionnent ✅."
        content.sound = .default
        content.userInfo = ["type": "debug"]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "debug_pro",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur debug notif:", error)
            }
        }
    }

    // MARK: - Rappel PRO en background

    /// Planifie UNE notif (dans 30s en debug) quand l’app passe en background.
    /// Plus tard tu pourras passer à 12h / 24h pour 2 notifs par jour.
    func scheduleBackgroundProReminder(isLoggedIn: Bool, username: String?) {
        let center = UNUserNotificationCenter.current()

        // On nettoie d’abord l’ancienne pour éviter les doublons
        center.removePendingNotificationRequests(withIdentifiers: ["pro_reminder"])

        let loggedName = username ?? "toi"

        // Messages quand l’utilisateur est déjà connecté
        let loggedInMessages: [String] = [
            "Hey \(loggedName), iakadir PRO t’attend : conversations illimitées et résumés plus longs.",
            "\(loggedName), et si tu passais à iakadir PRO ? Profite à fond de ton assistant IA.",
            "Continue ce que tu as commencé avec iakadir PRO : plus de limites, plus de puissance."
        ]

        // Messages quand il n’est pas connecté, mais a déjà lancé l’app une fois
        let loggedOutMessages: [String] = [
            "Reviens te connecter à iakadir pour découvrir l’offre PRO.",
            "Tu as installé iakadir, mais tu ne profites pas encore de PRO. Connecte-toi pour voir.",
            "Connecte-toi ou crée un compte pour débloquer iakadir PRO."
        ]

        let messages = isLoggedIn ? loggedInMessages : loggedOutMessages
        guard let message = messages.randomElement() else { return }

        let content = UNMutableNotificationContent()
        content.title = "iakadir PRO"
        content.body = message
        content.sound = .default
        content.userInfo = [
            "type": "pro_reminder"
        ]

        // DEBUG : 30s. En prod → par ex. 12h (12 * 3600)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 30,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "pro_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Erreur planification notif PRO:", error)
            }
        }
    }

    func cancelBackgroundProReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["pro_reminder"])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    // Quand une notif arrive alors que l’app est ouverte
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // 👉 On NE montre rien quand l’app est en foreground
        if UIApplication.shared.applicationState == .active {
            completionHandler([])
        } else {
            completionHandler([.banner, .sound])
        }
    }

    // Quand l’utilisateur touche la notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        if userInfo["type"] as? String == "pro_reminder" {
            DispatchQueue.main.async {
                // L’UI (ContentView/HomeView) gérera l’ouverture du Paywall
                self.navigateToPaywallFromNotification = true
            }
        }

        completionHandler()
    }
}
