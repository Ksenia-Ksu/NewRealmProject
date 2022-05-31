
import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var toDoTasks: Results<Task>?
    
    var selectedCategory : Category? {
        
        didSet {
            loadTasks()
        }
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: Constants.TextForAlerts.addTask, message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.TextForAlerts.addTaskPlaceholder
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: Constants.TextForAlerts.addTaskAction, style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                
                
                do {
                    try self.realm.write {
                        let newTask = Task()
                        newTask.title = textField.text!
                        newTask.done = false
                        currentCategory.tasks.append(newTask)
                    }
                } catch  {
                    print("Error saving new tasks, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoTasks?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.itemCellIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if let item = toDoTasks?[indexPath.row] {
            
            content.text = item.title
            
            if item.done {
                content.textProperties.color = .lightGray
            } else {
                content.textProperties.color = .black
            }
            
            cell.contentConfiguration = content
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            content.text = "No tasks added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let task = toDoTasks?[indexPath.row] {
            do {
                try realm.write {
                    task.done = !task.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    //MARK: - Saving and loading of items
    
    
    
    func loadTasks() {
        
        toDoTasks = selectedCategory?.tasks.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
    }
    
    //MARK: - Swipe actions - delete and edit
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let task = toDoTasks?[indexPath.row] {
            let deleteAction = UIContextualAction(style: .destructive, title: Constants.TextForSwipes.delete) { _, _, _ in
                do {
                    try self.realm.write {
                        self.realm.delete(task)
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
                tableView.reloadData()
            }
            
            let editAction = UIContextualAction(style: .normal, title: Constants.TextForSwipes.edit) { _, _, _ in
                
                let alert = UIAlertController(title: Constants.TextForSwipes.editTask, message: "", preferredStyle: .alert)
                
                var textField = UITextField()
                
                alert.addTextField { (alertTextField)  in
                    textField = alertTextField
                    textField.text = task.title
                    
                }
                
                let updateAction = UIAlertAction(title: Constants.TextForAlerts.save, style: .default) { action in
                    do {
                        try self.realm.write {
                            task.title = textField.text!
                        }
                    } catch {
                        print("Error updating done status, \(error)")
                        
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





//MARK: - SearchBar Delegate Methods
extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        
        toDoTasks = toDoTasks?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadTasks()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}




