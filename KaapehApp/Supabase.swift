//
//  Supabase.swift
//  KaapehApp
//
//  Created by Alumnos on 19/11/25.
//
import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://xrvsidhefvodmpwnovms.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhydnNpZGhlZnZvZG1wd25vdm1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2ODQ2ODksImV4cCI6MjA3ODI2MDY4OX0.n3LaAdOfmhYghcJKd788ynlJDJuoal9SlvksRJzcOk0",
    options: SupabaseClientOptions(
    )
    )

