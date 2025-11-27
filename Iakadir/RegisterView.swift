//
//  RegisterView.swift.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPassword = false
    
    // 🔥 États pour les animations (mêmes que sur LoginView)
    @State private var glow = false
    @State private var floatRobot = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.top, 16)

                VStack(spacing: 16) {
                    ZStack {
                        // 🌟 Halo vert animé
                        Circle()
                            .fill(Color.primaryGreen.opacity(glow ? 0.9 : 0.3))
                            .frame(width: 160, height: 160)
                            .blur(radius: 60)
                            .scaleEffect(glow ? 1.05 : 0.95)
                            .animation(
                                .easeInOut(duration: 1.8)
                                    .repeatForever(autoreverses: true),
                                value: glow
                            )

                        // 🤖 Robot qui flotte
                        Image("robotMain")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .offset(y: floatRobot ? -8 : 8)
                            .animation(
                                .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: floatRobot
                            )
                    }
                    .onAppear {
                        glow = true
                        floatRobot = true
                    }

                    Text("Inscris-toi")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Text("Tu as déjà un compte ?")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        Button("Connecte-toi") {
                            dismiss()
                        }
                        .foregroundColor(.primaryGreen)
                        .font(.system(size: 14, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 16) {

                    // Username
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nom d’utilisateur")
                            .foregroundColor(.gray)
                            .font(.system(size: 13))

                        HStack(spacing: 12) {
                            Image(systemName: "person")
                                .foregroundColor(.primaryGreen)

                            TextField("Ton pseudo", text: $auth.username)
                                .textInputAutocapitalization(.never)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .foregroundColor(.gray)
                            .font(.system(size: 13))

                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.primaryGreen)

                            TextField("ton.email@mail.com", text: $auth.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }

                    // Mot de passe
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mot de passe")
                            .foregroundColor(.gray)
                            .font(.system(size: 13))

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.primaryGreen)

                            if showPassword {
                                TextField("Mot de passe", text: $auth.password)
                            } else {
                                SecureField("Mot de passe", text: $auth.password)
                            }

                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Button {
                    Task {
                        await auth.register()

                        // ✅ Si inscription + login OK → currentUser ≠ nil
                        if auth.currentUser != nil {
                            // Optionnel : on ferme cette vue (de toute façon
                            // ContentView basculera sur HomeView)
                            dismiss()
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)

                        if auth.isLoading {
                            ProgressView()
                        } else {
                            Text("M’inscrire")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(height: 66)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
