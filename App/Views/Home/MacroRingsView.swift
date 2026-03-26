// MacroRingsView.swift
// Nutrivio

import SwiftUI

struct MacroRingsView: View {
    let protein: Double
    let proteinTarget: Double
    let carbs: Double
    let carbsTarget: Double
    let fat: Double
    let fatTarget: Double
    var size: CGFloat = 140
    var showCaloriesCenter: Bool = false
    var totalCalories: Double = 0

    @State private var proteinProgress: Double = 0
    @State private var carbsProgress: Double = 0
    @State private var fatProgress: Double = 0

    private let lineWidth: CGFloat = 14
    private let ringGap: CGFloat = 19

    var body: some View {
        ZStack {
            // Fat ring — outer (blue)
            Circle()
                .stroke(NutrivioTheme.fatBlue.opacity(0.12), lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: fatProgress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(NutrivioTheme.fatBlue)
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)

            // Fat glow dot
            if fatProgress > 0.02 {
                Circle()
                    .fill(NutrivioTheme.fatBlue)
                    .frame(width: lineWidth * 0.85, height: lineWidth * 0.85)
                    .shadow(color: NutrivioTheme.fatBlue.opacity(0.7), radius: 6)
                    .offset(y: -(size / 2))
                    .rotationEffect(.degrees(360 * fatProgress - 90))
            }

            // Carbs ring — middle (orange)
            let carbsSize = size - ringGap * 2
            Circle()
                .stroke(NutrivioTheme.carbsOrange.opacity(0.12), lineWidth: lineWidth)
                .frame(width: carbsSize, height: carbsSize)

            Circle()
                .trim(from: 0, to: carbsProgress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(NutrivioTheme.carbsOrange)
                .rotationEffect(.degrees(-90))
                .frame(width: carbsSize, height: carbsSize)

            // Carbs glow dot
            if carbsProgress > 0.02 {
                Circle()
                    .fill(NutrivioTheme.carbsOrange)
                    .frame(width: lineWidth * 0.85, height: lineWidth * 0.85)
                    .shadow(color: NutrivioTheme.carbsOrange.opacity(0.7), radius: 6)
                    .offset(y: -(carbsSize / 2))
                    .rotationEffect(.degrees(360 * carbsProgress - 90))
            }

            // Protein ring — inner (green)
            let proteinSize = size - ringGap * 4
            Circle()
                .stroke(NutrivioTheme.emeraldGreen.opacity(0.12), lineWidth: lineWidth)
                .frame(width: proteinSize, height: proteinSize)

            Circle()
                .trim(from: 0, to: proteinProgress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(NutrivioTheme.emeraldGreen)
                .rotationEffect(.degrees(-90))
                .frame(width: proteinSize, height: proteinSize)

            // Protein glow dot
            if proteinProgress > 0.02 {
                Circle()
                    .fill(NutrivioTheme.emeraldGreen)
                    .frame(width: lineWidth * 0.85, height: lineWidth * 0.85)
                    .shadow(color: NutrivioTheme.emeraldGreen.opacity(0.7), radius: 6)
                    .offset(y: -(proteinSize / 2))
                    .rotationEffect(.degrees(360 * proteinProgress - 90))
            }

            // Center label (only when requested and size is large enough)
            if showCaloriesCenter && size >= 120 {
                VStack(spacing: 1) {
                    Text("\(Int(totalCalories))")
                        .font(.system(size: size * 0.17, weight: .bold, design: .rounded))
                        .foregroundStyle(NutrivioTheme.textPrimary)
                    Text("kcal")
                        .font(.system(size: size * 0.09))
                        .foregroundStyle(NutrivioTheme.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(NutrivioAnimations.ringFill.delay(0.1)) {
                proteinProgress = min(protein / max(proteinTarget, 1), 1.0)
            }
            withAnimation(NutrivioAnimations.ringFill.delay(0.2)) {
                carbsProgress = min(carbs / max(carbsTarget, 1), 1.0)
            }
            withAnimation(NutrivioAnimations.ringFill.delay(0.3)) {
                fatProgress = min(fat / max(fatTarget, 1), 1.0)
            }
        }
        .onChange(of: protein) { _, v in
            withAnimation(NutrivioAnimations.easeOutQuick) {
                proteinProgress = min(v / max(proteinTarget, 1), 1.0)
            }
        }
        .onChange(of: carbs) { _, v in
            withAnimation(NutrivioAnimations.easeOutQuick) {
                carbsProgress = min(v / max(carbsTarget, 1), 1.0)
            }
        }
        .onChange(of: fat) { _, v in
            withAnimation(NutrivioAnimations.easeOutQuick) {
                fatProgress = min(v / max(fatTarget, 1), 1.0)
            }
        }
    }
}

// MARK: - Ring Shape (kept for backward compat)

struct RingShape: View {
    let progress: Double
    let lineWidth: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
    }
}

// MARK: - Macro Rings with Labels

struct MacroRingsWithLabels: View {
    let macros: Macros
    let targets: Macros

    var body: some View {
        HStack(spacing: 24) {
            MacroRingsView(
                protein: macros.protein,
                proteinTarget: targets.protein,
                carbs: macros.carbs,
                carbsTarget: targets.carbs,
                fat: macros.fat,
                fatTarget: targets.fat,
                showCaloriesCenter: true,
                totalCalories: macros.calories
            )

            VStack(alignment: .leading, spacing: 12) {
                MacroLegendRow(
                    color: NutrivioTheme.emeraldGreen,
                    label: "Proteina",
                    current: macros.protein,
                    target: targets.protein
                )
                MacroLegendRow(
                    color: NutrivioTheme.carbsOrange,
                    label: "Carbos",
                    current: macros.carbs,
                    target: targets.carbs
                )
                MacroLegendRow(
                    color: NutrivioTheme.fatBlue,
                    label: "Grasa",
                    current: macros.fat,
                    target: targets.fat
                )
            }
        }
    }
}

struct MacroLegendRow: View {
    let color: Color
    let label: String
    let current: Double
    let target: Double

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)

                Text("\(Int(current))/\(Int(target))g")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutrivioTheme.textPrimary)
            }
        }
    }
}

#Preview {
    MacroRingsWithLabels(
        macros: Macros(calories: 1490, protein: 94, carbs: 121, fat: 62),
        targets: Macros(calories: 2200, protein: 150, carbs: 220, fat: 73)
    )
    .padding()
}
