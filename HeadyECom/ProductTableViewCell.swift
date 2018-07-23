//
//  ProductTableViewCell.swift
//  HeadyECom
//
//  Created by Personal on 23/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit

protocol ProductTableViewCellDelegate: class {
    func didTapBuyButton(variant: Variant)
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
        sizeLabel.text = "\(variant.size)"
        colorLabel.text = variant.color
    }

    @IBAction func didTapBuyButton(_ sender: Any) {
        delegate?.didTapBuyButton(variant: self.variant)
    }
}
