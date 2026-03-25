// AIFoodAnalysisService.swift
// Nutrivio — Claude Vision API for food photo analysis

import Foundation

class AIFoodAnalysisService {
    static let shared = AIFoodAnalysisService()

    private let apiURL = "https://api.anthropic.com/v1/messages"
    private var apiKey: String {
        // In production: read from secure keychain or config
        return ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    }

    private init() {}

    // MARK: - Analyze Food Photo

    /// Sends a food photo to Claude Vision and returns estimated macros
    func analyzeFood(imageData: Data) async throws -> Meal {
        let base64Image = imageData.base64EncodedString()

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": """
                            Analiza esta foto de comida. Responde SOLO con JSON valido (sin markdown):
                            {
                              "name": "nombre del plato",
                              "items": [
                                {
                                  "name": "ingrediente",
                                  "quantity_g": 100,
                                  "calories": 200,
                                  "protein_g": 20,
                                  "carbs_g": 25,
                                  "fat_g": 8
                                }
                              ],
                              "total_calories": 500,
                              "total_protein_g": 30,
                              "total_carbs_g": 50,
                              "total_fat_g": 15,
                              "confidence": 0.85,
                              "meal_type": "lunch"
                            }
                            """
                        ]
                    ]
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
            throw AIFoodError.apiError("Error en la respuesta de la API")
        }

        return try parseFoodResponse(data)
    }

    // MARK: - Parse Response

    private func parseFoodResponse(_ data: Data) throws -> Meal {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let textContent = content.first(where: { $0["type"] as? String == "text" }),
              let text = textContent["text"] as? String,
              let foodData = text.data(using: .utf8),
              let foodJSON = try JSONSerialization.jsonObject(with: foodData) as? [String: Any]
        else {
            throw AIFoodError.parseError("No se pudo interpretar la respuesta")
        }

        let name = foodJSON["name"] as? String ?? "Comida"
        let totalCalories = foodJSON["total_calories"] as? Double ?? 0
        let totalProtein = foodJSON["total_protein_g"] as? Double ?? 0
        let totalCarbs = foodJSON["total_carbs_g"] as? Double ?? 0
        let totalFat = foodJSON["total_fat_g"] as? Double ?? 0
        let confidence = foodJSON["confidence"] as? Double ?? 0.5
        let mealTypeStr = foodJSON["meal_type"] as? String ?? "lunch"

        let mealType: MealType = {
            switch mealTypeStr {
            case "breakfast": return .breakfast
            case "lunch": return .lunch
            case "dinner": return .dinner
            case "snack": return .snack
            default: return .lunch
            }
        }()

        var items: [FoodItem] = []
        if let itemsArray = foodJSON["items"] as? [[String: Any]] {
            items = itemsArray.map { item in
                FoodItem(
                    name: item["name"] as? String ?? "",
                    quantity: item["quantity_g"] as? Double ?? 0,
                    unit: "g",
                    macros: Macros(
                        calories: item["calories"] as? Double ?? 0,
                        protein: item["protein_g"] as? Double ?? 0,
                        carbs: item["carbs_g"] as? Double ?? 0,
                        fat: item["fat_g"] as? Double ?? 0
                    )
                )
            }
        }

        return Meal(
            name: name,
            macros: Macros(
                calories: totalCalories,
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat
            ),
            mealType: mealType,
            items: items,
            isAIAnalyzed: true,
            confidenceScore: confidence
        )
    }
}

// MARK: - Errors

enum AIFoodError: LocalizedError {
    case apiError(String)
    case parseError(String)
    case noImage

    var errorDescription: String? {
        switch self {
        case .apiError(let msg): return msg
        case .parseError(let msg): return msg
        case .noImage: return "No se proporcionó una imagen"
        }
    }
}
