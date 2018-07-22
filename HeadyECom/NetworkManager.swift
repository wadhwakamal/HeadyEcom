//
//  NetworkManager.swift
//  HeadyECom
//
//  Created by Personal on 22/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class NetworkManager {
    
    class func fetchProducts() {
        guard let jsonData = stubbedResponse("ecommerce"),
            let json = try? JSON(data: jsonData),
            let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let moc = appDelegate.persistentContainer.newBackgroundContext()
        moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump        
        
        Category.fromJSON(json: json, moc: moc)
        Ranking.fromJSON(json: json, moc: moc)
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
}

func stubbedResponse(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    guard let path = bundle.path(forResource: filename, ofType: "json") else  { return nil }
    return (try? Data(contentsOf: URL(fileURLWithPath: path)))
}
