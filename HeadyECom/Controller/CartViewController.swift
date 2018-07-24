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
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var emptyCartView: UIView!
    
    // MARK: Properties
    lazy var fetchResultsController: NSFetchedResultsController<Cart> = {
        let moc = CoreDataManager.shared.viewContext()
        moc.automaticallyMergesChangesFromParent = true
        
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "productID", ascending: true)]
        
        let resultsController = NSFetchedResultsController<Cart>(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        
        return resultsController
    }()
    
    // MARK: Actions
    @IBAction func didTapBuyButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Thankyou", message: "Purchase is successful", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { [weak self] (result : UIAlertAction) -> Void in
            self?.clearCart()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Methods
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
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CartTableViewCell", bundle: nil), forCellReuseIdentifier: "CartCell")
        setupContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        totalAmountLabel.text = "TOTAL: \(Cart.totalAmount())"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
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
        cell.configure(cart: cart)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}

// MARK: - NSFetchedResultsControllerDelegate
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
