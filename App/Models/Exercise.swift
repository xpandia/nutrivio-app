// Exercise.swift
// Nutrivio

import Foundation

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var muscleGroups: [MuscleGroup]
    var sets: Int
    var reps: String        // "12" o "30s" para tiempo
    var restSeconds: Int
    var weight: Double?     // kg, nil si bodyweight
    var instructions: String
    var isCompleted: Bool
    var videoURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroups: [MuscleGroup],
        sets: Int,
        reps: String,
        restSeconds: Int = 60,
        weight: Double? = nil,
        instructions: String = "",
        isCompleted: Bool = false,
        videoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.muscleGroups = muscleGroups
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.weight = weight
        self.instructions = instructions
        self.isCompleted = isCompleted
        self.videoURL = videoURL
    }

    var muscleGroupsText: String {
        muscleGroups.map(\.rawValue).joined(separator: ", ")
    }

    var setsRepsText: String {
        "\(sets) x \(reps)"
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Pecho"
    case back = "Espalda"
    case shoulders = "Hombros"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case quads = "Cuadriceps"
    case hamstrings = "Isquiotibiales"
    case glutes = "Gluteos"
    case calves = "Pantorrillas"
    case core = "Core"
    case fullBody = "Cuerpo completo"

    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.walk"
        case .shoulders: return "figure.arms.open"
        case .biceps, .triceps: return "figure.strengthtraining.traditional"
        case .quads, .hamstrings, .calves: return "figure.run"
        case .glutes: return "figure.walk"
        case .core: return "figure.core.training"
        case .fullBody: return "figure.cross.training"
        }
    }
}

// MARK: - Sample Data

extension Exercise {
    static let sampleUpperBody: [Exercise] = [
        Exercise(
            name: "Press de banca",
            muscleGroups: [.chest, .triceps],
            sets: 4,
            reps: "10",
            restSeconds: 90,
            weight: 60,
            instructions: "Acuestate en el banco con los pies firmes en el suelo. Baja la barra al pecho controladamente y empuja de vuelta."
        ),
        Exercise(
            name: "Remo con mancuerna",
            muscleGroups: [.back, .biceps],
            sets: 3,
            reps: "12",
            restSeconds: 60,
            weight: 20,
            instructions: "Apoya una rodilla y mano en el banco. Tira la mancuerna hacia la cadera apretando la espalda."
        ),
        Exercise(
            name: "Press militar",
            muscleGroups: [.shoulders],
            sets: 3,
            reps: "10",
            restSeconds: 60,
            weight: 30,
            instructions: "De pie, empuja la barra sobre la cabeza extendiendo los brazos completamente."
        ),
        Exercise(
            name: "Curl de biceps",
            muscleGroups: [.biceps],
            sets: 3,
            reps: "12",
            restSeconds: 45,
            weight: 12,
            instructions: "Mantén los codos pegados al cuerpo. Sube las mancuernas contrayendo el biceps."
        ),
        Exercise(
            name: "Fondos en paralelas",
            muscleGroups: [.triceps, .chest],
            sets: 3,
            reps: "10",
            restSeconds: 60,
            instructions: "Baja controladamente flexionando los codos. Inclinate ligeramente hacia adelante para enfatizar pecho."
        )
    ]

    static let sampleHIIT: [Exercise] = [
        Exercise(
            name: "Burpees",
            muscleGroups: [.fullBody],
            sets: 4,
            reps: "30s",
            restSeconds: 15,
            instructions: "Desde de pie, baja a plancha, haz una flexion, salta de vuelta y salta arriba con brazos extendidos."
        ),
        Exercise(
            name: "Mountain climbers",
            muscleGroups: [.core, .quads],
            sets: 4,
            reps: "30s",
            restSeconds: 15,
            instructions: "En posicion de plancha, lleva las rodillas al pecho alternando rapidamente."
        ),
        Exercise(
            name: "Jump squats",
            muscleGroups: [.quads, .glutes],
            sets: 4,
            reps: "30s",
            restSeconds: 15,
            instructions: "Haz una sentadilla profunda y explota hacia arriba en un salto. Aterriza suavemente."
        )
    ]
}
