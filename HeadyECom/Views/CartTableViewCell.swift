//
//  CartTableViewCell.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    
    
    func configure(cart: Cart) {
        if let price = cart.variant?.price,
            let tax = cart.product?.taxValue,
            let color = cart.variant?.color,
            let name = cart.product?.name,
            let size = cart.variant?.size {
            
            productNameLabel.text =  name
            sizeLabel.text = size > 0 ? "\(size)" : "NA"
            priceLabel.text = "\(price)"
            taxLabel.text = "TAX: \(cart.product?.taxName ?? "") \(tax)"
            colorLabel.text = "\(color)"
        }
    }
    
}
