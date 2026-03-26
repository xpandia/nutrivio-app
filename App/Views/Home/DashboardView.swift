// DashboardView.swift
// Nutrivio

import SwiftUI

struct DashboardView: View {
    let dailyLog: DailyLog
    let goals: UserGoals

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Health Score
            healthScoreCard
                .staggered(index: 0)

            // MARK: - Calories In/Out
            caloriesSection
                .staggered(index: 1)

            // MARK: - Macros
            macrosSection
                .staggered(index: 2)

            // MARK: - Metrics Grid
            metricsGrid
                .staggered(index: 3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedScore = Double(dailyLog.healthScore)
            }
        }
        .onChange(of: dailyLog.healthScore) { _, newScore in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedScore = Double(newScore)
            }
        }
    }

    // MARK: - Health Score Card

    private var healthScoreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Tu dia de salud")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(dailyLog.healthScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                        .contentTransition(.numericText())

                    Text("/100")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(NutrivioTheme.textTertiary)
                }

                Text(scoreMessage)
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Animated tri-color score ring
            ZStack {
                // Track
                Circle()
                    .stroke(Color.gray.opacity(0.12), lineWidth: 9)
                    .frame(width: 72, height: 72)

                // Filled arc — tri-color AngularGradient
                Circle()
                    .trim(from: 0, to: animatedScore / 100.0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(stops: [
                                .init(color: NutrivioTheme.emeraldGreen, location: 0.0),
                                .init(color: NutrivioTheme.energyOrange, location: 0.5),
                                .init(color: NutrivioTheme.carbsOrange, location: 1.0),
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 72, height: 72)

                Image(systemName: scoreIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(scoreColor)
            }
        }
        .padding(20)
        .nutrivioCard()
    }

    private var scoreColor: Color {
        let score = dailyLog.healthScore
        if score >= 80 { return NutrivioTheme.emeraldGreen }
        if score >= 60 { return NutrivioTheme.energyOrange }
        return NutrivioTheme.carbsOrange
    }

    private var scoreIcon: String {
        let score = dailyLog.healthScore
        if score >= 80 { return "flame.fill" }
        if score >= 60 { return "heart.fill" }
        return "arrow.up.heart.fill"
    }

    private var scoreMessage: String {
        let score = dailyLog.healthScore
        if score >= 80 { return "Excelente! Sigue asi, estas en racha." }
        if score >= 60 { return "Buen dia. Puedes mejorar tu hidratacion." }
        return "Hay margen de mejora. Empieza con una comida balanceada."
    }

    // MARK: - Calories Section

    private var caloriesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Calorias")
                    .font(.headline)
                    .foregroundStyle(NutrivioTheme.textPrimary)
                Spacer()
                Text("Objetivo: \(goals.targetCalories) kcal")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }

            CalorieRing(
                consumed: dailyLog.totalCaloriesIn,
                target: Double(goals.targetCalories),
                burned: Double(dailyLog.activeCalories),
                size: 180
            )
        }
        .padding(20)
        .nutrivioCard()
    }

    // MARK: - Macros Section

    private var macrosSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Macronutrientes")
                    .font(.headline)
                    .foregroundStyle(NutrivioTheme.textPrimary)
                Spacer()
            }

            MacroRingsWithLabels(
                macros: dailyLog.totalMacros,
                targets: goals.targetMacros
            )

            VStack(spacing: 10) {
                MacroBar(
                    label: "Proteina",
                    current: dailyLog.totalMacros.protein,
                    target: goals.targetProtein,
                    color: NutrivioTheme.emeraldGreen,
                    unit: "g"
                )
                MacroBar(
                    label: "Carbohidratos",
                    current: dailyLog.totalMacros.carbs,
                    target: goals.targetCarbs,
                    color: NutrivioTheme.carbsOrange,
                    unit: "g"
                )
                MacroBar(
                    label: "Grasa",
                    current: dailyLog.totalMacros.fat,
                    target: goals.targetFat,
                    color: NutrivioTheme.fatBlue,
                    unit: "g"
                )
            }
        }
        .padding(20)
        .nutrivioCard()
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            MetricTile(
                icon: "drop.fill",
                iconColor: NutrivioTheme.skyBlue,
                title: "Agua",
                value: "\(dailyLog.waterGlasses)",
                subtitle: "de 10 vasos",
                progress: dailyLog.waterML / goals.targetWaterML
            )

            MetricTile(
                icon: "moon.fill",
                iconColor: NutrivioTheme.fatBlue,
                title: "Sueno",
                value: String(format: "%.1fh", dailyLog.sleepHours),
                subtitle: "de \(Int(goals.targetSleepHours))h",
                progress: dailyLog.sleepHours / goals.targetSleepHours
            )

            MetricTile(
                icon: "figure.walk",
                iconColor: NutrivioTheme.primaryGreen,
                title: "Pasos",
                value: formatNumber(dailyLog.steps),
                subtitle: "de \(formatNumber(goals.targetSteps))",
                progress: Double(dailyLog.steps) / Double(goals.targetSteps)
            )

            MetricTile(
                icon: "heart.fill",
                iconColor: .red,
                title: "Ritmo cardiaco",
                value: "\(dailyLog.heartRateAvg ?? 0)",
                subtitle: "bpm promedio",
                progress: nil
            )
        }
    }

    private func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
}

// MARK: - Metric Tile

struct MetricTile: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    let progress: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(NutrivioTheme.textPrimary)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(NutrivioTheme.textTertiary)

            if let progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(iconColor.opacity(0.12))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(iconColor)
                            .frame(width: geo.size.width * min(progress, 1.0))
                            .animation(NutrivioAnimations.easeInOutMedium, value: progress)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .nutrivioCard()
    }
}

#Preview {
    ScrollView {
        DashboardView(
            dailyLog: .sampleToday,
            goals: .default
        )
        .padding()
    }
    .background(NutrivioTheme.backgroundPrimary)
}
