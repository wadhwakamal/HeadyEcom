//
//  RankingViewController.swift
//  HeadyECom
//
//  Created by Personal on 23/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import CoreData

class RankingViewController: BaseViewController {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    let rankingFetchRequest: NSFetchRequest<Ranking> = Ranking.fetchRequest()
    let productFetchRequest: NSFetchRequest<Product> = Product.fetchRequest()

    lazy var productFetchResultsController: NSFetchedResultsController<Product> = {
        let moc = CoreDataManager.shared.viewContext()
        moc.automaticallyMergesChangesFromParent = true
        let resultsController = NSFetchedResultsController<Product>(fetchRequest: productFetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        
        return resultsController
    }()
    
    lazy var rankingFetchResultsController: NSFetchedResultsController<Ranking> = {
        let moc = CoreDataManager.shared.viewContext()
        moc.automaticallyMergesChangesFromParent = true
        return NSFetchedResultsController<Ranking>(fetchRequest: rankingFetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    
    // MARK: - Methods
    func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"shopping-cart"), style: .plain, target: self, action: #selector(RankingViewController.didTapCartBarButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"list"), style: .plain, target: self, action: #selector(RankingViewController.didTapListBarButton))
    }
    
    func setupContent() {
        self.title = "Products"
        do {
            rankingFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            productFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            productFetchRequest.predicate = nil
            try rankingFetchResultsController.performFetch()
            try productFetchResultsController.performFetch()
        } catch {
            print("Unable to fetch Category Data \(error)")
        }
    }
    
    func showAction() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let productAction: UIAlertAction = UIAlertAction(title: "All Products", style: .default) { [weak self] action -> Void in
            self?.setupContent()
            self?.tableView.reloadData()
        }
        actionSheetController.addAction(productAction)
        
        for ranking in rankingFetchResultsController.fetchedObjects! {
            guard let rankingName = ranking.name else { continue }
            let action: UIAlertAction = UIAlertAction(title: rankingName, style: .default) { [weak self] action -> Void in
                self?.sortContentBy(ranking: ranking)
            }
            actionSheetController.addAction(action)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        // add actions
        actionSheetController.addAction(cancelAction)
        
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }

    func sortContentBy(ranking: Ranking) {
        guard let rankingName = ranking.name, let rankBy = ranking.rankBy else { return }
        
        self.title = rankingName
        let sortDescriptor = NSSortDescriptor(key: rankBy, ascending: false)
        let predicate = NSPredicate(format: "\(rankBy) > 0")
        productFetchRequest.sortDescriptors = [sortDescriptor]
        productFetchRequest.predicate = predicate
        do {
            try productFetchResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Unable to fetch Category Data \(error)")
        }
    }
    
    // MARK: Actions
    @objc func didTapListBarButton() {
        showAction()
    }
    
    // MARK: Lifecycle methods
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RankingViewController: UITableViewDataSource, UITableViewDelegate {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = productFetchResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
        configureProductCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureProductCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let product = productFetchResultsController.object(at: indexPath)
        cell.textLabel?.text = product.name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = productFetchResultsController.object(at: indexPath)
        segueToProduct(product: product)
    }
    
    // MARK: - Segue
    func segueToProduct(product: Product) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductVC") as! ProductViewController
        vc.product = product
        vc.title = product.category?.name
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension RankingViewController: NSFetchedResultsControllerDelegate {
    
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
                    configureProductCell(cell, indexPath: indexPath)
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

