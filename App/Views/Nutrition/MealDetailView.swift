// MealDetailView.swift
// Nutrivio

import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero photo
                heroPhoto

                VStack(spacing: 20) {
                    // Title + meta
                    titleSection

                    // Calorie summary
                    calorieSummary

                    // Macro breakdown
                    macroBreakdown

                    // Food items
                    if !meal.items.isEmpty {
                        foodItems
                    }

                    // AI note
                    if meal.isAIAnalyzed {
                        aiNote
                    }
                }
                .padding(20)
            }
        }
        .background(NutrivioTheme.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero Photo

    private var heroPhoto: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder gradient
            LinearGradient(
                colors: [NutrivioTheme.mintGreen.opacity(0.3), NutrivioTheme.emeraldGreen.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)

            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundStyle(NutrivioTheme.primaryGreen.opacity(0.3))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.4)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .frame(height: 300)
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: meal.mealType.icon)
                    .foregroundStyle(NutrivioTheme.primaryGreen)
                Text(meal.mealType.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.primaryGreen)

                Spacer()

                Text(timeFormatted)
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textTertiary)
            }

            Text(meal.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(NutrivioTheme.textPrimary)
        }
    }

    // MARK: - Calorie Summary

    private var calorieSummary: some View {
        HStack {
            VStack(spacing: 4) {
                Text("\(Int(meal.macros.calories))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(NutrivioTheme.textPrimary)
                Text("calorias")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(NutrivioTheme.textTertiary.opacity(0.3))
                .frame(width: 1, height: 40)

            macroSummaryColumn(
                value: "\(Int(meal.macros.protein))g",
                label: "Proteina",
                color: NutrivioTheme.emeraldGreen
            )

            macroSummaryColumn(
                value: "\(Int(meal.macros.carbs))g",
                label: "Carbos",
                color: NutrivioTheme.carbsOrange
            )

            macroSummaryColumn(
                value: "\(Int(meal.macros.fat))g",
                label: "Grasa",
                color: NutrivioTheme.fatBlue
            )
        }
        .padding(20)
        .nutrivioCard()
    }

    private func macroSummaryColumn(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(NutrivioTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Macro Breakdown

    private var macroBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribucion de macros")
                .font(.headline)
                .foregroundStyle(NutrivioTheme.textPrimary)

            // Visual pie-like breakdown
            GeometryReader { geo in
                HStack(spacing: 2) {
                    let total = meal.macros.proteinCalories + meal.macros.carbsCalories + meal.macros.fatCalories
                    let pWidth = total > 0 ? geo.size.width * (meal.macros.proteinCalories / total) : 0
                    let cWidth = total > 0 ? geo.size.width * (meal.macros.carbsCalories / total) : 0
                    let fWidth = total > 0 ? geo.size.width * (meal.macros.fatCalories / total) : 0

                    RoundedRectangle(cornerRadius: 4)
                        .fill(NutrivioTheme.emeraldGreen)
                        .frame(width: pWidth, height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(NutrivioTheme.carbsOrange)
                        .frame(width: cWidth, height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(NutrivioTheme.fatBlue)
                        .frame(width: fWidth, height: 12)
                }
            }
            .frame(height: 12)
            .clipShape(Capsule())

            HStack {
                Label("\(Int(meal.macros.proteinPercentage * 100))% Prot", systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.emeraldGreen)
                Spacer()
                Label("\(Int(meal.macros.carbsPercentage * 100))% Carbs", systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.carbsOrange)
                Spacer()
                Label("\(Int(meal.macros.fatPercentage * 100))% Grasa", systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.fatBlue)
            }
        }
        .padding(20)
        .nutrivioCard()
    }

    // MARK: - Food Items

    private var foodItems: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alimentos")
                .font(.headline)
                .foregroundStyle(NutrivioTheme.textPrimary)

            ForEach(meal.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(NutrivioTheme.textPrimary)

                        Text("\(Int(item.quantity))\(item.unit)")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textTertiary)
                    }

                    Spacer()

                    Text("\(Int(item.macros.calories)) kcal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutrivioTheme.textSecondary)
                }
                .padding(.vertical, 8)

                if item.id != meal.items.last?.id {
                    Divider()
                }
            }
        }
        .padding(20)
        .nutrivioCard()
    }

    // MARK: - AI Note

    private var aiNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(NutrivioTheme.primaryGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text("Analizado con IA")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutrivioTheme.primaryGreen)

                if let confidence = meal.confidenceScore {
                    Text("Precision estimada: \(Int(confidence * 100))%. Puedes ajustar las cantidades manualmente.")
                        .font(.caption)
                        .foregroundStyle(NutrivioTheme.textSecondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(NutrivioTheme.primaryGreen.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusSmall))
    }

    private var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }
}

#Preview {
    NavigationStack {
        MealDetailView(meal: .sampleBreakfast)
    }
}
