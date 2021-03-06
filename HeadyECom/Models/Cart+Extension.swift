//
//  Cart+Extension.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Cart {
    
    class func itemCount() -> Int {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            return result.count
        }
        return 0
    }
    
    class func add(productID: String, variantID: String) {
        let moc = CoreDataManager.shared.newBackgroundContext()
        moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        if let cart = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: moc) as? Cart {
            cart.productID = productID
            cart.variantID = variantID
            var predicate = NSPredicate(format: "id == %@", variantID)
            if let variant = CoreDataManager.fetchObjects(from: Variant.self, moc: moc, predicate: predicate)?.first {
                cart.variant = variant
            }
            
            predicate = NSPredicate(format: "id == %@", productID)
            if let product = CoreDataManager.fetchObjects(from: Product.self, moc: moc, predicate: predicate)?.first {
                cart.product = product
            }
        }
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                print(error)
            }
        }
    }
    
    class func totalAmount() -> Double {
        let context = CoreDataManager.shared.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        var amount: Double = 0
        
        if let result = try? context.fetch(fetchRequest) {
            for cart in result {
                if let price = cart.variant?.price, let tax = cart.product?.taxValue {
                    amount += Double(price) + Double(Float(price)*tax/100)
                }
            }
        }
        return amount
    }
    
    class func clear() {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object)
            }
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
