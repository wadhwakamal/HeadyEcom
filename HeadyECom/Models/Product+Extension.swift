//
//  Product+Extension.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

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
