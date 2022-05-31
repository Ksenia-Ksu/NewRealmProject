

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: Constants.TextForAlerts.alertAddCategoryAction, message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.TextForAlerts.alertAddCategoryAction
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: Constants.TextForAlerts.addCategoryAction, style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            self.save(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.categoryCellIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        content.text = categories?[indexPath.row].name ?? "No categories added yet"
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Identifiers.segueFromCategoryToItems, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.segueFromCategoryToItems {
            
            let destinationVC = segue.destination as! ToDoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.selectedCategory = categories?[indexPath.row]
                
            }
        }
        
    }
    
    
    //MARK: - Saving and loading data methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch  {
            print("Error saving category \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Swipe actions - delete and edit
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let category = categories?[indexPath.row] {
            let deleteAction = UIContextualAction(style: .destructive, title: Constants.TextForSwipes.delete) { _, _, _ in
                do {
                    try self.realm.write {
                        self.realm.delete(category)
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
                tableView.reloadData()
            }
            
            let editAction = UIContextualAction(style: .normal, title: Constants.TextForSwipes.edit) { _, _, _ in
                
                let alert = UIAlertController(title: Constants.TextForSwipes.editCategory, message: "", preferredStyle: .alert)
                
                var textField = UITextField()
                
                alert.addTextField { (alertTextField)  in
                    textField = alertTextField
                    textField.text = category.name
                    
                }
                
                let updateAction = UIAlertAction(title: Constants.TextForAlerts.save, style: .default) { action in
                    do {
                        try self.realm.write {
                            category.name = textField.text!
                        }
                    } catch {
                        print("Error updating name of category, \(error)")
                        
                    }
                    tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
                alert.addAction(updateAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
            
            
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
            
            return swipeActions
            
        }
        
        return nil
    }
    
}



