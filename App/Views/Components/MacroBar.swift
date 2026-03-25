// MacroBar.swift
// Nutrivio

import SwiftUI

struct MacroBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color
    let unit: String

    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Spacer()

                Text("\(Int(current))/\(Int(target))\(unit)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(NutrivioAnimations.ringFill) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MacroBar(label: "Proteina", current: 92, target: 150, color: NutrivioTheme.emeraldGreen, unit: "g")
        MacroBar(label: "Carbos", current: 180, target: 220, color: NutrivioTheme.carbsOrange, unit: "g")
        MacroBar(label: "Grasa", current: 55, target: 73, color: NutrivioTheme.fatBlue, unit: "g")
    }
    .padding()
}
