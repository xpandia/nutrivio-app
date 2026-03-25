// NutrientChip.swift
// Nutrivio

import SwiftUI

struct NutrientChip: View {
    let value: String
    let label: String
    let color: Color
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)

            Text(value)
                .font(compact ? .system(size: 11, weight: .bold) : .caption.bold())
                .foregroundStyle(NutrivioTheme.textPrimary)

            Text(label)
                .font(compact ? .system(size: 10) : .caption2)
                .foregroundStyle(NutrivioTheme.textSecondary)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Macro Chips Row

struct MacroChipsRow: View {
    let macros: Macros
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            NutrientChip(
                value: "\(Int(macros.protein))g",
                label: "Prot",
                color: NutrivioTheme.emeraldGreen,
                compact: compact
            )
            NutrientChip(
                value: "\(Int(macros.carbs))g",
                label: "Carbs",
                color: NutrivioTheme.carbsOrange,
                compact: compact
            )
            NutrientChip(
                value: "\(Int(macros.fat))g",
                label: "Grasa",
                color: NutrivioTheme.fatBlue,
                compact: compact
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MacroChipsRow(macros: Macros(calories: 420, protein: 32, carbs: 48, fat: 12))
        MacroChipsRow(macros: Macros(calories: 420, protein: 32, carbs: 48, fat: 12), compact: true)
    }
    .padding()
}
