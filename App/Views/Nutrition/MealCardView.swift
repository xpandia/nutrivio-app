// MealCardView.swift
// Nutrivio

import SwiftUI

struct MealCardView: View {
    let meal: Meal
    @State private var isAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Photo area (editorial style, 220pt tall)
            ZStack(alignment: .bottom) {
                photoSection

                // Deep bottom gradient overlay
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.35), .black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Overlay content — staggered vertical layout
                VStack(alignment: .leading, spacing: 6) {
                    // Meal type pill
                    HStack(spacing: 4) {
                        Image(systemName: meal.mealType.icon)
                            .font(.system(size: 10))
                        Text(meal.mealType.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(0.5)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial.opacity(0.85))
                    .clipShape(Capsule())

                    // Meal name
                    Text(meal.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                // AI badge — top right
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
            .frame(height: 220)
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

                // Macro chips — horizontally scrollable if needed
                ScrollView(.horizontal, showsIndicators: false) {
                    MacroChipsRow(macros: meal.macros)
                }

                // Confidence bar (only if AI analyzed)
                if meal.isAIAnalyzed, let confidence = meal.confidenceScore {
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
            LinearGradient(
                colors: mealGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: mealIcon)
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.35))
        }
    }

    private var mealGradientColors: [Color] {
        switch meal.mealType {
        case .breakfast: return [Color(hex: "FFB347"), Color(hex: "F4845F")]
        case .lunch:     return [Color(hex: "56ab2f"), Color(hex: "a8e063")]
        case .dinner:    return [Color(hex: "2C3E7A"), Color(hex: "4A6FA5")]
        case .snack:     return [Color(hex: "f7971e"), Color(hex: "ffd200")]
        }
    }

    private var mealIcon: String {
        switch meal.mealType {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch:     return "fork.knife"
        case .dinner:    return "moon.stars.fill"
        case .snack:     return "carrot.fill"
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
        .shadow(color: NutrivioTheme.primaryGreen.opacity(0.4), radius: 4)
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
