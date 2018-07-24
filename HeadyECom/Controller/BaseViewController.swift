//
//  BaseViewController.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Cart.itemCount() == 0 {
            self.navigationItem.rightBarButtonItem?.removeBadge()
        } else {
            self.navigationItem.rightBarButtonItem?.addBadge(number: Cart.itemCount())
        }
    }
    
    @objc func didTapCartBarButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CartVC") as! CartViewController
        vc.title = "Cart"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
