//
//  ChatView.swift
//  Iakadir
//
//  Created by digital on 24/11/2025.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {

                header

                chatContent

                inputBar
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }


    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Text("Parler à l’IA")
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            HStack(spacing: 6) {
                Text("GPT-4")
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.primaryGreen)
            )
            .foregroundColor(.black)
        }
        .padding(.top, 8)
    }


    private var chatContent: some View {
        ScrollView {
            VStack(spacing: 16) {

                VStack(spacing: 16) {

                    MessageBubble(
                        text: "Hello, moi c’est Ugo sans H.\nQuelle est ta question ?",
                        isUser: false,
                        isLargeBlock: false
                    )

                    MessageBubble(
                        text: "Est-ce que Kotlin en XML est plus simple que SwiftUI ?",
                        isUser: true,
                        isLargeBlock: false
                    )

                    // grosse réponse IA
                    VStack(spacing: 0) {
                        MessageBubble(
                            text: """
Écoute-moi bien petit con, la prochaine fois que tu me parles de XML, je te fais avaler ton PC.

Donc, retourne faire du SwiftUI et ne me parle plus jamais d’Android, sinon ça va très mal se passer pour toi.

Sinon, pour être plus sérieux :

La réponse est évidemment… NON.
""",
                            isUser: false,
                            isLargeBlock: true
                        )

                       
                        HStack(spacing: 32) {
                            ActionChip(icon: "arrow.clockwise", title: "Régénérer")
                            ActionChip(icon: "doc.on.doc", title: "Copier")
                            ActionChip(icon: "square.and.arrow.up", title: "Partager")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(Color.black.opacity(0.9))
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 4)
        }
    }


    private var inputBar: some View {
        HStack {
            Text("Écris une demande ici")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 15))
                .padding(.leading, 20)

            Spacer()

            Button {
                
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 42, height: 42)

                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.trailing, 6)
            }
        }
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16)) // genre dark bleu/violet
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}


struct MessageBubble: View {
    let text: String
    let isUser: Bool
    let isLargeBlock: Bool

    var body: some View {
        HStack {
            if isUser { Spacer() }

            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(isUser ? Color(red: 0.05, green: 0.06, blue: 0.18) : Color(red: 0.13, green: 0.13, blue: 0.15))
                )
                .frame(maxWidth: isLargeBlock ? .infinity : 280, alignment: .leading)

            if !isUser { Spacer() }
        }
    }
}

struct ActionChip: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(Color.primaryGreen)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
