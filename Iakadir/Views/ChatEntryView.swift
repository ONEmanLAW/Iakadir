//
//  ChatEntryView.swift
//  Iakadir
//
//  Created by digital on 28/12/2025.
//

import SwiftUI

/// Routeur central : selon le mode, on affiche la bonne view.
struct ChatEntryView: View {
    let mode: ChatMode
    let conversationID: UUID?

    var body: some View {
        switch mode {
        case .generateImage:
            GenerateImageView()
        case .assistant, .summarizeAudio:
            ChatView(mode: mode, conversationID: conversationID)
        }
    }
}
