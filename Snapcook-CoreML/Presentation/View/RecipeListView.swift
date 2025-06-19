import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: RecipeViewModel? = nil

    var body: some View {
        Group {
            if let viewModel = viewModel {
                RecipeListContent(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            if viewModel == nil {
                let filterVM = FilterViewModel(context: context)
                let recipeVM = RecipeViewModel(recipeManager: RecipeManager(), filterViewModel: filterVM)
                viewModel = recipeVM
            }
        }
    }
}

struct RecipeListContent: View {
    @StateObject var viewModel: RecipeViewModel

    var body: some View {
        List(viewModel.recipes) { recipe in
            Text(recipe.ingredients.joined(separator: ", "))
        }
        .task {
            await viewModel.loadAndFilterRecipes(ingredients: ["bawang", "cabai"])
        }
    }
}
