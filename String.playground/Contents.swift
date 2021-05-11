import UIKit

var str = "🤷‍♀️👨‍👩‍👧‍👦👪💏💑abv我来了"
print(str.count)
print(str.utf16.count)
print((str as NSString).length)
let startIndex = str.startIndex
let endIndex = str.endIndex
let offsetIndex = str.index(startIndex, offsetBy: str.count)
let range = startIndex..<offsetIndex
let subStr = String(str[range])
print(subStr.count)
print(subStr)
