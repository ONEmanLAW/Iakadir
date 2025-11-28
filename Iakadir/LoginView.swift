//
//  LoginView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    let onBack: () -> Void

    @State private var showPassword = false
    
    // 🔥 États pour les animations
    @State private var glow = false
    @State private var floatRobot = false

    // Apparition fluide de la page
    @State private var didAppear = false

    // 👇 observer clavier
    @StateObject private var keyboard = KeyboardObserver()

    // 👇 gestion du focus des champs
    private enum Field {
        case email
        case password
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // HEADER
                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                    .opacity(didAppear ? 1 : 0)
                    .offset(y: didAppear ? 0 : -10)
                    .animation(.easeOut(duration: 0.4), value: didAppear)

                    // BLOC ROBOT + TITRES
                    VStack(spacing: 16) {
                        ZStack {
                            // 🌟 Halo vert qui pulse
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

                            // 🤖 Robot qui “vole”
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

                        Text("Connecte-toi")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 4) {
                            Text("Tu n'as pas de compte ?")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))

                            NavigationLink {
                                RegisterView()
                                    .environmentObject(auth)
                            } label: {
                                Text("Inscris-toi")
                                    .foregroundColor(.primaryGreen)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .opacity(didAppear ? 1 : 0)
                    .offset(y: didAppear ? 0 : 10)
                    .animation(.easeOut(duration: 0.45).delay(0.05), value: didAppear)

                    // FORMULAIRE
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.primaryGreen)
                            TextField("ugoavecunu@gmail.com", text: $auth.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)             // ⏭ "Suivant"
                                .onSubmit {
                                    // passer au mot de passe
                                    focusedField = .password
                                }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )

                        Rectangle()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 1)
                            .padding(.horizontal, 16)

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.primaryGreen)

                            if showPassword {
                                TextField("Mot de passe", text: $auth.password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)           // ✅ "OK / Go"
                                    .onSubmit {
                                        Task { await submitLogin() }
                                    }
                            } else {
                                SecureField("Mot de passe", text: $auth.password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)           // ✅ "OK / Go"
                                    .onSubmit {
                                        Task { await submitLogin() }
                                    }
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
                    .padding(.top, 8)
                    .opacity(didAppear ? 1 : 0)
                    .offset(y: didAppear ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: didAppear)

                    // LIEN + ERREUR + BOUTON
                    VStack(spacing: 8) {
                        Button {
                            // plus tard reset mot de passe
                        } label: {
                            Text("Mot de passe oublié ?")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.top, 4)

                        if let error = auth.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.system(size: 13))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 4)
                        }

                        Button {
                            Task { await submitLogin() }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white)

                                if auth.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Me connecter")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(height: 66)
                        }
                        .padding(.top, 8)
                    }
                    .opacity(didAppear ? 1 : 0)
                    .offset(y: didAppear ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.15), value: didAppear)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .frame(
                    maxWidth: .infinity,
                    minHeight: UIScreen.main.bounds.height,
                    alignment: .topLeading
                )
            }
            .scrollDisabled(!keyboard.isVisible)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !didAppear {
                didAppear = true
            }
        }
    }

    // MARK: - Actions

    private func submitLogin() async {
        // ferme le clavier
        focusedField = nil
        await auth.login()
    }
}

#Preview {
    NavigationStack {
        LoginView(onBack: {})
            .environmentObject(AuthViewModel())
    }
}
