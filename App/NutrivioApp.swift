// NutrivioApp.swift
// Nutrivio — Nutricion + Fitness Unificado con IA
// Entry Point

import SwiftUI
import SwiftData

@main
struct NutrivioApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var nutritionVM = NutritionViewModel()
    @StateObject private var workoutVM = WorkoutViewModel()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(dashboardVM)
                    .environmentObject(nutritionVM)
                    .environmentObject(workoutVM)
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [MealItem.self, WorkoutEntry.self, DailyLogEntry.self])
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)

            FoodLogView()
                .tabItem {
                    Label("Nutricion", systemImage: "fork.knife")
                }
                .tag(1)

            PhotoCaptureView()
                .tabItem {
                    Label("Foto", systemImage: "camera.fill")
                }
                .tag(2)

            WorkoutView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
                }
                .tag(3)

            Text("Perfil")
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(NutrivioTheme.primaryGreen)
    }
}
