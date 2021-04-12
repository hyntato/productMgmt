//
//  itemStoreWithFireStore.swift
//  ch15-HomePwnerWithTableView-hw5
//
//  Created by admin01 on 2020/06/30.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ItemStoreWithFireStore: ItemStore {
    
    enum NotifyAction {
        case removed
        case modified
        case searched // 검색 액션 추가
    }
    
    let collection = Firestore.firestore().collection("itemStore")
    var listenerRegistration: ListenerRegistration?
    var listener: ((NotifyAction, Int) -> Void)?
    
    func setListener(listener: @escaping (NotifyAction, Int) -> Void) {
        self.listener = listener
    }
    
    func notifyItemRemoved() {
    
        // Firestore가 삭제된 아이템을 감지하여 알려줌
        listenerRegistration = collection.addSnapshotListener( {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else { return }
            for documentChange in querySnapshot.documentChanges {
                
                if documentChange.type == .removed {
                    let itemKey = self.dicToItem(dic: documentChange.document.data()).itemKey
                    
                    let index = self.getIndexByItemkey(key: itemKey)
                    if index != -1 {
                        self.allItems.remove(at: index)
                        
                        if let listener = self.listener {
                            listener(.removed, index)
                        }
                    }
                }
            }
        })
    }
    
    func notifyItemModified() {
        
        // Firestore가 변경된 아이템을 감지하여 알려줌
        listenerRegistration = collection.addSnapshotListener( {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else { return }
            for documentChange in querySnapshot.documentChanges {
                
                if documentChange.type == .modified {
                    let item = self.dicToItem(dic: documentChange.document.data())
                    let itemKey = item.itemKey
                    
                    let index = self.getIndexByItemkey(key: itemKey)
                    if index != -1 {
                        self.allItems[index] = item
                        if let listener = self.listener {
                            listener(.modified, index)
                        }
                    }
                }
            }
        })
    }
    
    // 검색 뿐만 아니라 아이템 추가 시에도 이 리스너를 통해 알림을 받음
    func notifyItemSearched(queryStr: String) {
        
        // 리스너가 listenerRegistration에 계속 쌓이는 것을 방지
        if let listener = listenerRegistration {
            listener.remove()
        }
        
        // 텍스트 필드의 스트링으로 시작하는 아이템들만 추출하기 위한 쿼리 작성
        let query = collection.whereField("name", isGreaterThanOrEqualTo: queryStr)
            .whereField("name", isLessThanOrEqualTo: queryStr+"~")
        
        // 쿼리를 만족하는 아이템들을 알려줌
        listenerRegistration = query.addSnapshotListener {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else { return }
            for documentChange in querySnapshot.documentChanges {
                
                if documentChange.type == .added {
                    let item = self.dicToItem(dic: documentChange.document.data())
                    super.addItem(item: item)
                    
                    if let listener = self.listener {
                        listener(.searched, self.allItems.count - 1)
                    }
                }
            }
            
        }
        
        // 검색 기능이 활성화 되면 아이템 삭제, 변경을 감지하는 리스너도 Firestore에 연결
        notifyItemRemoved()
        notifyItemModified()
        
    }
    
    // item의 key를 이용해 item의 index를 찾아주는 함수
    func getIndexByItemkey(key: String) -> Int {
        for i in 0..<allItems.count {
            if allItems[i].itemKey == key {
                return i
            }
        }
        return -1
    }
    
    // Firestore에 아이템 저장(추가)
    override func addItem(item: Item) {
        print("itemStoreWith    Firestore: addItem")
        let dic = itemToDic(item: item)
        collection.document(item.itemKey).setData(dic)
    }
    
    // Firestore에 아이템 삭제
    override func removeItem(key: String) {
        print("itemStoreWith    Firestore: removeItem")
        collection.document(key).delete()
    }
    
    // Firestore에 아이템 변경
    override func modifyItem(item: Item, key: String) {
        print("itemStoreWith    Firestore: modifyItem")
        let dic = itemToDic(item: item)
        collection.document(key).updateData(dic)
    }
    
    func dicToItem(dic: [String: Any]) -> Item {
        let item = Item(random: true)
        item.name = dic["name"] as! String
        item.serialNumber = dic["serialNumber"] as? String
        item.valueInDollars = dic["valueInDollars"] as! Int
        item.dateCreated = Date(timeIntervalSince1970: dic["dateCreated"] as! TimeInterval)
        item.itemKey = dic["itemKey"] as! String
        
        return item
    }
    
    func itemToDic(item: Item) -> [String: Any] {
        var dic = [String: Any]()
        dic["name"] = item.name
        dic["serialNumber"] = item.serialNumber
        dic["valueInDollars"] = item.valueInDollars
        dic["dateCreated"] = item.dateCreated.timeIntervalSince1970  // data type cannot serialize to json
        dic["itemKey"] = item.itemKey
        
        return dic
    }
    
}
