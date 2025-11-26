import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    @State private var showMainBlock = false        // apparition (opacity + léger zoom)
    @State private var robotFloat = false           // rebond / flottement du robot
    @State private var pulseGlow = false            // glow qui pulse
    @State private var showTextAndButton = false    // texte "iakadir" + tagline + bouton

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 80)

                // "iakadir" – arrive après l’anim du bloc central
                if showTextAndButton {
                    Text("iakadir")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.primaryGreen)
                        )
                        .transition(.opacity)
                }

                // BLOC CENTRAL : traits + glow + robot
                ZStack {
                    // Traits larges (proche de ta maquette 479 x 367)
                    Image("trait")
                        .resizable()
                        .aspectRatio(479.12 / 367.41, contentMode: .fit)
                        .frame(width: 340) // ajuste à 360 si tu veux encore plus large

                    // Glow vert derrière le robot
                    RadialGradient(
                        colors: [
                            Color.primaryGreen.opacity(0.9),
                            Color.primaryGreen.opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                    .blur(radius: 30)
                    .opacity(pulseGlow ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: pulseGlow
                    )

                    // Robot – rebond / flottement façon Wall-E
                    Image("robotMain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .offset(y: robotFloat ? -12 : 12)
                        .animation(
                            .interpolatingSpring(stiffness: 120, damping: 10)
                                .repeatForever(autoreverses: true),
                            value: robotFloat
                        )
                }
                .padding(.top, 24)
                // Apparition propre : au centre, pas de déplacement, juste opacity + léger zoom
                .scaleEffect(showMainBlock ? 1.0 : 0.9)
                .opacity(showMainBlock ? 1.0 : 0.0)
                .animation(
                    .easeOut(duration: 1.8),   // plus lent qu’avant
                    value: showMainBlock
                )

                Spacer()

                // Texte + bouton qui fade-in après la splash
                if showTextAndButton {
                    VStack(spacing: 24) {
                        Text("Ton assistant IA,\nau quotidien.")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 306)
                            .padding(.horizontal, 32)

                        Button {
                            onStart()
                        } label: {
                            Text("Commencer")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 66)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            // 1) Apparition du bloc central (traits + robot) – zoom très léger + fade
            showMainBlock = true

            // 2) Lancement des animations continues
            robotFloat = true
            pulseGlow = true

            // 3) Ensuite seulement, apparition du texte + bouton
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showTextAndButton = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
