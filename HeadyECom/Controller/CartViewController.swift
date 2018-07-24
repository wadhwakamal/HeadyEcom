//
//  CartViewController.swift
//  HeadyECom
//
//  Created by Personal on 24/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import CoreData

class CartViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var emptyCartView: UIView!
    
//    var totalAmount: Double = 0
    
//    var amount: Double {
//        get {
//            return totalAmount
//        }
//        set {
////            totalAmount += newValue
//            totalAmountLabel.text = "TOTAL: \(totalAmount)"
//        }
//    }
    
    lazy var fetchResultsController: NSFetchedResultsController<Cart> = {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        moc.automaticallyMergesChangesFromParent = true
        
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "productID", ascending: true)]
        
        let resultsController = NSFetchedResultsController<Cart>(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        
        return resultsController
    }()
    
    @IBAction func didTapBuyButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Thankyou", message: "Purchase is successful", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { [weak self] (result : UIAlertAction) -> Void in
            self?.clearCart()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func clearCart() {
        Cart.clear()
    }
    
    func setupContent() {
        do {
            try fetchResultsController.performFetch()
            if let count = fetchResultsController.fetchedObjects?.count, count > 0 {
                emptyCartView.isHidden = true
                emptyCartView.alpha = 0
            }
        } catch {
            print("Unable to fetch Category Data \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        totalAmountLabel.text = "TOTAL: \(Cart.totalAmount())"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CartTableViewCell", bundle: nil), forCellReuseIdentifier: "CartCell")
        setupContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartTableViewCell
        configureCartCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCartCell(_ cell: CartTableViewCell, indexPath: IndexPath) {
        let cart = fetchResultsController.object(at: indexPath)

        if let price = cart.variant?.price,
            let tax = cart.product?.taxValue,
            let color = cart.variant?.color,
            let name = cart.product?.name,
            let size = cart.variant?.size {
            
            cell.productNameLabel.text =  name
            cell.sizeLabel.text = size > 0 ? "\(size)" : "NA"
            cell.priceLabel.text = "\(price)"
            cell.taxLabel.text = "TAX: \(cart.product?.taxName ?? "") \(tax)"
            cell.colorLabel.text = "\(color)"
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}

extension CartViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRow(at: indexPath) as? CartTableViewCell {
                    configureCartCell(cell, indexPath: indexPath)
                }
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        if let count = fetchResultsController.fetchedObjects?.count, count == 0 {
            emptyCartView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.emptyCartView.alpha = 1
            })
            
        }
    }
}
