//
//  GroceryListViewController.swift
//  GroceryShopHelper
//
//  Created by Ashley Donohoe on 1/10/17.
//  Copyright © 2017 Ashley Donohoe. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBOutlet weak var groceryItemTable: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController<GroceryItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(GroceryListViewController.addItem))
        
        // gets grocery data and reloads table
        fetchGroceryListData()
        groceryItemTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        groceryItemTable.reloadData()
    }
    
    // Shows screen to add a new item
    func addItem() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "AddItemViewController") as! AddItemViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as UITableViewCell
        let groceryItem = fetchedResultsController.object(at: indexPath)
        // Show title and image based on favorited status
        cell.textLabel?.text = groceryItem.name
        if groceryItem.favorite {
            cell.imageView?.image = UIImage(named: "starfilled")
        } else {
            cell.imageView?.image = UIImage(named: "starnofill")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GroceryItemDetailViewController") as! GroceryItemDetailViewController
        controller.item = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete) {
            let itemToRemove = fetchedResultsController.object(at: indexPath)
            context.delete(itemToRemove)
            appDelegate.saveContext()
        }
    }
    
    // Provides sorting based on segment
    @IBAction func segmentChanged(_ sender: Any) {
        fetchGroceryListData()
        groceryItemTable.reloadData()
    }
    
    // Gets the GroceryItem objects from Core Data and sets the predicates
    func fetchGroceryListData() {
        let fetchRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        let showAllItems = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [showAllItems]
        
        if sortControl.selectedSegmentIndex == 1 {
            fetchRequest.predicate = NSPredicate(format: "favorite == %@", true as CVarArg)
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
            groceryItemTable.reloadData()
        } catch {
            showAlert(title: "Error", message: "Could not fetch data")
        }
    }
}
