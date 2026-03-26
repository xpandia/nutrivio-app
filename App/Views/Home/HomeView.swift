// HomeView.swift
// Nutrivio

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingProfile = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    aiCoachCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    DashboardView(
                        dailyLog: dashboardVM.todayLog,
                        goals: dashboardVM.goals
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    quickActions
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
            }
            .background(NutrivioTheme.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(greeting)
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                        Text("Nutrivio")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(NutrivioTheme.textPrimary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingProfile = true } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundStyle(NutrivioTheme.primaryGreen)
                    }
                }
            }
        }
        .task {
            dashboardVM.configure(modelContext: modelContext)
            nutritionVM.configure(modelContext: modelContext)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(todayFormatted)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(NutrivioTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(NutrivioTheme.primaryGreen.opacity(0.08))
            .clipShape(Capsule())

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(NutrivioTheme.energyOrange)
                Text("7 dias")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(NutrivioTheme.textPrimary)
            }
        }
    }

    // MARK: - AI Coach Card

    private var aiCoachCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(NutrivioTheme.greenGradient)
                    .frame(width: 40, height: 40)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Coach IA")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutrivioTheme.primaryGreen)

                Text("Llevas 3 dias cumpliendo tu meta de proteina. Buen trabajo!")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(NutrivioTheme.textTertiary)
        }
        .padding(16)
        .background(NutrivioTheme.primaryGreen.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones rapidas")
                .font(.headline)
                .foregroundStyle(NutrivioTheme.textPrimary)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "camera.fill",
                    label: "Foto comida",
                    color: NutrivioTheme.primaryGreen
                )

                QuickActionButton(
                    icon: "fork.knife",
                    label: "Log manual",
                    color: NutrivioTheme.energyOrange
                )

                QuickActionButton(
                    icon: "figure.run",
                    label: "Workout",
                    color: NutrivioTheme.cobaltBlue
                )

                QuickActionButton(
                    icon: "drop.fill",
                    label: "Agua",
                    color: NutrivioTheme.skyBlue
                ) {
                    dashboardVM.addWater(ml: 250)
                }
            }
        }
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Buenos dias" }
        if hour < 18 { return "Buenas tardes" }
        return "Buenas noches"
    }

    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE d MMM"
        return formatter.string(from: Date()).capitalized
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(DashboardViewModel())
        .environmentObject(NutritionViewModel())
}
