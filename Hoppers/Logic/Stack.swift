//
//  Stack.swift
//  Hoppers
//
//  Created by Tamir on 07/07/2018.
//  Copyright © 2018 tamir. All rights reserved.
//

import Foundation

struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    mutating func clear() -> Void {
        items.removeAll()
    }
}
