//
//  SupabaseClientManager.swift
//  Iakadir
//
//  Created by digital on 19/11/2025.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey
)

