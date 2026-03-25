// CalorieRing.swift
// Nutrivio

import SwiftUI

struct CalorieRing: View {
    let consumed: Double
    let target: Double
    let burned: Double
    var size: CGFloat = 200

    @State private var animatedProgress: Double = 0
    @State private var animatedBurnProgress: Double = 0

    private var consumedProgress: Double {
        guard target > 0 else { return 0 }
        return min(consumed / target, 1.0)
    }

    private var burnedProgress: Double {
        guard target > 0 else { return 0 }
        return min(burned / target, 0.5)
    }

    private var remaining: Double {
        max(target - consumed, 0)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    NutrivioTheme.primaryGreen.opacity(0.1),
                    lineWidth: 18
                )

            // Burned calories ring (outer, subtle)
            Circle()
                .trim(from: 0, to: animatedBurnProgress)
                .stroke(
                    NutrivioTheme.energyOrange.opacity(0.3),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size + 28, height: size + 28)

            // Consumed calories ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            NutrivioTheme.mintGreen,
                            NutrivioTheme.emeraldGreen,
                            NutrivioTheme.primaryGreen
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(360 * animatedProgress - 90)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // End cap glow
            Circle()
                .fill(NutrivioTheme.primaryGreen)
                .frame(width: 18, height: 18)
                .shadow(color: NutrivioTheme.primaryGreen.opacity(0.5), radius: 6)
                .offset(y: -size / 2)
                .rotationEffect(.degrees(360 * animatedProgress))
                .opacity(animatedProgress > 0.05 ? 1 : 0)

            // Center content
            VStack(spacing: 4) {
                Text("\(Int(remaining))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Text("restantes")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)

                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(Int(consumed))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(NutrivioTheme.primaryGreen)
                        Text("comidas")
                            .font(.system(size: 9))
                            .foregroundStyle(NutrivioTheme.textTertiary)
                    }

                    Rectangle()
                        .fill(NutrivioTheme.textTertiary)
                        .frame(width: 1, height: 20)

                    VStack(spacing: 2) {
                        Text("\(Int(burned))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(NutrivioTheme.energyOrange)
                        Text("quemadas")
                            .font(.system(size: 9))
                            .foregroundStyle(NutrivioTheme.textTertiary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(NutrivioAnimations.ringFill) {
                animatedProgress = consumedProgress
                animatedBurnProgress = burnedProgress
            }
        }
    }
}

#Preview {
    CalorieRing(consumed: 1490, target: 2200, burned: 320)
        .padding()
}
