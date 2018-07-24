//
//  Category+Extension.swift
//  HeadyECom
//
//  Created by Personal on 22/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Category {
    
    struct Stack {
        fileprivate var jsonArray: [JSON] = []
        
        var isEmpty: Bool {
            return jsonArray.isEmpty
        }
        
        var count: Int {
            return jsonArray.count
        }
        
        mutating func push(_ element: JSON) {
            jsonArray.append(element)
        }

        mutating func pop() -> JSON? {
            return jsonArray.popLast()
        }
    }
    
    
    
    @discardableResult
    static func fromJSON(json: JSON, moc: NSManagedObjectContext) -> [Category] {
        let kCategoryCategoriesKey: String = "categories"
        let kCategoriesProductsKey: String = "products"
        let kCategoriesInternalIdentifierKey: String = "id"
        let kCategoriesChildCategoriesKey: String = "child_categories"
        let kCategoriesNameKey: String = "name"
        
        var categories = [Category]()
        var categoryStack = Stack()
        
        func createCategory(categoryJSON: JSON, moc: NSManagedObjectContext) {
            if let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: moc) as? Category {
                category.id = "\(categoryJSON[kCategoriesInternalIdentifierKey].intValue)"
                category.name = categoryJSON[kCategoriesNameKey].string
                
                // Persisting Products
                if let productsJSON = categoryJSON[kCategoriesProductsKey].array, productsJSON.isNotEmpty {
                    for productJSON in productsJSON {
                        if let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: moc) as? Product {
                            product.populate(fromJSON: productJSON, moc: moc)
                            category.addToProducts(product)
                        }
                    }
                }
                
                // Persisting Subcategories
                if let subCategoriesJSON = categoryJSON[kCategoriesChildCategoriesKey].array, subCategoriesJSON.isNotEmpty {
                    let predicate = NSPredicate(format: "id IN %@", subCategoriesJSON.map { "\($0.intValue)" })
                    if let subCategories = CoreDataManager.fetchObjects(from: Category.self, moc: moc, predicate: predicate), subCategories.isNotEmpty {
                        for subCategory in subCategories {
                            subCategory.parentID = category.id
                            category.addToSubCategory(subCategory)
                        }
                    } else {
                        // Pusing Parent category to stack to allow them to have child categories once child categories are added in context
                        categoryStack.push(categoryJSON)
                    }
                }
                categories.append(category)
            }
        }
        
        if let categoriesJSON = json[kCategoryCategoriesKey].array {
            for categoryJSON in categoriesJSON {
                createCategory(categoryJSON: categoryJSON, moc: moc)
            }
            
            while !categoryStack.isEmpty {
                guard let categoryJSON = categoryStack.pop() else { continue }
                createCategory(categoryJSON: categoryJSON, moc: moc)
            }
        }
        return categories
    }
}


