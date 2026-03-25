// OnboardingView.swift
// Nutrivio

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var selectedGoal: FitnessGoal = .maintain
    @State private var weight: String = "75"
    @State private var height: String = "175"
    @State private var age: String = "28"
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var selectedEquipment: Equipment = .gym
    @State private var hasWatch = false
    @State private var isCalculating = false
    @State private var showPaywall = false

    private let totalPages = 5

    var body: some View {
        ZStack {
            NutrivioTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                progressDots
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // Page content
                TabView(selection: $currentPage) {
                    goalPage.tag(0)
                    dataPage.tag(1)
                    equipmentPage.tag(2)
                    watchPage.tag(3)
                    calculatingPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Navigation buttons
                if currentPage < 4 {
                    navigationButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPage ? NutrivioTheme.primaryGreen : NutrivioTheme.textTertiary.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(NutrivioAnimations.springSmooth, value: currentPage)
            }
        }
    }

    // MARK: - Page 1: Goal

    private var goalPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Cual es tu objetivo?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Text("Esto nos ayuda a personalizar tu plan de nutricion y ejercicio")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: selectedGoal == goal
                    ) {
                        withAnimation { selectedGoal = goal }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 2: Data

    private var dataPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Tus datos basicos")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Text("Para calcular tus calorias y macros ideales")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }

            VStack(spacing: 16) {
                OnboardingField(icon: "scalemass", label: "Peso (kg)", text: $weight)
                OnboardingField(icon: "ruler", label: "Altura (cm)", text: $height)
                OnboardingField(icon: "calendar", label: "Edad", text: $age)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nivel de actividad")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(NutrivioTheme.textPrimary)

                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Button {
                            withAnimation { activityLevel = level }
                        } label: {
                            HStack {
                                Text(level.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(NutrivioTheme.textPrimary)
                                Spacer()
                                if activityLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(NutrivioTheme.primaryGreen)
                                }
                            }
                            .padding(12)
                            .background(activityLevel == level
                                ? NutrivioTheme.primaryGreen.opacity(0.08)
                                : NutrivioTheme.textTertiary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 3: Equipment

    private var equipmentPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Que equipamiento tienes?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Text("Adaptamos las rutinas a lo que tengas disponible")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }

            VStack(spacing: 12) {
                ForEach(Equipment.allCases, id: \.self) { equip in
                    Button {
                        withAnimation { selectedEquipment = equip }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedEquipment == equip
                                        ? NutrivioTheme.cobaltBlue.opacity(0.1)
                                        : NutrivioTheme.textTertiary.opacity(0.05))
                                    .frame(width: 48, height: 48)

                                Image(systemName: equip.icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedEquipment == equip
                                        ? NutrivioTheme.cobaltBlue
                                        : NutrivioTheme.textSecondary)
                            }

                            Text(equip.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(NutrivioTheme.textPrimary)

                            Spacer()

                            if selectedEquipment == equip {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(NutrivioTheme.cobaltBlue)
                            }
                        }
                        .padding(14)
                        .background(selectedEquipment == equip
                            ? NutrivioTheme.cobaltBlue.opacity(0.04)
                            : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
                        .overlay(
                            RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium)
                                .stroke(selectedEquipment == equip
                                    ? NutrivioTheme.cobaltBlue.opacity(0.3)
                                    : NutrivioTheme.textTertiary.opacity(0.15),
                                    lineWidth: 1)
                        )
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 4: Watch

    private var watchPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Tienes Apple Watch?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Text("Con Apple Watch obtienes calorias quemadas, sueno y frecuencia cardiaca en tiempo real")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Watch illustration
            ZStack {
                Circle()
                    .fill(NutrivioTheme.primaryGreen.opacity(0.08))
                    .frame(width: 160, height: 160)

                Image(systemName: "applewatch.watchface")
                    .font(.system(size: 80))
                    .foregroundStyle(NutrivioTheme.primaryGreen)
            }

            VStack(spacing: 16) {
                Button {
                    withAnimation { hasWatch = true }
                } label: {
                    HStack {
                        Image(systemName: hasWatch ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(hasWatch ? NutrivioTheme.primaryGreen : NutrivioTheme.textTertiary)
                        Text("Si, tengo Apple Watch")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(NutrivioTheme.textPrimary)
                        Spacer()
                    }
                    .padding(16)
                    .background(hasWatch ? NutrivioTheme.primaryGreen.opacity(0.06) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasWatch ? NutrivioTheme.primaryGreen.opacity(0.3) : NutrivioTheme.textTertiary.opacity(0.2), lineWidth: 1)
                    )
                }

                Button {
                    withAnimation { hasWatch = false }
                } label: {
                    HStack {
                        Image(systemName: !hasWatch ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(!hasWatch ? NutrivioTheme.primaryGreen : NutrivioTheme.textTertiary)
                        Text("No, quizas despues")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(NutrivioTheme.textPrimary)
                        Spacer()
                    }
                    .padding(16)
                    .background(!hasWatch ? NutrivioTheme.primaryGreen.opacity(0.06) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(!hasWatch ? NutrivioTheme.primaryGreen.opacity(0.3) : NutrivioTheme.textTertiary.opacity(0.2), lineWidth: 1)
                    )
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Page 5: Calculating

    private var calculatingPage: some View {
        VStack(spacing: 32) {
            Spacer()

            if isCalculating {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(NutrivioTheme.primaryGreen.opacity(0.2), lineWidth: 4)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(NutrivioTheme.primaryGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(isCalculating ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isCalculating)
                    }

                    VStack(spacing: 8) {
                        Text("Calculando tu plan personalizado...")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(NutrivioTheme.textPrimary)

                        Text("Analizando tus datos para crear el plan perfecto de nutricion y ejercicio")
                            .font(.subheadline)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            } else {
                // Plan ready
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(NutrivioTheme.primaryGreen)

                    Text("Tu plan esta listo!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(NutrivioTheme.textPrimary)

                    // Plan preview
                    planPreview

                    Button {
                        showPaywall = true
                    } label: {
                        Text("Continuar")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(NutrivioTheme.greenGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        hasCompletedOnboarding = true
                    } label: {
                        Text("Continuar con plan gratuito")
                            .font(.subheadline)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            isCalculating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isCalculating = false
                }
            }
        }
    }

    private var planPreview: some View {
        VStack(spacing: 12) {
            HStack {
                planPreviewItem(icon: "flame.fill", color: NutrivioTheme.energyOrange, label: "Calorias", value: "2,200 kcal")
                planPreviewItem(icon: "fork.knife", color: NutrivioTheme.emeraldGreen, label: "Proteina", value: "150g")
            }
            HStack {
                planPreviewItem(icon: "figure.run", color: NutrivioTheme.cobaltBlue, label: "Workouts", value: "4/semana")
                planPreviewItem(icon: "drop.fill", color: NutrivioTheme.skyBlue, label: "Agua", value: "2.5L")
            }
        }
    }

    private func planPreviewItem(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textTertiary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutrivioTheme.textPrimary)
            }

            Spacer()
        }
        .padding(12)
        .background(NutrivioTheme.textTertiary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentPage > 0 {
                Button {
                    withAnimation { currentPage -= 1 }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.body.bold())
                        .foregroundStyle(NutrivioTheme.textSecondary)
                        .frame(width: 52, height: 52)
                        .background(NutrivioTheme.textTertiary.opacity(0.1))
                        .clipShape(Circle())
                }
            }

            Spacer()

            Button {
                withAnimation { currentPage += 1 }
            } label: {
                HStack {
                    Text("Siguiente")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(NutrivioTheme.greenGradient)
                .clipShape(Capsule())
                .shadow(color: NutrivioTheme.primaryGreen.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
    }
}

// MARK: - Goal Option Card

struct GoalOptionCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected
                            ? NutrivioTheme.primaryGreen.opacity(0.1)
                            : NutrivioTheme.textTertiary.opacity(0.05))
                        .frame(width: 48, height: 48)

                    Image(systemName: goal.icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? NutrivioTheme.primaryGreen : NutrivioTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutrivioTheme.textPrimary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundStyle(NutrivioTheme.textSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? NutrivioTheme.primaryGreen : NutrivioTheme.textTertiary)
            }
            .padding(14)
            .background(isSelected ? NutrivioTheme.primaryGreen.opacity(0.04) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium)
                    .stroke(isSelected ? NutrivioTheme.primaryGreen.opacity(0.3) : NutrivioTheme.textTertiary.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

// MARK: - Onboarding Field

struct OnboardingField: View {
    let icon: String
    let label: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(NutrivioTheme.primaryGreen)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(NutrivioTheme.textSecondary)

            Spacer()

            TextField("", text: $text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .frame(width: 80)
        }
        .padding(14)
        .background(NutrivioTheme.textTertiary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OnboardingView()
}
