// FoodLogView.swift
// Nutrivio

import SwiftUI
import SwiftData

struct FoodLogView: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @Environment(\.modelContext) private var modelContext

    // @Query provides live SwiftData-backed observation of MealItem records
    @Query(sort: \MealItem.timestamp, order: .forward) private var allMealItems: [MealItem]

    @State private var showingCamera = false
    @State private var selectedMealType: MealType?

    // MARK: - Today's items derived from @Query

    private var todayMealItems: [MealItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return allMealItems.filter { $0.timestamp >= today && $0.timestamp < tomorrow }
    }

    private var todayMeals: [Meal] {
        todayMealItems.map { $0.toMeal() }
    }

    private var todayMacros: Macros {
        todayMealItems.reduce(.zero) { acc, item in
            acc + Macros(calories: item.calories, protein: item.protein,
                         carbs: item.carbs, fat: item.fat)
        }
    }

    private var filteredMeals: [Meal] {
        if let type = selectedMealType {
            return todayMeals.filter { $0.mealType == type }
        }
        return todayMeals
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        dailySummaryHeader
                            .padding(.horizontal, 20)

                        mealTypeFilter
                            .padding(.horizontal, 20)

                        LazyVStack(spacing: 16) {
                            ForEach(Array(filteredMeals.enumerated()), id: \.element.id) { index, meal in
                                NavigationLink {
                                    MealDetailView(meal: meal)
                                } label: {
                                    MealCardView(meal: meal)
                                        .staggered(index: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        if filteredMeals.isEmpty {
                            emptyState
                                .padding(.top, 40)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 8)
                }
                .background(NutrivioTheme.backgroundPrimary)

                addMealButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            }
            .navigationTitle("Nutricion")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCamera) {
                PhotoCaptureView()
                    .environmentObject(nutritionVM)
            }
        }
        .task {
            nutritionVM.configure(modelContext: modelContext)
        }
    }

    // MARK: - Daily Summary

    private var dailySummaryHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hoy")
                    .font(.subheadline)
                    .foregroundStyle(NutrivioTheme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(todayMacros.calories))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(NutrivioTheme.textPrimary)

                    Text("/ 2200 kcal")
                        .font(.subheadline)
                        .foregroundStyle(NutrivioTheme.textTertiary)
                }
            }

            Spacer()

            MacroRingsView(
                protein: todayMacros.protein,
                proteinTarget: 150,
                carbs: todayMacros.carbs,
                carbsTarget: 220,
                fat: todayMacros.fat,
                fatTarget: 73,
                size: 80
            )
        }
        .padding(20)
        .nutrivioCard()
    }

    // MARK: - Meal Type Filter

    private var mealTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "Todas",
                    isSelected: selectedMealType == nil
                ) {
                    withAnimation { selectedMealType = nil }
                }

                ForEach(MealType.allCases, id: \.self) { type in
                    FilterChip(
                        label: type.rawValue,
                        icon: type.icon,
                        isSelected: selectedMealType == type
                    ) {
                        withAnimation { selectedMealType = type }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(NutrivioTheme.primaryGreen.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "camera.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(NutrivioTheme.primaryGreen)
            }

            Text("No hay comidas registradas")
                .font(.headline)
                .foregroundStyle(NutrivioTheme.textPrimary)

            Text("Toma una foto de tu comida y la IA\nhara el resto")
                .font(.subheadline)
                .foregroundStyle(NutrivioTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - FAB

    private var addMealButton: some View {
        Button {
            showingCamera = true
        } label: {
            ZStack {
                Circle()
                    .fill(NutrivioTheme.greenGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: NutrivioTheme.primaryGreen.opacity(0.4), radius: 12, x: 0, y: 6)

                Image(systemName: "camera.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(isSelected ? .white : NutrivioTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? NutrivioTheme.primaryGreen : NutrivioTheme.primaryGreen.opacity(0.08))
            .clipShape(Capsule())
        }
    }
}

#Preview {
    FoodLogView()
        .environmentObject(NutritionViewModel())
}
