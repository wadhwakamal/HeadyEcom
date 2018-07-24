//
//  Variant+Extension.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

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
