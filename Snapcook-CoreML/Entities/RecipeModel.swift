//
//  RecipeModel.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 18/06/25.
//

import Foundation

struct RecipeModel: Identifiable {
    var id = UUID()
    var time: Int
    var portion: Int
    var stepCount: Int
    var ingredients: [String]
    var image: String?
    var step: [String]
    var isCooked: Bool?
}
