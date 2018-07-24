//
//  ProductTableViewCell.swift
//  HeadyECom
//
//  Created by Personal on 23/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit

protocol ProductTableViewCellDelegate: class {
    func didTapBuyButton(variant: Variant, sender: UIButton)
}

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var indexImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
    weak var delegate: ProductTableViewCellDelegate?
    
    var variant: Variant!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        indexImageView.layer.cornerRadius = 8
    }
    
    func configure(variant: Variant, index: Int) {
        self.variant = variant
        indexImageView.imageWith(number: "\(index)")
        priceLabel.text = "\(variant.price)"
        sizeLabel.text = variant.size > 0 ? "\(variant.size)" : "NA"
        colorLabel.text = variant.color
    }

    @IBAction func didTapBuyButton(_ sender: UIButton) {
        delegate?.didTapBuyButton(variant: self.variant, sender: sender)
    }
}
