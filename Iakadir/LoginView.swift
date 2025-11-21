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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

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

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.7))
                            .frame(width: 160, height: 160)
                            .blur(radius: 60)

                        Image("robotMain")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
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

                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(.primaryGreen)
                        TextField("ugoavecunu@gmail.com", text: $auth.email)
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

                    Rectangle()
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 1)
                        .padding(.horizontal, 16)

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
                .padding(.top, 8)

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
                    Task { await auth.login() }
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
                .padding(.top, 16)

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
        LoginView(onBack: {})
            .environmentObject(AuthViewModel())
    }
}

