//
//  ShakeDetector.swift
//  Iakadir
//

import SwiftUI
import UIKit

// UIViewController qui détecte les secousses
final class ShakeViewController: UIViewController {
    var onShake: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        if motion == .motionShake {
            onShake?()
        }
    }
}

// Wrapper SwiftUI pour utiliser ShakeViewController
struct ShakeDetector: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let vc = ShakeViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}
