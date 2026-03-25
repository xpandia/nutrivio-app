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

    @State private var proteinProgress: Double = 0
    @State private var carbsProgress: Double = 0
    @State private var fatProgress: Double = 0

    var body: some View {
        ZStack {
            // Fat ring (outer)
            RingShape(progress: fatProgress, lineWidth: 14)
                .foregroundStyle(NutrivioTheme.fatBlue)
                .frame(width: size, height: size)

            // Background fat
            Circle()
                .stroke(NutrivioTheme.fatBlue.opacity(0.12), lineWidth: 14)
                .frame(width: size, height: size)

            // Carbs ring (middle)
            RingShape(progress: carbsProgress, lineWidth: 14)
                .foregroundStyle(NutrivioTheme.carbsOrange)
                .frame(width: size - 38, height: size - 38)

            Circle()
                .stroke(NutrivioTheme.carbsOrange.opacity(0.12), lineWidth: 14)
                .frame(width: size - 38, height: size - 38)

            // Protein ring (inner)
            RingShape(progress: proteinProgress, lineWidth: 14)
                .foregroundStyle(NutrivioTheme.emeraldGreen)
                .frame(width: size - 76, height: size - 76)

            Circle()
                .stroke(NutrivioTheme.emeraldGreen.opacity(0.12), lineWidth: 14)
                .frame(width: size - 76, height: size - 76)
        }
        .onAppear {
            withAnimation(NutrivioAnimations.ringFill.delay(0.1)) {
                proteinProgress = min(protein / proteinTarget, 1.0)
            }
            withAnimation(NutrivioAnimations.ringFill.delay(0.2)) {
                carbsProgress = min(carbs / carbsTarget, 1.0)
            }
            withAnimation(NutrivioAnimations.ringFill.delay(0.3)) {
                fatProgress = min(fat / fatTarget, 1.0)
            }
        }
    }
}

// MARK: - Ring Shape

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
                fatTarget: targets.fat
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
