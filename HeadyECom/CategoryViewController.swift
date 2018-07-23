//
//  CategoryViewController.swift
//  HeadyECom
//
//  Created by Personal on 22/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var parentCategory: Category?
    
    var categories = [Category]()
    var products = [Product]()
    
    lazy var categoryResults: NSFetchedResultsController<Category> = {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        if let category = parentCategory, let parentID = category.id {
            fetchRequest.predicate = NSPredicate(format: "parentID == %@", parentID)
        } else {
            fetchRequest.predicate = NSPredicate(format: "parentID == nil")
        }

        let FRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        FRC.delegate = self
        return FRC
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if parentCategory == nil {
            NetworkManager.fetchProducts { [weak self] in
                
            }
        }
    }
    
    func setupContent() {
        do {
            try categoryResults.performFetch()
            
            if let categories = categoryResults.fetchedObjects {
                self.categories = categories
            }
            
            if let category = parentCategory, let products = category.products?.allObjects as? [Product] {
                self.products = products
            }

            tableView.reloadData()
        } catch {
            print("Unable to fetch Category Data \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = categoryResults.fetchedObjects?.count, count > 0 {
            return count
        }
        
        if let category = self.parentCategory, let count = category.products?.allObjects.count, count > 0 {
            return count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCategory", for: indexPath)
        if let categories = categoryResults.fetchedObjects, categories.isNotEmpty {
            let category = categories[indexPath.row]
            cell.textLabel?.text = category.name
            cell.detailTextLabel?.text = ""
            
            if let subCategory = category.subCategory {
                cell.detailTextLabel?.text = (Array(subCategory) as! [Category]).flatMap { $0.name }.joined(separator: "-")
            }
        } else if let product = self.parentCategory?.products?.allObjects[indexPath.row] as? Product {
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = "\(product.taxName ?? "") \(product.taxValue)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let categories = categoryResults.fetchedObjects, categories.isNotEmpty {
            let category = categories[indexPath.row]
            segueToSubCategory(category: category)
        }
    }
    
    func segueToSubCategory(category: Category) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CategoryController") as! CategoryViewController
        vc.parentCategory = category
        vc.title = category.name
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
