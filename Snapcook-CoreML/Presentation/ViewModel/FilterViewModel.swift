import Foundation
import SwiftData

@MainActor
class FilterViewModel: ObservableObject {
    @Published var excludedIngredients: [ExcludedIngredient] = []
    @Published var excludedRecipes: [ExcludedRecipe] = []

    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
        fetchExcludedIngredients()
        fetchExcludedRecipes()
    }

    // MARK: - Ingredients

    func fetchExcludedIngredients() {
        do {
            let descriptor = FetchDescriptor<ExcludedIngredient>()
            excludedIngredients = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch ingredients: \(error)")
        }
    }

    func addExcludedIngredient(_ name: String) {
        guard !excludedIngredients.contains(where: { $0.name == name }) else { return }
        let newItem = ExcludedIngredient(name: name)
        modelContext.insert(newItem)
        try? modelContext.save()
        fetchExcludedIngredients()
    }

    func deleteExcludedIngredient(_ item: ExcludedIngredient) {
        modelContext.delete(item)
        try? modelContext.save()
        fetchExcludedIngredients()
    }

    // MARK: - Recipes

    func fetchExcludedRecipes() {
        do {
            let descriptor = FetchDescriptor<ExcludedRecipe>()
            excludedRecipes = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch recipes: \(error)")
        }
    }

    func addExcludedRecipe(_ id: String) {
        guard !excludedRecipes.contains(where: { $0.id == id }) else { return }
        let recipe = ExcludedRecipe(id: id)
        modelContext.insert(recipe)
        try? modelContext.save()
        fetchExcludedRecipes()
    }

    func deleteExcludedRecipe(_ item: ExcludedRecipe) {
        modelContext.delete(item)
        try? modelContext.save()
        fetchExcludedRecipes()
    }
}
