//
//  PaywallView.swift
//  Iakadir
//
//  Created by digital on 26/11/2025.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    enum BillingPlan {
        case weekly
        case yearly
    }

    @State private var selectedPlan: BillingPlan = .weekly
    @State private var showAnimation = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {

                headerSection

                titleAndFeaturesSection

                plansSection

                Spacer()

                continueButton

                footerSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .opacity(showAnimation ? 0 : 1)
            .animation(.easeInOut(duration: 0.25), value: showAnimation)

            if showAnimation {
                Color.black.ignoresSafeArea()

                LottieView(name: "sparkles-paywall", loopMode: .playOnce)
                    .frame(width: 380, height: 380)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }


    private var headerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black)
                .overlay(
                    Image("splashBackground")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.4)
                        .clipped()
                        .offset(x: 40, y: -10)
                )
                .frame(height: 240)

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                            )
                    }

                    Spacer()

                    Button {
                        // plus tard : restauration d’achats
                    } label: {
                        Text("Déjà abonné ?")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.5))
                        .blur(radius: 40)
                        .frame(width: 180, height: 180)

                    Image("robotMain")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                }
                .padding(.bottom, 12)
            }
        }
    }


    private var titleAndFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text("iakadir")
                    .foregroundColor(.white)
                    .font(.system(size: 26, weight: .semibold))
                Text("PRO")
                    .foregroundColor(Color.primaryGreen)
                    .font(.system(size: 26, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "sparkles", text: "Access to all features")
                FeatureRow(icon: "brain.head.profile", text: "Powered by ChatGPT-4")
                FeatureRow(icon: "text.bubble", text: "Unlimited message chat")
                FeatureRow(icon: "doc.text.magnifyingglass", text: "More detailed answers")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: 14) {
            weeklyPlanCard
            yearlyPlanCard
        }
    }

    private var cardBackground: Color {
        Color(red: 20/255, green: 20/255, blue: 35/255)
    }

    // — carte hebdomadaire
    private var weeklyPlanCard: some View {
        let isSelected = (selectedPlan == .weekly)

        return VStack(alignment: .leading, spacing: 6) {
            Text("3 jours gratuits, puis")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))

            Text("$5,99 / semaine, annulable facilement")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.primaryGreen : Color.white.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        .onTapGesture {
            selectedPlan = .weekly
        }
    }

    // — carte annuelle
    private var yearlyPlanCard: some View {
        let isSelected = (selectedPlan == .yearly)

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Annuel")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                Text("$39,99 / an")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Économise 89%")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : Color.primaryGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.primaryGreen : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(Color.primaryGreen,
                                        lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.primaryGreen : Color.white.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        .onTapGesture {
            selectedPlan = .yearly
        }
    }

    // MARK: - Bouton continuer

    private var continueButton: some View {
        Button {
            // On lance l'anim + timer pour la cacher
            withAnimation(.easeInOut(duration: 0.25)) {
                showAnimation = true
            }

            // Durée de ton Lottie (ajuste 2.0 en fonction de la vraie durée)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showAnimation = false
                }
            }
        } label: {
            Text("Continuer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.primaryGreen)
                )
        }
        .disabled(showAnimation)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack(spacing: 8) {
            Button {
                // ouvrir page plus tard
            } label: {
                Text("Confidentialité")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Text("·")
                .foregroundColor(.white.opacity(0.4))

            Button {
                // ouvrir page plus tard
            } label: {
                Text("Conditions d’utilisation")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Feature row

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.primaryGreen)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    PaywallView()
}
