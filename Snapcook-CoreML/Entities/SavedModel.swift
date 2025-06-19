//
//  SavedModel.swift
//  Snapcook-CoreML
//
//  Created by Heryan Cahya Febriansyah on 18/06/25.
//

import SwiftData

@Model
class ExcludedIngredient {
    @Attribute(.unique) var name: String

    init(name: String) {
        self.name = name
    }
}

@Model
class ExcludedRecipe {
    @Attribute(.unique) var id: String

    init(id: String) {
        self.id = id
    }
}


@Model
class CookedRecipe {
    @Attribute(.unique) var id: String

    init(id: String) {
        self.id = id
    }
}
