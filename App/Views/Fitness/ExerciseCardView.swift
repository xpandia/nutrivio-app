// ExerciseCardView.swift
// Nutrivio

import SwiftUI

struct ExerciseCardView: View {
    let exercise: Exercise
    let index: Int
    let onComplete: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 14) {
                // Index / checkmark
                Button(action: onComplete) {
                    ZStack {
                        Circle()
                            .fill(exercise.isCompleted
                                ? NutrivioTheme.cobaltBlue
                                : NutrivioTheme.cobaltBlue.opacity(0.1))
                            .frame(width: 40, height: 40)

                        if exercise.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(NutrivioTheme.cobaltBlue)
                        }
                    }
                }

                // Exercise info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(exercise.isCompleted
                            ? NutrivioTheme.textTertiary
                            : NutrivioTheme.textPrimary)
                        .strikethrough(exercise.isCompleted)

                    HStack(spacing: 8) {
                        // Sets x Reps
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 9))
                            Text(exercise.setsRepsText)
                                .font(.caption)
                        }
                        .foregroundStyle(NutrivioTheme.textSecondary)

                        // Weight
                        if let weight = exercise.weight {
                            HStack(spacing: 3) {
                                Image(systemName: "scalemass")
                                    .font(.system(size: 9))
                                Text("\(Int(weight))kg")
                                    .font(.caption)
                            }
                            .foregroundStyle(NutrivioTheme.textSecondary)
                        }

                        // Rest
                        HStack(spacing: 3) {
                            Image(systemName: "timer")
                                .font(.system(size: 9))
                            Text("\(exercise.restSeconds)s")
                                .font(.caption)
                        }
                        .foregroundStyle(NutrivioTheme.textTertiary)
                    }
                }

                Spacer()

                // Expand button
                Button {
                    withAnimation(NutrivioAnimations.springSmooth) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(NutrivioTheme.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding(16)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()

                    // Muscle groups
                    HStack(spacing: 6) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.cobaltBlue)

                        Text("Musculos: \(exercise.muscleGroupsText)")
                            .font(.caption)
                            .foregroundStyle(NutrivioTheme.textSecondary)
                    }

                    // Muscle group chips
                    FlowLayout(spacing: 6) {
                        ForEach(exercise.muscleGroups, id: \.self) { muscle in
                            Text(muscle.rawValue)
                                .font(.system(size: 11))
                                .fontWeight(.medium)
                                .foregroundStyle(NutrivioTheme.cobaltBlue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(NutrivioTheme.cobaltBlue.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }

                    // Instructions
                    if !exercise.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Instrucciones")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(NutrivioTheme.textPrimary)

                            Text(exercise.instructions)
                                .font(.caption)
                                .foregroundStyle(NutrivioTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(NutrivioTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
        .shadow(color: NutrivioTheme.cardShadow, radius: 8, x: 0, y: 3)
        .opacity(exercise.isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    VStack(spacing: 12) {
        ExerciseCardView(
            exercise: Exercise.sampleUpperBody[0],
            index: 1,
            onComplete: {}
        )
        ExerciseCardView(
            exercise: Exercise.sampleUpperBody[1],
            index: 2,
            onComplete: {}
        )
    }
    .padding()
    .background(NutrivioTheme.backgroundPrimary)
}
