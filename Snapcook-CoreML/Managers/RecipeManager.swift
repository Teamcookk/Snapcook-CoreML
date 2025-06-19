import Foundation

class RecipeManager: RecipeProtocol {
    private(set) var allRecipes: [RecipeModel] = []

    init() {}

    func loadRecipes() async {
        guard let path = Bundle.main.path(forResource: "Indonesian_Food_Recipes", ofType: "csv") else {
            print("CSV file not found")
            return
        }

        do {
            let content = try String(contentsOfFile: path)
            let lines = content.components(separatedBy: .newlines)

            // Offload heavy parsing to background thread
            allRecipes = try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    var parsed: [RecipeModel] = []

                    for line in lines.dropFirst() where !line.trimmingCharacters(in: .whitespaces).isEmpty {
                        let columns = self.parseCSVRow(line)
                        if let recipe = self.parseRecipe(from: columns) {
                            parsed.append(recipe)
                        }
                    }

                    continuation.resume(returning: parsed)
                }
            }

        } catch {
            print("Failed to read CSV: \(error)")
        }
    }

    func getRecipes(ingredients: [String]) -> [RecipeModel] {
        allRecipes.filter { recipe in
            !Set(recipe.ingredients).isDisjoint(with: ingredients)
        }
    }

    func getRecipe(by id: UUID) -> RecipeModel? {
        allRecipes.first { $0.id == id }
    }

    private func parseCSVRow(_ line: String) -> [String] {
        // Still a simple parser – use CodableCSV or SwiftCSV if you have quotes/commas inside values
        return line.split(separator: ",", omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private func parseRecipe(from columns: [String]) -> RecipeModel? {
        guard columns.count > 12 else { return nil }

        let uuid = UUID(uuidString: columns[0]) ?? UUID()
        let ingredients = columns[2].components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        let steps = columns[3].components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }

        return RecipeModel(
            id: uuid,
            time: Int(columns[7]) ?? 0,
            portion: Int(columns[6]) ?? 1,
            stepCount: Int(columns[12]) ?? steps.count,
            ingredients: ingredients,
            image: columns[5].isEmpty ? nil : columns[5],
            step: steps,
            isCooked: nil
        )
    }
}
