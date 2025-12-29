import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    @State private var showMainBlock = false   
    @State private var robotFloat = false
    @State private var pulseGlow = false
    @State private var showTextAndButton = false
    @State private var isExiting = false

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

              
                ZStack {
                 
                    Image("trait")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()

                    
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

             
                    Image("robotMain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .offset(y: robotFloat ? -6 : 6)
                        .offset(y: -6)
                        .animation(
                            .easeInOut(duration: 2.4)
                                .repeatForever(autoreverses: true),
                            value: robotFloat
                        )
                }
                .padding(.top, 24)
                .scaleEffect(showMainBlock ? 1.0 : 0.9)
                .opacity(showMainBlock ? 1.0 : 0.0)
                .animation(
                    .easeOut(duration: 1.8),
                    value: showMainBlock
                )

                Spacer()

                if showTextAndButton {
                    VStack(spacing: 24) {
                        Text("Ton assistant IA,\nau quotidien.")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 306)
                            .padding(.horizontal, 32)

                        Button {
                            HapticsManager.shared.strongTap()

                            SoundManager.shared.playStartSound()

                            withAnimation(.easeInOut(duration: 0.4)) {
                                isExiting = true
                            }

                            
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
            .opacity(isExiting ? 0 : 1)
        }
        .onAppear {
            
            showMainBlock = true

            
            pulseGlow = true

        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showTextAndButton = true
                }
            }

            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                robotFloat = true
            }
        }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
