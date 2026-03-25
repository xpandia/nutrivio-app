// WorkoutSummaryView.swift
// Nutrivio

import SwiftUI

struct WorkoutSummaryView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [NutrivioTheme.cobaltBlue, NutrivioTheme.deepBlue],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Trophy/celebration
                        celebrationHeader
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 30)

                        // Stats grid
                        statsGrid
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // Exercises completed
                        exercisesCompleted
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // AI insight
                        aiInsight
                            .opacity(showContent ? 1 : 0)

                        // Done button
                        Button {
                            dismiss()
                        } label: {
                            Text("Completado")
                                .font(.headline)
                                .foregroundStyle(NutrivioTheme.cobaltBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.top, 8)
                        .opacity(showContent ? 1 : 0)
                    }
                    .padding(24)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    showContent = true
                }
            }
        }
    }

    // MARK: - Celebration

    private var celebrationHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(NutrivioTheme.goldLight)
                    .pulse()
            }

            Text("Workout completado!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(workout.name)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            SummaryStat(
                value: "\(workout.durationMinutes)",
                unit: "min",
                label: "Duracion",
                icon: "clock"
            )
            SummaryStat(
                value: "\(workout.estimatedCalories)",
                unit: "kcal",
                label: "Quemadas",
                icon: "flame.fill"
            )
            SummaryStat(
                value: "\(workout.exercises.count)",
                unit: "",
                label: "Ejercicios",
                icon: "figure.strengthtraining.traditional"
            )
        }
    }

    // MARK: - Exercises Completed

    private var exercisesCompleted: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ejercicios")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(workout.exercises) { exercise in
                HStack(spacing: 12) {
                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(exercise.isCompleted ? NutrivioTheme.emeraldGreen : .white.opacity(0.3))

                    Text(exercise.name)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(exercise.isCompleted ? 1 : 0.5))

                    Spacer()

                    Text(exercise.setsRepsText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
    }

    // MARK: - AI Insight

    private var aiInsight: some View {
        HStack(spacing: 10) {
            Image(systemName: "brain.head.profile")
                .foregroundStyle(NutrivioTheme.primaryGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text("Insight IA")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutrivioTheme.primaryGreen)

                Text("Buen trabajo! Para maximizar la recuperacion, te sugiero una cena con al menos 35g de proteina en las proximas 2 horas.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(16)
        .background(NutrivioTheme.primaryGreen.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusSmall))
    }
}

// MARK: - Summary Stat

struct SummaryStat: View {
    let value: String
    let unit: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    WorkoutSummaryView(workout: .sampleStrength)
}
