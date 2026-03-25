// PaywallView.swift
// Nutrivio

import SwiftUI

struct PaywallView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PaywallPlan = .annual
    @State private var isAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                NutrivioTheme.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Plan preview
                        planPreviewCard

                        // Features
                        featuresSection

                        // Plan selection
                        planSelection

                        // CTA
                        ctaButton

                        // Free option
                        Button {
                            hasCompletedOnboarding = true
                            dismiss()
                        } label: {
                            Text("Continuar con plan gratuito")
                                .font(.subheadline)
                                .foregroundStyle(NutrivioTheme.textSecondary)
                        }
                        .padding(.bottom, 8)

                        // Legal
                        Text("La suscripcion se renueva automaticamente. Puedes cancelar en cualquier momento desde Configuracion > Apple ID.")
                            .font(.system(size: 10))
                            .foregroundStyle(NutrivioTheme.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(NutrivioTheme.textTertiary)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    isAppeared = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(NutrivioTheme.greenGradient)
                    .frame(width: 64, height: 64)

                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }

            Text("Tu plan esta listo")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(NutrivioTheme.textPrimary)

            Text("Desbloquea todo el poder de Nutrivio con IA ilimitada")
                .font(.subheadline)
                .foregroundStyle(NutrivioTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Plan Preview

    private var planPreviewCard: some View {
        VStack(spacing: 16) {
            Text("Tu plan personalizado")
                .font(.headline)
                .foregroundStyle(NutrivioTheme.textPrimary)

            HStack(spacing: 0) {
                // Nutrition side
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(NutrivioTheme.emeraldGreen)

                    Text("Nutricion")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutrivioTheme.emeraldGreen)

                    VStack(spacing: 4) {
                        Text("2,200 kcal")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("150g Prot")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                        Text("220g Carbs")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                        Text("73g Grasa")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

                Rectangle()
                    .fill(NutrivioTheme.textTertiary.opacity(0.2))
                    .frame(width: 1)
                    .padding(.vertical, 8)

                // Fitness side
                VStack(spacing: 10) {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundStyle(NutrivioTheme.cobaltBlue)

                    Text("Fitness")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutrivioTheme.cobaltBlue)

                    VStack(spacing: 4) {
                        Text("4x semana")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("Fuerza + Cardio")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                        Text("45 min/sesion")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                        Text("Adaptado con IA")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .padding(20)
        .nutrivioCard()
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            PaywallFeatureRow(icon: "camera.fill", color: NutrivioTheme.primaryGreen, text: "Fotos ilimitadas con analisis IA")
            PaywallFeatureRow(icon: "brain.head.profile", color: NutrivioTheme.emeraldGreen, text: "Coach IA que conecta nutricion + fitness + sueno")
            PaywallFeatureRow(icon: "figure.strengthtraining.traditional", color: NutrivioTheme.cobaltBlue, text: "Rutinas personalizadas que se adaptan a tu dia")
            PaywallFeatureRow(icon: "applewatch", color: NutrivioTheme.energyOrange, text: "Apple Watch tracking completo")
            PaywallFeatureRow(icon: "chart.xyaxis.line", color: NutrivioTheme.fatBlue, text: "Analytics avanzados y weekly review")
        }
    }

    // MARK: - Plan Selection

    private var planSelection: some View {
        VStack(spacing: 10) {
            // Annual (recommended)
            PlanOptionCard(
                plan: .annual,
                isSelected: selectedPlan == .annual,
                badge: "Recomendado"
            ) {
                withAnimation { selectedPlan = .annual }
            }

            // Monthly
            PlanOptionCard(
                plan: .monthly,
                isSelected: selectedPlan == .monthly
            ) {
                withAnimation { selectedPlan = .monthly }
            }
        }
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button {
            // Start subscription flow
            hasCompletedOnboarding = true
            dismiss()
        } label: {
            VStack(spacing: 4) {
                Text("Prueba gratis 7 dias")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Luego \(selectedPlan.priceText)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(NutrivioTheme.greenGradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: NutrivioTheme.primaryGreen.opacity(0.4), radius: 16, x: 0, y: 8)
        }
    }
}

// MARK: - Paywall Plan

enum PaywallPlan {
    case monthly
    case annual

    var name: String {
        switch self {
        case .monthly: return "Mensual"
        case .annual: return "Anual"
        }
    }

    var priceText: String {
        switch self {
        case .monthly: return "$6.99/mes"
        case .annual: return "$39.99/ano"
        }
    }

    var monthlyEquivalent: String {
        switch self {
        case .monthly: return "$6.99/mes"
        case .annual: return "$3.33/mes"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "Ahorra 52%"
        }
    }
}

// MARK: - Plan Option Card

struct PlanOptionCard: View {
    let plan: PaywallPlan
    let isSelected: Bool
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(NutrivioTheme.textPrimary)

                        Text(plan.monthlyEquivalent)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(isSelected ? NutrivioTheme.primaryGreen : NutrivioTheme.textPrimary)
                    }

                    Spacer()

                    if let savings = plan.savings {
                        Text(savings)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(NutrivioTheme.primaryGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(NutrivioTheme.primaryGreen.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? NutrivioTheme.primaryGreen : NutrivioTheme.textTertiary)
                }
                .padding(16)
                .background(isSelected ? NutrivioTheme.primaryGreen.opacity(0.04) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium)
                        .stroke(isSelected ? NutrivioTheme.primaryGreen : NutrivioTheme.textTertiary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )

                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(NutrivioTheme.primaryGreen)
                        .clipShape(Capsule())
                        .offset(x: -12, y: -8)
                }
            }
        }
    }
}

// MARK: - Feature Row

struct PaywallFeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(NutrivioTheme.textPrimary)

            Spacer()
        }
    }
}

#Preview {
    PaywallView()
}
