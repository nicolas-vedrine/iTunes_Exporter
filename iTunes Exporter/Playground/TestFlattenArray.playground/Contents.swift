import Cocoa

var theArray:[Any] = [1,2,[[3,4],[5,6,[7]]],8]
let theFlat = flattenedArray(array: theArray)
var theTest = Test()
theTest.str = "kkkdd"
theTest.number = 14598
var theTest2 = Test()
theTest2.str = "nsnsnsqhq"
theTest.number = 478841
let rosie = [[42, "thirty-nine", 56, [theTest, theTest2]], "all"] as [Any]

let theFlat2 = flatten(rosie)


func flattenedArray(array:[Any]) -> [Int] {
    var myArray = [Int]()
    for element in array {
        if let element = element as? Int {
            myArray.append(element)
        }
        if let element = element as? [Any] {
            let result = flattenedArray(array: element)
            for i in result {
                myArray.append(i)
            }

        }
    }
    return myArray
}

func flatten(_ array: [Any]) -> [Any] {
    var result = [Any]()
    for element in array {
        if let element = element as? [Any] {
            result.append(contentsOf: flatten(element))
        } else {
            result.append(element)
        }
    }
    return result
}


struct Test {
    var str: String = ""
    var number: Int = 1
}
