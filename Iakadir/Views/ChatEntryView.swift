//
//  ChatEntryView.swift
//  Iakadir
//
//  Created by digital on 28/12/2025.
//

import SwiftUI

struct ChatEntryView: View {
    let mode: ChatMode

    var body: some View {
        switch mode {
        case .assistant:
            ChatView(mode: .assistant, conversationID: nil)

        case .summarizeAudio:
            ChatView(mode: .summarizeAudio, conversationID: nil)

        case .generateImage:
            GenerateImageView(conversationID: nil)
        }
    }
}

#Preview {
    NavigationStack {
        ChatEntryView(mode: .assistant)
            .environmentObject(ChatStore(userID: "preview-user"))
    }
}

