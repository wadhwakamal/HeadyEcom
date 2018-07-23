//
//  ProductViewController.swift
//  HeadyECom
//
//  Created by Personal on 23/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductViewController: UIViewController {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var product: Product!
    var gradient: [CGColor]!
    var variants = [Variant]()
    
    var cartButton: UIBarButtonItem!
    
    func setupViews() {
        cartButton = UIBarButtonItem(image: UIImage(named:"shopping-cart"), style: .plain, target: self, action: #selector(ProductViewController.didTapCart))
        navigationItem.rightBarButtonItem = cartButton

        
        if let jsonData = stubbedResponse("gradient") {
            let json = JSON(jsonData)
            if let gradients = json.arrayObject as? [[String]] {
                let selectedIndex = Int.random(lower: 0, upper: gradients.count - 1)
                let gradientsInCGColor = gradients[selectedIndex].flatMap({ UIColor(hexString: $0)?.cgColor
                })
                self.gradient = gradientsInCGColor
                
            }
        }
        self.gradientView.gradientLayer.colors = self.gradient
        self.gradientView.gradientLayer.gradient = GradientPoint.topRightBottomLeft.draw()

        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        
    }
    
    @objc func didTapCart() {
        print("CaRRT")
    }
    
    func setupContent() {
        
        let textFontAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.strokeColor: UIColor.black.withAlphaComponent(0.2),
            NSAttributedStringKey.strokeWidth: -1
            ] as [NSAttributedStringKey : Any]

        self.productNameLabel.attributedText = NSMutableAttributedString(string: product.name?.uppercased() ?? "", attributes: textFontAttributes)
        
        if let variants = product.variants?.allObjects as? [Variant] {
            self.variants = variants
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ProductViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ProductTableViewCell
        cell.configure(variant: variants[indexPath.row], index: indexPath.row + 1)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}

extension ProductViewController: ProductTableViewCellDelegate {
    func didTapBuyButton(variant: Variant) {
        print(variant)
        navigationItem.rightBarButtonItem?.addBadge(number: 1)
    }
}
