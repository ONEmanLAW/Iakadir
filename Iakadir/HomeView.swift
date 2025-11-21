//
//  HomeView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct HomeView: View {
    let username: String
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Bienvenue, \(username)")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 80)

                Image("robotMain")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)

                Spacer()

                Button {
                    Task { await auth.logout() }
                } label: {
                    Text("Se déconnecter")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    HomeView(username: "Hugo")
        .environmentObject(AuthViewModel())
}

