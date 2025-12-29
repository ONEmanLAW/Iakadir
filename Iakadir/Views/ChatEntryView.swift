//
//  ChatEntryView.swift
//  Iakadir
//
//  Created by digital on 28/12/2025.
//

import SwiftUI

struct ChatEntryView: View {
    let mode: ChatMode
    let conversationID: UUID?

    var body: some View {
        switch mode {
        case .assistant:
            ChatView(conversationID: conversationID)

        case .summarizeAudio:
            SummarizeAudioView(conversationID: conversationID)

        case .generateImage:
            GenerateImageView(conversationID: conversationID)
        }
    }
}

#Preview {
    NavigationStack {
        ChatEntryView(mode: .assistant, conversationID: nil)
            .environmentObject(ChatStore(userID: "preview-user"))
    }
}

