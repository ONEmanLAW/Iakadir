import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    @State private var showMainBlock = false        // apparition (opacity + léger zoom)
    @State private var robotFloat = false           // flottement du robot (après les anims)
    @State private var pulseGlow = false            // glow qui pulse
    @State private var showTextAndButton = false    // texte "iakadir" + tagline + bouton

    @State private var isExiting = false            // fade out avant d’aller au login

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 80)

                if showTextAndButton {
                    Text("Iakadir")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.primaryGreen)
                        )
                        .offset(y: 28)
                        .transition(.opacity)
                }

                // BLOC CENTRAL : traits + glow + robot
                ZStack {
                    // Traits qui prennent toute la largeur de l’écran
                    Image("trait")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()

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

                    // Robot – flottement très léger + un poil plus haut
                    Image("robotMain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .offset(y: robotFloat ? -6 : 6)   // flottement léger
                        .offset(y: -6)                    // léger décalage vers le haut
                        .animation(
                            .easeInOut(duration: 2.4)
                                .repeatForever(autoreverses: true),
                            value: robotFloat
                        )
                }
                .padding(.top, 24)
                // Apparition propre : au centre, opacity + léger zoom
                .scaleEffect(showMainBlock ? 1.0 : 0.9)
                .opacity(showMainBlock ? 1.0 : 0.0)
                .animation(
                    .easeOut(duration: 1.8),
                    value: showMainBlock
                )

                Spacer()

                // Texte + bouton qui fade-in après la splash
                if showTextAndButton {
                    VStack(spacing: 24) {
                        Text("Ton assistant IA,\nau quotidien.")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 306)
                            .padding(.horizontal, 32)

                        Button {
                            // 0) VIBRATION forte (heavy + un peu plus longue)
                            HapticsManager.shared.strongTap()

                            // 1) jouer le son une seule fois
                            SoundManager.shared.playStartSound()

                            // 2) lancer le fade out
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isExiting = true
                            }

                            // 3) après le fade out, appeler onStart() pour passer au Login
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                onStart()
                            }
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
                    .padding(.bottom, 70)
                    .offset(y: -60)
                    .transition(.opacity)
                }
            }
            // Fade out global avant de changer d’écran
            .opacity(isExiting ? 0 : 1)
        }
        .onAppear {
            // 1) Apparition du bloc central (traits + robot) – léger zoom + fade
            showMainBlock = true

            // 2) Glow commence direct (loop)
            pulseGlow = true

            // 3) Après la splash, apparition du texte + bouton
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showTextAndButton = true
                }
            }

            // 4) Quand tout le set d’anim est fini → on lance le flottement léger du robot
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                robotFloat = true
            }
        }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
