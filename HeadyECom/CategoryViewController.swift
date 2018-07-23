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
    
    var categories = [Category]()
    var products = [Product]()
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
            NetworkManager.fetchProducts { [weak self] in
//                tableView.reloadData()
                
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

//            tableView.reloadData()
        } catch {
            print("Unable to fetch Category Data \(error)")
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(CategoryViewController.reloadData), name: NSNotification.Name("NSManagedObjectContextDidSave"), object: nil)
    }
    
    @objc func reloadData() {
//        self.tableView.reloadData()
    }
    
    @objc func didTapCart() {
        print("CaRRT")
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories.count > 0 {
            contentType = .category
            return categories.count
        }
        
        if products.count > 0 {
            contentType = .product
            return products.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCategory", for: indexPath)
        
        switch contentType {
        case .category:
            let category = categories[indexPath.row]
            cell.textLabel?.text = category.name
            cell.detailTextLabel?.text = ""
            
            if let subCategory = category.subCategory {
                cell.detailTextLabel?.text = (Array(subCategory) as! [Category]).flatMap { $0.name }.joined(separator: "-")
            }
        case .product:
            let product = products[indexPath.row]
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = nil
            
        default:
            assert(false, "Content type is not handled properly. Please check the data in categories and products. Also make sure proper contentType is implemented")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch contentType {
        case .category:
            let category = categories[indexPath.row]
            segueToSubCategory(category: category)
        case .product:
            let product = products[indexPath.row]
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
