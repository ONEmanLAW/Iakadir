//
//  LottieView.swift
//  Iakadir
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .playOnce

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)

        // Selon ta version de Lottie, ça peut être LottieAnimationView ou AnimationView
        let animationView = LottieAnimationView(name: name)
        // Si erreur ici, essaie :
        // let animationView = AnimationView(name: name)

        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Lancer l'animation
        animationView.play()

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // rien à mettre ici pour l'instant
    }
}
