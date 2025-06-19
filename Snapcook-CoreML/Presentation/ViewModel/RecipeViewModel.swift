import Foundation

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [RecipeModel] = []

    let recipeManager: RecipeProtocol
    let filterViewModel: FilterViewModel

    init(recipeManager: RecipeProtocol, filterViewModel: FilterViewModel) {
        self.recipeManager = recipeManager
        self.filterViewModel = filterViewModel
    }

    func loadAndFilterRecipes(ingredients: [String], cookedId: String? = nil) async {
        await recipeManager.loadRecipes()

        let excludedIngredients = filterViewModel.excludedIngredients.map(\.name)
        let excludedRecipes = filterViewModel.excludedRecipes.map(\.id)

        let filteredIngredients = ingredients.filter { !excludedIngredients.contains($0) }

        var allRecipes = recipeManager.getRecipes(ingredients: filteredIngredients)

        allRecipes = allRecipes.filter { !excludedRecipes.contains($0.id.uuidString) }

        if let id = cookedId {
            allRecipes = allRecipes.filter { $0.id.uuidString != id }
        }

        self.recipes = allRecipes
    }

    func applyRecipeSorting(fastestTime: Bool = false, largestPortion: Bool = false, smallestPortion: Bool = false) {
        if fastestTime {
            recipes.sort { $0.time < $1.time }
        } else if largestPortion {
            recipes.sort { $0.portion > $1.portion }
        } else if smallestPortion {
            recipes.sort { $0.portion < $1.portion }
        }
    }
}
