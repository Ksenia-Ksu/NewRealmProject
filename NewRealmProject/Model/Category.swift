import Foundation
import RealmSwift

class Category: Object {
    
    @Persisted var name: String = ""
    @Persisted var tasks = List<Task>()
}
