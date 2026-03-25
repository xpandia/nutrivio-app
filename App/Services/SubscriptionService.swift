// SubscriptionService.swift
// Nutrivio — RevenueCat subscription management

import Foundation

// Note: In production, import RevenueCat SDK
// import RevenueCat

class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    @Published var isPro = false
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var isLoading = false

    private init() {}

    // MARK: - Products

    enum SubscriptionPlan: String {
        case free = "free"
        case monthly = "nutrivio_pro_monthly"     // $6.99/month
        case annual = "nutrivio_pro_annual"        // $39.99/year

        var displayName: String {
            switch self {
            case .free: return "Gratuito"
            case .monthly: return "Pro Mensual"
            case .annual: return "Pro Anual"
            }
        }

        var priceDisplay: String {
            switch self {
            case .free: return "Gratis"
            case .monthly: return "$6.99/mes"
            case .annual: return "$39.99/ano"
            }
        }

        var monthlyEquivalent: String {
            switch self {
            case .free: return "$0"
            case .monthly: return "$6.99"
            case .annual: return "$3.33"
            }
        }
    }

    // MARK: - Limits

    var dailyPhotoLimit: Int {
        isPro ? Int.max : 3
    }

    var hasAICoach: Bool {
        isPro
    }

    var hasAdvancedRoutines: Bool {
        isPro
    }

    var hasAppleWatchFeatures: Bool {
        isPro
    }

    // MARK: - Configuration

    func configure() {
        // In production:
        // Purchases.configure(withAPIKey: "your_revenuecat_api_key")
        // Purchases.shared.delegate = self
        checkSubscriptionStatus()
    }

    // MARK: - Purchase

    func purchase(plan: SubscriptionPlan) async throws {
        isLoading = true
        defer { isLoading = false }

        // In production:
        // let offerings = try await Purchases.shared.offerings()
        // guard let package = offerings.current?.availablePackages.first(where: { ... }) else { return }
        // let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)
        // isPro = customerInfo.entitlements["pro"]?.isActive ?? false

        // Simulate purchase
        try await Task.sleep(for: .seconds(1))
        isPro = true
        currentPlan = plan
    }

    // MARK: - Restore

    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        // In production:
        // let customerInfo = try await Purchases.shared.restorePurchases()
        // isPro = customerInfo.entitlements["pro"]?.isActive ?? false

        try await Task.sleep(for: .seconds(1))
    }

    // MARK: - Status Check

    func checkSubscriptionStatus() {
        // In production:
        // Purchases.shared.getCustomerInfo { [weak self] (info, error) in
        //     self?.isPro = info?.entitlements["pro"]?.isActive ?? false
        // }
    }

    // MARK: - Feature Gate

    func canUseFeature(_ feature: ProFeature) -> Bool {
        switch feature {
        case .unlimitedPhotos: return isPro
        case .aiCoach: return isPro
        case .advancedRoutines: return isPro
        case .appleWatch: return isPro
        case .mealPlanning: return isPro
        case .advancedAnalytics: return isPro
        case .basicFoodLog: return true
        case .basicRoutines: return true
        case .basicDashboard: return true
        }
    }
}

// MARK: - Pro Features

enum ProFeature {
    case unlimitedPhotos
    case aiCoach
    case advancedRoutines
    case appleWatch
    case mealPlanning
    case advancedAnalytics
    case basicFoodLog
    case basicRoutines
    case basicDashboard
}
