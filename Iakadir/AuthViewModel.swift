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

    @Published var isProUser: Bool = false

    private var didAttemptRestore = false

    // MARK: - INSCRIPTION

    func register() async {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Complète tous les champs."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await supabase.auth.signUp(
                email: email,
                password: password
            )

            try await supabase.auth.signIn(
                email: email,
                password: password
            )

            guard let authUser = supabase.auth.currentUser else {
                errorMessage = "Impossible de récupérer la session après l'inscription."
                isLoading = false
                return
            }

            let insert = ProfileInsert(
                id: authUser.id,
                username: username,
                email: email
            )

            _ = try await supabase
                .from("profiles")
                .insert(insert)
                .execute()

            currentUser = AppUser(
                id: authUser.id,
                email: email,
                username: username
            )

            isProUser = false

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - LOGIN

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email et mot de passe obligatoires."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await supabase.auth.signIn(
                email: email,
                password: password
            )

            guard let authUser = supabase.auth.currentUser else {
                errorMessage = "Session introuvable après la connexion."
                isLoading = false
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

            isProUser = false

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - RESTORE SESSION

    func restoreSessionIfNeeded() async {
        guard !didAttemptRestore else { return }
        didAttemptRestore = true

        if currentUser != nil { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.session
            let authUser = session.user

            let profile: ProfileRow = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: authUser.id)
                .single()
                .execute()
                .value

            let finalUsername = profile.username ?? "Utilisateur"
            let finalEmail = profile.email ?? (authUser.email ?? "")

            currentUser = AppUser(
                id: authUser.id,
                email: finalEmail,
                username: finalUsername
            )

            isProUser = false
            print("✅ Session restaurée pour \(finalEmail)")

        } catch {
            print("ℹ️ Impossible de restaurer la session :", error.localizedDescription)
        }
    }

    // MARK: - LOGOUT

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

        NotificationManager.shared.cancelBackgroundProReminders()
    }
}
