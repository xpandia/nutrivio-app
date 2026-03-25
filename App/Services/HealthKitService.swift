// HealthKitService.swift
// Nutrivio — HealthKit integration for reading/writing health data

import Foundation
import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    private init() {}

    // MARK: - Authorization

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKCategoryType(.sleepAnalysis),
            HKQuantityType(.bodyMass),
            HKQuantityType(.height),
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.dietaryWater)
        ]

        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.dietaryWater),
            HKQuantityType(.activeEnergyBurned)
        ]

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    // MARK: - Read Data

    func fetchTodaySteps() async throws -> Int {
        let stepsType = HKQuantityType(.stepCount)
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            healthStore.execute(query)
        }
    }

    func fetchTodayActiveCalories() async throws -> Double {
        let caloriesType = HKQuantityType(.activeEnergyBurned)
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: caloriesType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: calories)
            }
            healthStore.execute(query)
        }
    }

    func fetchLastNightSleep() async throws -> Double {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let totalSleep = (samples as? [HKCategorySample])?.reduce(0.0) { total, sample in
                    if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                        return total + sample.endDate.timeIntervalSince(sample.startDate)
                    }
                    return total
                } ?? 0

                continuation.resume(returning: totalSleep / 3600.0)
            }
            healthStore.execute(query)
        }
    }

    func fetchAverageHeartRate() async throws -> Int {
        let hrType = HKQuantityType(.heartRate)
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let avgHR = result?.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0
                continuation.resume(returning: Int(avgHR))
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Write Data

    func logNutrition(macros: Macros, date: Date = Date()) async throws {
        var samples: [HKQuantitySample] = []

        let caloriesSample = HKQuantitySample(
            type: HKQuantityType(.dietaryEnergyConsumed),
            quantity: HKQuantity(unit: .kilocalorie(), doubleValue: macros.calories),
            start: date,
            end: date
        )
        samples.append(caloriesSample)

        let proteinSample = HKQuantitySample(
            type: HKQuantityType(.dietaryProtein),
            quantity: HKQuantity(unit: .gram(), doubleValue: macros.protein),
            start: date,
            end: date
        )
        samples.append(proteinSample)

        let carbsSample = HKQuantitySample(
            type: HKQuantityType(.dietaryCarbohydrates),
            quantity: HKQuantity(unit: .gram(), doubleValue: macros.carbs),
            start: date,
            end: date
        )
        samples.append(carbsSample)

        let fatSample = HKQuantitySample(
            type: HKQuantityType(.dietaryFatTotal),
            quantity: HKQuantity(unit: .gram(), doubleValue: macros.fat),
            start: date,
            end: date
        )
        samples.append(fatSample)

        try await healthStore.save(samples)
    }

    func logWater(ml: Double, date: Date = Date()) async throws {
        let waterSample = HKQuantitySample(
            type: HKQuantityType(.dietaryWater),
            quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: ml),
            start: date,
            end: date
        )
        try await healthStore.save(waterSample)
    }
}
