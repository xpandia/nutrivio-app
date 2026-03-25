// AIWorkoutService.swift
// Nutrivio — AI-powered workout generation

import Foundation

class AIWorkoutService {
    static let shared = AIWorkoutService()

    private let apiURL = "https://api.anthropic.com/v1/messages"
    private var apiKey: String {
        ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    }

    private init() {}

    // MARK: - Generate Personalized Workout

    func generateWorkout(
        goal: FitnessGoal,
        equipment: Equipment,
        difficulty: Difficulty,
        durationMinutes: Int,
        nutritionContext: NutritionContext? = nil,
        recoveryScore: Double? = nil,
        sleepHours: Double? = nil
    ) async throws -> Workout {

        let contextPrompt = buildContextPrompt(
            goal: goal,
            equipment: equipment,
            difficulty: difficulty,
            durationMinutes: durationMinutes,
            nutritionContext: nutritionContext,
            recoveryScore: recoveryScore,
            sleepHours: sleepHours
        )

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 2048,
            "messages": [
                [
                    "role": "user",
                    "content": contextPrompt
                ]
            ]
        ]

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WorkoutGenerationError.apiError
        }

        return try parseWorkoutResponse(data, goal: goal, difficulty: difficulty)
    }

    // MARK: - Build Context Prompt

    private func buildContextPrompt(
        goal: FitnessGoal,
        equipment: Equipment,
        difficulty: Difficulty,
        durationMinutes: Int,
        nutritionContext: NutritionContext?,
        recoveryScore: Double?,
        sleepHours: Double?
    ) -> String {
        var prompt = """
        Genera una rutina de ejercicio personalizada. Responde SOLO con JSON valido (sin markdown):

        Parametros:
        - Objetivo: \(goal.rawValue)
        - Equipamiento: \(equipment.rawValue)
        - Dificultad: \(difficulty.rawValue)
        - Duracion: \(durationMinutes) minutos
        """

        if let nutrition = nutritionContext {
            prompt += "\n- Calorias consumidas hoy: \(Int(nutrition.caloriesConsumed)) de \(Int(nutrition.caloriesTarget))"
            prompt += "\n- Proteina consumida: \(Int(nutrition.proteinConsumed))g de \(Int(nutrition.proteinTarget))g"
        }

        if let recovery = recoveryScore {
            prompt += "\n- Score de recuperacion: \(Int(recovery))/100"
        }

        if let sleep = sleepHours {
            prompt += "\n- Horas de sueno anoche: \(String(format: "%.1f", sleep))h"
        }

        prompt += """

        Responde con este formato JSON:
        {
          "name": "Nombre de la rutina",
          "type": "strength|hiit|yoga|cardio|flexibility|functional",
          "duration_minutes": 45,
          "estimated_calories": 300,
          "adaptation_note": "Nota si la rutina fue adaptada (o null)",
          "exercises": [
            {
              "name": "Nombre del ejercicio",
              "muscle_groups": ["Pecho", "Triceps"],
              "sets": 4,
              "reps": "10",
              "rest_seconds": 60,
              "weight_kg": null,
              "instructions": "Instrucciones claras en espanol"
            }
          ]
        }
        """

        return prompt
    }

    // MARK: - Parse Response

    private func parseWorkoutResponse(_ data: Data, goal: FitnessGoal, difficulty: Difficulty) throws -> Workout {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let textContent = content.first(where: { $0["type"] as? String == "text" }),
              let text = textContent["text"] as? String,
              let workoutData = text.data(using: .utf8),
              let workoutJSON = try JSONSerialization.jsonObject(with: workoutData) as? [String: Any]
        else {
            throw WorkoutGenerationError.parseError
        }

        let name = workoutJSON["name"] as? String ?? "Rutina del dia"
        let typeStr = workoutJSON["type"] as? String ?? "strength"
        let duration = workoutJSON["duration_minutes"] as? Int ?? 45
        let calories = workoutJSON["estimated_calories"] as? Int ?? 300
        let adaptationNote = workoutJSON["adaptation_note"] as? String

        let workoutType = WorkoutType(rawValue: typeStr) ?? .strength

        var exercises: [Exercise] = []
        if let exercisesArray = workoutJSON["exercises"] as? [[String: Any]] {
            exercises = exercisesArray.map { ex in
                let muscleNames = ex["muscle_groups"] as? [String] ?? []
                let muscles = muscleNames.compactMap { name in
                    MuscleGroup.allCases.first { $0.rawValue == name }
                }

                return Exercise(
                    name: ex["name"] as? String ?? "",
                    muscleGroups: muscles.isEmpty ? [.fullBody] : muscles,
                    sets: ex["sets"] as? Int ?? 3,
                    reps: ex["reps"] as? String ?? "10",
                    restSeconds: ex["rest_seconds"] as? Int ?? 60,
                    weight: ex["weight_kg"] as? Double,
                    instructions: ex["instructions"] as? String ?? ""
                )
            }
        }

        return Workout(
            name: name,
            type: workoutType,
            exercises: exercises,
            durationMinutes: duration,
            estimatedCalories: calories,
            difficulty: difficulty,
            aiGenerated: true,
            adaptationNote: adaptationNote
        )
    }
}

// MARK: - Supporting Types

struct NutritionContext {
    let caloriesConsumed: Double
    let caloriesTarget: Double
    let proteinConsumed: Double
    let proteinTarget: Double
}

enum WorkoutGenerationError: LocalizedError {
    case apiError
    case parseError

    var errorDescription: String? {
        switch self {
        case .apiError: return "Error al contactar la IA"
        case .parseError: return "Error al interpretar la rutina generada"
        }
    }
}
