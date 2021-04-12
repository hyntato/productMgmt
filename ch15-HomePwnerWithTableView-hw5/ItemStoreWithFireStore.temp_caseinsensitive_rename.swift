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
    
    var reference: CollectionPath!
    
    override init() {
        reference = Firestore.firestore().collection("itemStore")
    }
    
}
