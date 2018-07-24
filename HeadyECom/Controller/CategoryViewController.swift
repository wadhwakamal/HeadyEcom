//
//  CategoryViewController.swift
//  HeadyECom
//
//  Created by Personal on 22/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import CoreData

enum ContentType {
    case category, product, none
}

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parentCategory: Category?
    var contentType = ContentType.none
    
    lazy var categoryResults: NSFetchedResultsController<Category> = {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        moc.automaticallyMergesChangesFromParent = true
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        if let category = parentCategory, let parentID = category.id {
            fetchRequest.predicate = NSPredicate(format: "parentID == %@", parentID)
        } else {
            fetchRequest.predicate = NSPredicate(format: "parentID == nil")
        }
        
        let resultsController = NSFetchedResultsController<Category>(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        
        return resultsController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if parentCategory == nil {
            NetworkManager.fetchProducts { 
                
            }
        }
        self.navigationItem.rightBarButtonItem?.addBadge(number: Cart.itemCount())
    }
    
    func setupContent() {
        do {
            try categoryResults.performFetch()
        } catch {
            print("Unable to fetch Category Data \(error)")
        }
    }
    
    @objc func didTapCart() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CartVC") as! CartViewController
        vc.title = "Cart"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"shopping-cart"), style: .plain, target: self, action: #selector(CategoryViewController.didTapCart))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.setupContent()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = categoryResults.sections {
            let currentSection = sections[section]
            
            if currentSection.numberOfObjects > 0 {
                contentType = .category
                return currentSection.numberOfObjects
            } else if let products = parentCategory?.products?.allObjects as? [Product], products.count > 0 {
                contentType = .product
                return products.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCategory", for: indexPath)
        
        switch contentType {
        case .category:
            configureCategoryCell(cell, indexPath: indexPath)
        case .product:
            configureProductCell(cell, indexPath: indexPath)
        default:
            assert(false, "Content type is not handled properly. Please check the data in categories and products. Also make sure proper contentType is implemented")
        }
        return cell
    }
    
    func configureCategoryCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let category = categoryResults.object(at: indexPath)
        cell.textLabel?.text = category.name
    }
    
    func configureProductCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let product = parentCategory?.products?.allObjects[indexPath.row] as? Product else { return }
        cell.textLabel?.text = product.name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch contentType {
        case .category:
            let category = categoryResults.object(at: indexPath)
            segueToSubCategory(category: category)
        case .product:
            guard let product = parentCategory?.products?.allObjects[indexPath.row] as? Product else { return }
            segueToProduct(product: product)
        default:
            assert(false, "Content type is not handled properly. Please check the data in categories and products. Also make sure proper contentType is implemented")
        }
    }
    
    func segueToSubCategory(category: Category) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryViewController
        vc.parentCategory = category
        vc.title = category.name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func segueToProduct(product: Product) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductVC") as! ProductViewController
        vc.product = product
        vc.title = self.parentCategory?.name
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: NSFetchedResultsControllerDelegate {
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
                if let cell = tableView.cellForRow(at: indexPath) {
                    configureCategoryCell(cell, indexPath: indexPath)
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
    }
}
