import SwiftUI
import UIKit

enum ImageStyle: String, CaseIterable, Identifiable {
    case surreal = "Irréaliste"
    case realistic = "Réaliste"
    case cinematic = "Cinématique"
    case anime = "Dessin animé"
    case illustration = "Illustration"
    case threeD = "3D"
    case pixel = "Pixel Art"

    var id: String { rawValue }

    var promptHint: String {
        switch self {
        case .surreal: return "surreal, dreamlike, unexpected elements"
        case .realistic: return "photorealistic, natural lighting, high detail"
        case .cinematic: return "cinematic lighting, film still, dramatic mood"
        case .anime: return "cartoon/anime style, clean lines, vibrant colors"
        case .illustration: return "digital illustration, stylized, artistic"
        case .threeD: return "3D render, soft shadows, high detail"
        case .pixel: return "pixel art, 16-bit, retro game style"
        }
    }

    var lowercaseLabel: String { rawValue.lowercased() }
}

struct GenerateImageView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedStyle: ImageStyle = .surreal

    @State private var prompt: String = ""
    @State private var lastPrompt: String = ""

    // On fige le style au moment de l'envoi
    @State private var submittedStyle: ImageStyle = .surreal

    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage? = nil

    @State private var hasSubmittedPrompt: Bool = false

    // ✅ Pour différencier “envoyer” vs “régénérer”
    @State private var lastActionWasRegenerate: Bool = false

    // Une seule proposition comme la maquette
    private let suggestion: String = "Des chèvres dans l’espace"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                stylePickerRow

                // suggestion avant 1er prompt
                if !hasSubmittedPrompt {
                    suggestionChip
                }

                promptChip

                if hasSubmittedPrompt {
                    imageCard
                }

                Spacer(minLength: 0)
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
            Button { dismiss() } label: {
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

            Text("Générer une image")
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
            .background(Capsule().fill(Color.primaryGreen))
            .foregroundColor(.black)
        }
        .padding(.top, 8)
    }

    // Style picker avec underline comme ta capture
    private var stylePickerRow: some View {
        Menu {
            ForEach(ImageStyle.allCases) { style in
                Button { selectedStyle = style } label: { Text(style.rawValue) }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Style de l’image générée")
                        .foregroundColor(.white.opacity(0.65))
                        .font(.system(size: 15, weight: .medium))

                    Rectangle()
                        .fill(Color.primaryGreen.opacity(0.9))
                        .frame(width: 170, height: 2)
                        .cornerRadius(2)
                }

                Spacer()

                Text(selectedStyle.rawValue)
                    .foregroundColor(Color.primaryGreen)
                    .font(.system(size: 15, weight: .semibold))

                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.55))
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
            )
        }
    }

    private var suggestionChip: some View {
        Button {
            submitPrompt(suggestion)
        } label: {
            Text(suggestion)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        .background(Capsule().fill(Color.black.opacity(0.10)))
                )
        }
        .disabled(isGenerating)
        .opacity(isGenerating ? 0.6 : 1)
    }

    private var promptChip: some View {
        Group {
            if hasSubmittedPrompt && !lastPrompt.isEmpty {
                Text(lastPrompt)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            .background(Capsule().fill(Color.black.opacity(0.15)))
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Color.clear.frame(height: 8)
            }
        }
    }

    private var imageCard: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.07, green: 0.08, blue: 0.16))

                if let uiImage = generatedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(10)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 34))
                            .foregroundColor(.white.opacity(0.35))

                        Text(isGenerating ? "Génération en cours…" : (lastActionWasRegenerate ? quotaMessageForRegenerate() : quotaMessageForSubmit()))
                            .foregroundColor(.white.opacity(0.75))
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                    }
                }

                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
            .frame(height: 360)

            HStack {
                Button { regenerate() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Régénérer")
                    }
                    .foregroundColor(Color.primaryGreen)
                    .font(.system(size: 15, weight: .semibold))
                }
                .disabled(isGenerating || lastPrompt.isEmpty)

                Spacer()

                Button { downloadImage() } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.down")
                        Text("Télécharger")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.primaryGreen))
                }
                .disabled(generatedImage == nil)
                .opacity(generatedImage == nil ? 0.5 : 1)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var inputBar: some View {
        HStack {
            TextField("Écris une demande ici", text: $prompt)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .padding(.leading, 20)

            Spacer(minLength: 8)

            Button {
                let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                submitPrompt(trimmed)
                prompt = ""
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
            .disabled(isGenerating || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity((isGenerating || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1)
        }
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.07, green: 0.08, blue: 0.16))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func quotaMessageForSubmit() -> String {
        "Votre image \(submittedStyle.lowercaseLabel) a bien été prise en compte par GPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
    }

    private func quotaMessageForRegenerate() -> String {
        "Votre image \(submittedStyle.lowercaseLabel) a bien été régénérée et prise en compte par GPT, mais il n’y a plus assez de crédit sur le compte API, flemme de payer hehe."
    }

    private func submitPrompt(_ text: String) {
        guard !isGenerating else { return }

        hasSubmittedPrompt = true
        lastPrompt = text

        // ✅ Le style choisi impacte le prompt (et le message)
        submittedStyle = selectedStyle

        // ✅ C’est un “envoi”, pas une regen
        lastActionWasRegenerate = false

        isGenerating = true
        generatedImage = nil

        // MOCK : on “termine” sans image => message quota
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isGenerating = false
            generatedImage = nil
        }
    }

    private func regenerate() {
        guard !lastPrompt.isEmpty, !isGenerating else { return }

        lastActionWasRegenerate = true
        isGenerating = true
        generatedImage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isGenerating = false
            generatedImage = nil
        }
    }

    private func downloadImage() {
        guard let img = generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}

#Preview {
    GenerateImageView()
}
