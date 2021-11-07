import UIKit

let aaa: Int = 10

let labels = (0...aaa).map({ _ in
    return UILabel()
})
print(labels)
