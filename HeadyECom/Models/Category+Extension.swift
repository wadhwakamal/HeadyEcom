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
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.isSubCategory = false
    }
    
    static func fetchObjects<T: NSManagedObject>(from entityClass: T.Type, moc: NSManagedObjectContext, predicate: NSPredicate? = nil) -> [T]? {
        
        let entityName = String(describing: T.self)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = predicate
        
        do {
            let result = try moc.fetch(fetchRequest)
            return result
        } catch {
            print("Data not found")
        }
        return nil
    }
    
    @discardableResult
    static func fromJSON(json: JSON, moc: NSManagedObjectContext) -> [Category] {
        let kCategoryCategoriesKey: String = "categories"
        let kCategoriesProductsKey: String = "products"
        let kCategoriesInternalIdentifierKey: String = "id"
        let kCategoriesChildCategoriesKey: String = "child_categories"
        let kCategoriesNameKey: String = "name"
        
        var categories = [Category]()
        
        if let categoriesJSON = json[kCategoryCategoriesKey].array {
            for categoryJSON in categoriesJSON {

                if let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: moc) as? Category {
                    category.id = "\(categoryJSON[kCategoriesInternalIdentifierKey].intValue)"
                    category.name = categoryJSON[kCategoriesNameKey].string
                    
                    if let productsJSON = categoryJSON[kCategoriesProductsKey].array {
                        for productJSON in productsJSON {
                            if let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: moc) as? Product {
                                product.populate(fromJSON: productJSON, moc: moc)
                                category.addToProducts(product)
                            }
                        }
                    }

                    if let subCategoriesJSON = categoryJSON[kCategoriesChildCategoriesKey].array, subCategoriesJSON.isNotEmpty {
                        let predicate = NSPredicate(format: "id IN %@", subCategoriesJSON.map { "\($0.intValue)" })
                        if let subCategories = fetchObjects(from: Category.self, moc: moc, predicate: predicate) {
                            for subCategory in subCategories {
                                subCategory.isSubCategory = true
                                category.addToSubCategory(subCategory)
                            }
//                            category.isSubCategory = true
                        }
                    }
                    categories.append(category)
                }
            }
        }
        return categories
    }
}

extension Product {
    
    func populate(fromJSON json: JSON, moc: NSManagedObjectContext) {
        
        let kProductsNameKey: String = "name"
        let kProductsDateAddedKey: String = "date_added"
        let kProductsInternalIdentifierKey: String = "id"
        let kTaxKey: String = "tax"
        let kTaxNameKey: String = "name"
        let kTaxValueKey: String = "value"
        let kProductsVariantsKey: String = "variants"
        
        id = "\(json[kProductsInternalIdentifierKey].intValue)"
        name = json[kProductsNameKey].stringValue
        dateAdded = DateFormatter.iso8601.date(from: json[kProductsDateAddedKey].stringValue)
        taxName = json[kTaxKey][kTaxNameKey].stringValue
        taxValue = json[kTaxKey][kTaxValueKey].floatValue
        
        if let items = json[kProductsVariantsKey].array {
            for item in items {
                if let variant = NSEntityDescription.insertNewObject(forEntityName: "Variant", into: moc) as? Variant {
                    variant.populate(fromJSON: item)
                    self.addToVariants(variant)
                }
            }
        }
    }
}

extension Variant {
    func populate(fromJSON json: JSON) {
        let kVariantsInternalIdentifierKey: String = "id"
        let kVariantsSizeKey: String = "size"
        let kVariantsPriceKey: String = "price"
        let kVariantsColorKey: String = "color"
        
        id = "\(json[kVariantsInternalIdentifierKey].intValue)"
        size = json[kVariantsSizeKey].int64Value
        price = json[kVariantsPriceKey].int64Value
        color = json[kVariantsColorKey].string
    }
    
}

extension Ranking {
    @discardableResult
    static func fromJSON(json: JSON, moc: NSManagedObjectContext) -> [Ranking] {
        let kCategoryRankingsKey: String = "rankings"
        let kRankingsRankingKey: String = "ranking"
        let kRankingsProductsKey: String = "products"
        let kRankingsProductsInternalIdentifierKey: String = "id"
        let kRankingsProductsSharesKey: String = "shares"
        let kRankingsProductsViewCountKey: String = "view_count"
        let kRankingsProductsOrderCountKey: String = "order_count"
        
        var rankings = [Ranking]()
        
        if let rankingsJSON = json[kCategoryRankingsKey].array {
            for rankingJSON in rankingsJSON {
                if let ranking = NSEntityDescription.insertNewObject(forEntityName: "Ranking", into: moc) as? Ranking {
                    ranking.name = rankingJSON[kRankingsRankingKey].string
                    
                    if let productsJSON = rankingJSON[kRankingsProductsKey].array {
                        for productJSON in productsJSON {
                            let productID = "\(productJSON[kRankingsProductsInternalIdentifierKey].intValue)"
                            let predicate = NSPredicate(format: "id == %@", productID)
                            
                            if let product = Category.fetchObjects(from: Product.self, moc: moc, predicate: predicate)?.first {
                                if let orderCount = json[kRankingsProductsOrderCountKey].int64 {
                                    product.orderCount = orderCount
                                }
                                
                                if let shares = json[kRankingsProductsSharesKey].int64 {
                                    product.shares = shares
                                }
                                
                                if let viewCount = json[kRankingsProductsViewCountKey].int64 {
                                    product.viewCount = viewCount
                                }
                                
                                ranking.addToProducts(product)
                            }
                            
                        }
                    }
                    rankings.append(ranking)
                }
            }
        }
        return rankings
    }
}