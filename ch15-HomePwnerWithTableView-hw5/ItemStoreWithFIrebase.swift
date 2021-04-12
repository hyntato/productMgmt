//
//  ItemStoreWithFIrebase.swift
//  ch15-HomePwnerWithTableView-hw5
//
//  Created by admin01 on 2020/06/29.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ItemStoreWithFirebase: ItemStore {
    
    enum NotifyAction {
        case added
        case removed
        case modified
    }
    
    var reference: DatabaseReference
    var listener: ((NotifyAction, Int) -> Void)?
    
    override init() {
        reference = Database.database().reference().child("itemStore")
        super.init()
        
        reference.observe(.childAdded, with: notifyItemAdded)
        reference.observe(.childRemoved, with: notifyItemRemoved)
        reference.observe(.childChanged, with: notifyItemModified)
    }
    
    func setListener(listener: @escaping (NotifyAction, Int) -> Void) {
        self.listener = listener
    }
    
    func dicToItem(dic: [String: Any?]) -> Item {
        var item = Item(random: true)
        item.name = dic["name"] as! String
        item.serialNumber = dic["serialNumber"] as? String
        item.valueInDollars = dic["valueInDollars"] as! Int
        item.dateCreated = Date(timeIntervalSince1970: dic["dateCreated"] as! TimeInterval)
        item.itemKey = dic["itemKey"] as! String
        
        return item
    }
    
    func itemToDic(item: Item) -> [String: Any?] {
        var dic = [String: Any?]()
        dic["name"] = item.name
        dic["serialNumber"] = item.serialNumber
        dic["valueInDollars"] = item.valueInDollars
        dic["dateCreated"] = item.dateCreated.timeIntervalSince1970  // data type cannot serialize to json
        dic["itemKey"] = item.itemKey
        
        return dic
    }
    
    func notifyItemAdded(dataSnapshot: DataSnapshot) {
        // let key = dataSnapshot.key
        let item = dicToItem(dic: dataSnapshot.value as! [String: Any?])
        
        super.addItem(item: item)
        
        if let listener = listener {
            listener(.added, allItems.count - 1)
        }
    }
    
    func notifyItemRemoved(dataSnapshot: DataSnapshot) {
        
        let key = dataSnapshot.key
        //super.removeItem(key: key)
        
        for i in 0..<allItems.count {
            if allItems[i].itemKey == key {
                allItems.remove(at: i)
                if let listener = listener {
                    listener(.removed, i)
                }
                break
            }
        }
    }
    
    func notifyItemModified(dataSnapshot: DataSnapshot) {
        
        let key = dataSnapshot.key
        let item = dicToItem(dic: dataSnapshot.value as! [String: Any?])
        //super.modifyItem(key: key)
        
        for i in 0..<allItems.count {
            if allItems[i].itemKey == key {
                allItems[i] = item
                if let listener = listener {
                    listener(.modified, i)
                }
                break
            }
        }
    }
    
    override func addItem(item: Item) {
        let dic = itemToDic(item: item)
        
        reference.child(item.itemKey).setValue(dic)
    }
    
    override func removeItem(key: String) {
        reference.child(key).setValue(nil)
    }
    
    override func modifyItem(item: Item, key: String) {
        let dic = itemToDic(item: item)
        reference.child(key).setValue(dic)  // 키가 있으면 업데이트, 없으면 새로생성
    }

}

