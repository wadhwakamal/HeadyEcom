//
//  Ranking+Extension.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

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
                            
                            if let product = CoreDataManager.fetchObjects(from: Product.self, moc: moc, predicate: predicate)?.first {
                                if let orderCount = productJSON[kRankingsProductsOrderCountKey].int64 {
                                    ranking.rankBy = kRankingsProductsOrderCountKey
                                    product.order_count = orderCount
                                }
                                
                                if let shares = productJSON[kRankingsProductsSharesKey].int64 {
                                    ranking.rankBy = kRankingsProductsSharesKey
                                    product.shares = shares
                                }
                                
                                if let viewCount = productJSON[kRankingsProductsViewCountKey].int64 {
                                    ranking.rankBy = kRankingsProductsViewCountKey
                                    product.view_count = viewCount
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
