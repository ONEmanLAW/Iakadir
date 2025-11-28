//
//  HapticsManager.swift
//  Iakadir
//
//  Created by digital on 28/11/2025.
//

// this is for vibrations

import Foundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    /// Haptique léger (si tu veux l'utiliser ailleurs)
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Haptique plus "heavy" + un peu plus long (double impact rapide)
    func strongTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()

        // petit deuxième impact très proche pour donner une impression un peu plus "longue"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            generator.impactOccurred()
        }
    }

    /// Haptique de succès (au cas où pour plus tard)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

