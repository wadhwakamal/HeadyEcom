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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CartVC") as! CartViewController
        vc.title = "Cart"
        navigationController?.pushViewController(vc, animated: true)
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
    
    func sendToCart(_ sender: UIButton) {
        let buttonPosition : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)!
        
        let cell = tableView.cellForRow(at: indexPath) as! ProductTableViewCell
        
        let imageViewPosition : CGPoint = cell.indexImageView.convert(cell.indexImageView.bounds.origin, to: self.view)
        
        
        let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.indexImageView.frame.size.width, height: cell.indexImageView.frame.size.height))
        
        imgViewTemp.image = cell.indexImageView.image
        
        animation(dummyView: imgViewTemp)
    }
    
    func animation(dummyView : UIView)  {
        self.view.addSubview(dummyView)
        UIView.animate(withDuration: 1.0,
                       animations: {
                        dummyView.animationZoom(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                dummyView.animationZoom(scaleX: 0.2, y: 0.2)
                dummyView.animationRoted(angle: CGFloat(Double.pi))
                
                dummyView.frame.origin.x = self.view.bounds.width - 45
                dummyView.frame.origin.y = self.navigationController!.navigationBar.bounds.height - 8
                
            }, completion: { _ in
                
                dummyView.removeFromSuperview()
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.navigationItem.rightBarButtonItem?.addBadge(number: Cart.itemCount())
                    self.navigationItem.rightBarButtonItem!.animationZoom(scaleX: 1.4, y: 1.4)
                }, completion: {_ in
                    self.navigationItem.rightBarButtonItem!.animationZoom(scaleX: 1.0, y: 1.0)
                })
                
            })
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.rightBarButtonItem?.addBadge(number: Cart.itemCount())
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
    func didTapBuyButton(variant: Variant, sender: UIButton) {
        guard let id = product.id, let variantID = variant.id else { return }
        Cart.add(productID: id, variantID: variantID)
        
        sendToCart(sender)
//        navigationItem.rightBarButtonItem?.addBadge(number: 1)
        
    }
}
