//
//  AuthViewModel..swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import Foundation
import SwiftUI
import Supabase

struct AppUser {
    let id: UUID
    let email: String
    let username: String
}

struct ProfileRow: Decodable {
    let id: UUID
    let username: String?
    let email: String?
}

struct ProfileInsert: Encodable {
    let id: UUID
    let username: String
    let email: String
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentUser: AppUser?

    // MARK: - INSCRIPTION

    func register() async {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Complète tous les champs."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 1) Création du compte Supabase
            try await supabase.auth.signUp(
                email: email,
                password: password
            )

            // 2) Connexion automatique
            try await supabase.auth.signIn(
                email: email,
                password: password
            )

            // 3) Récupération de l’utilisateur courant
            guard let authUser = supabase.auth.currentUser else {
                errorMessage = "Impossible de récupérer la session après l'inscription."
                return
            }

            // 4) Création du profil dans la table "profiles"
            let insert = ProfileInsert(
                id: authUser.id,
                username: username,
                email: email
            )

            _ = try await supabase
                .from("profiles")
                .insert(insert)
                .execute()

            // 5) Mise à jour de l'utilisateur courant de l'app
            currentUser = AppUser(
                id: authUser.id,
                email: email,
                username: username
            )

            // (optionnel) tu peux vider les champs si tu veux
            // self.password = ""
            // self.username = ""

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - CONNEXION

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email et mot de passe obligatoires."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await supabase.auth.signIn(
                email: email,
                password: password
            )

            guard let authUser = supabase.auth.currentUser else {
                errorMessage = "Session introuvable après la connexion."
                return
            }

            let profile: ProfileRow = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: authUser.id)
                .single()
                .execute()
                .value

            let finalUsername = profile.username ?? "Utilisateur"
            let finalEmail = profile.email ?? (authUser.email ?? email)

            currentUser = AppUser(
                id: authUser.id,
                email: finalEmail,
                username: finalUsername
            )

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - DÉCONNEXION

    func logout() async {
        do {
            try await supabase.auth.signOut()
        } catch {
            print("Erreur signOut:", error)
        }

        currentUser = nil
        email = ""
        password = ""
        username = ""
        errorMessage = nil
    }
}
