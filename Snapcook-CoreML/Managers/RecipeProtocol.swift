import Foundation

protocol RecipeProtocol {
    func loadRecipes() async
    func getRecipes(ingredients: [String]) -> [RecipeModel]
    func getRecipe(by id: UUID) -> RecipeModel?
}
