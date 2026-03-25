// Workout.swift
// Nutrivio

import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: WorkoutType
    var exercises: [Exercise]
    var durationMinutes: Int
    var estimatedCalories: Int
    var difficulty: Difficulty
    var isCompleted: Bool
    var completedAt: Date?
    var aiGenerated: Bool
    var adaptationNote: String?

    init(
        id: UUID = UUID(),
        name: String,
        type: WorkoutType,
        exercises: [Exercise] = [],
        durationMinutes: Int,
        estimatedCalories: Int,
        difficulty: Difficulty = .intermediate,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        aiGenerated: Bool = true,
        adaptationNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.exercises = exercises
        self.durationMinutes = durationMinutes
        self.estimatedCalories = estimatedCalories
        self.difficulty = difficulty
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.aiGenerated = aiGenerated
        self.adaptationNote = adaptationNote
    }

    var completedExercises: Int {
        exercises.filter { $0.isCompleted }.count
    }

    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(completedExercises) / Double(exercises.count)
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case strength = "Fuerza"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case cardio = "Cardio"
    case flexibility = "Flexibilidad"
    case functional = "Funcional"

    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .hiit: return "bolt.fill"
        case .yoga: return "figure.yoga"
        case .cardio: return "figure.run"
        case .flexibility: return "figure.flexibility"
        case .functional: return "figure.cross.training"
        }
    }

    var color: String {
        switch self {
        case .strength: return "cobaltBlue"
        case .hiit: return "energyOrange"
        case .yoga: return "lavenderPurple"
        case .cardio: return "skyBlue"
        case .flexibility: return "mintGreen"
        case .functional: return "emeraldGreen"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner = "Principiante"
    case intermediate = "Intermedio"
    case advanced = "Avanzado"

    var stars: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
}

// MARK: - Sample Data

extension Workout {
    static let sampleStrength = Workout(
        name: "Fuerza - Tren Superior",
        type: .strength,
        exercises: Exercise.sampleUpperBody,
        durationMinutes: 45,
        estimatedCalories: 320,
        difficulty: .intermediate,
        adaptationNote: "Intensidad reducida: dormiste solo 5.5h anoche"
    )

    static let sampleHIIT = Workout(
        name: "HIIT Quema Grasa",
        type: .hiit,
        exercises: Exercise.sampleHIIT,
        durationMinutes: 25,
        estimatedCalories: 280,
        difficulty: .advanced
    )
}
