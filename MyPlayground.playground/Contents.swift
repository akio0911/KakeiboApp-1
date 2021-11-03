import UIKit

var greeting = "Hello, playground"

struct User {
    let id: String
    init?(id: String?) {
        guard let id = id else { return nil }
        self.id = id
    }
}

let sameUser = User(id: "12345")
let nilUser = User(id: nil)

func printId(id: String?) {
    guard let id = id else { return }
    print(id)
}
sameUser?.id
nilUser?.id

printId(id: sameUser?.id)
printId(id: nilUser?.id)

