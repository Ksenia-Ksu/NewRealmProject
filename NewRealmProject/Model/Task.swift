
import Foundation
import RealmSwift

class Task: Object {
    
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
