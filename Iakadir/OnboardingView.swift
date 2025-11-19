//
//  OnboardingView.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
        
            Image("onboardingBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 4)
                .opacity(0.9)
            
            VStack {
                Spacer().frame(height: 80)
            
                Text("iakadir")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.primaryGreen)
                    )
                
                ZStack {
                    
                    Image("robotMain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 141.27, height: 270)
                }
                .padding(.top, 24)
                
                Spacer()
                
                Text("Ton assistant IA,\nau quotidien.")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 306)                             // largeur Figma
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                Button {
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
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
