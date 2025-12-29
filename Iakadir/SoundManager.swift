//
//  SoundManager.swift
//  Iakadir
//
//  Created by digital on 27/11/2025.
//

import Foundation
import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playStartSound() {
        guard let url = Bundle.main.url(forResource: "start", withExtension: "mp3") else {
            print("start.mp3 non")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Erreur AVAudioPlayer:", error)
        }
    }
}
