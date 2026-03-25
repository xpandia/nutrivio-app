// MealCardView.swift
// Nutrivio

import SwiftUI

struct MealCardView: View {
    let meal: Meal
    @State private var isAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Photo area (editorial style)
            ZStack(alignment: .bottomLeading) {
                // Photo placeholder / actual photo
                photoSection

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)

                // Overlay content
                VStack(alignment: .leading, spacing: 6) {
                    // Meal type pill
                    HStack(spacing: 4) {
                        Image(systemName: meal.mealType.icon)
                            .font(.system(size: 10))
                        Text(meal.mealType.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial.opacity(0.8))
                    .clipShape(Capsule())

                    Text(meal.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(16)

                // AI badge
                if meal.isAIAnalyzed {
                    VStack {
                        HStack {
                            Spacer()
                            aiBadge
                                .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 200)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: NutrivioTheme.cornerRadiusMedium,
                    topTrailingRadius: NutrivioTheme.cornerRadiusMedium
                )
            )

            // MARK: - Macros section
            VStack(spacing: 12) {
                // Calories header
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.energyOrange)

                        Text("\(Int(meal.macros.calories))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(NutrivioTheme.textPrimary)

                        Text("kcal")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                    }

                    Spacer()

                    Text(timeFormatted)
                        .font(.caption)
                        .foregroundStyle(NutrivioTheme.textTertiary)
                }

                // Macro chips
                MacroChipsRow(macros: meal.macros)

                // Confidence bar (if AI analyzed)
                if let confidence = meal.confidenceScore {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                            .foregroundStyle(NutrivioTheme.primaryGreen)

                        Text("Precision IA: \(Int(confidence * 100))%")
                            .font(.system(size: 10))
                            .foregroundStyle(NutrivioTheme.textTertiary)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(NutrivioTheme.primaryGreen.opacity(0.12))
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(NutrivioTheme.primaryGreen)
                                    .frame(width: geo.size.width * confidence)
                            }
                        }
                        .frame(height: 3)
                    }
                }
            }
            .padding(16)
        }
        .background(NutrivioTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
        .shadow(color: NutrivioTheme.cardShadow, radius: 16, x: 0, y: 6)
        .scaleEffect(isAppeared ? 1 : 0.95)
        .opacity(isAppeared ? 1 : 0)
        .onAppear {
            withAnimation(NutrivioAnimations.springSmooth) {
                isAppeared = true
            }
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        ZStack {
            // Placeholder with gradient
            LinearGradient(
                colors: mealGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Food illustration placeholder
            VStack(spacing: 8) {
                Image(systemName: mealIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private var mealGradientColors: [Color] {
        switch meal.mealType {
        case .breakfast: return [Color(hex: "F8E8D4"), Color(hex: "E8C9A0")]
        case .lunch: return [Color(hex: "D4F1D4"), Color(hex: "A0D8A0")]
        case .dinner: return [Color(hex: "D4D8F1"), Color(hex: "A0A8D8")]
        case .snack: return [Color(hex: "F1E8D4"), Color(hex: "D8C8A0")]
        }
    }

    private var mealIcon: String {
        switch meal.mealType {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars.fill"
        case .snack: return "carrot.fill"
        }
    }

    // MARK: - AI Badge

    private var aiBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "sparkles")
                .font(.system(size: 9))
            Text("IA")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(NutrivioTheme.primaryGreen)
        .clipShape(Capsule())
    }

    private var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            MealCardView(meal: .sampleBreakfast)
            MealCardView(meal: .sampleLunch)
        }
        .padding()
    }
    .background(NutrivioTheme.backgroundPrimary)
}
