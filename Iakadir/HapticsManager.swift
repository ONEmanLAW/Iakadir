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


    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    func strongTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()

       
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

