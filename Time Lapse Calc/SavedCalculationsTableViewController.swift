//
//  SavedCalculationsTableViewController.swift
//  Time Lapse Calc
//
//  Created by 1024 on 27.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation



class SavedCalculationsTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var calculations = [Calculation]()
    
    
    var fetchedResultsController: NSFetchedResultsController<Calculation>!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        let backgroundImage = UIImage(named: "BG")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView
        tableView.rowHeight = 100.0
        
        let fetchRequest: NSFetchRequest<Calculation> = Calculation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,     // fetched results controller will group the search results based on the value of the category attribute
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        self.fetchedResultsController = fetchedResultsController
        perfomFetch()
        
    }

    func perfomFetch() {
        do {
            try fetchedResultsController.performFetch()

            let sectionInfo = fetchedResultsController.sections![0]
            let count = sectionInfo.numberOfObjects
            print("Objects count = \(count)")
        } catch {
            fatalCoreDataError(error: error)
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
        print("deinit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calculationCell", for: indexPath) as! CalculationCell
        let calculation = fetchedResultsController.object(at: indexPath)
        cell.configure(forCalculation: calculation)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCalculation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! SavingViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let calculation = fetchedResultsController.object(at: indexPath)
                controller.calculationToEdit = calculation
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let calculation = fetchedResultsController.object(at: indexPath)
            calculation.removePhotoFile()
            managedObjectContext.delete(calculation)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error: error)
            }
        }

    }
}

extension SavedCalculationsTableViewController:  NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent ***")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? CalculationCell {
                let calculation = controller.object(at: indexPath!) as! Calculation
                cell.configure(forCalculation: calculation)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .update:
            print("*** NSFetchedResultController UPDATE section ***")
        case .move:
            print("*** NSFetchedResultController Move section ***")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}












