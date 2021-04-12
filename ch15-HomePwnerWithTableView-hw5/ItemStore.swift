//
//  ItemStore.swift
//  ch09-HomePwner
//
//  Created by Jae Moon Lee on 13/01/2020.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import Foundation

import UIKit
class ItemStore: NSObject {
    var allItems = [Item]()
    
    func addItem(item: Item) {
        allItems.append(item)
    }

    func modifyItem(item: Item, key: String) {
        for i in 0..<allItems.count {
            if allItems[i].itemKey == key {
                allItems[i] = item
                break
            }
        }
    }
    
    func removeItem(key: String){
        for i in 0..<allItems.count {
            if allItems[i].itemKey == key {
                allItems.remove(at: i)
                break
            }
        }
    }
    
    func moveItem(from: Int, to:Int){
        let item = allItems[from]
        allItems.remove(at: from)
        allItems.insert(item, at: to)
    }
    
}
