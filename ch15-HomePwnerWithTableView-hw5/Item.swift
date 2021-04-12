//
//  Item.swift
//  ch09-HomePwner
//
//  Created by Jae Moon Lee on 13/01/2020.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import UIKit

class Item : NSObject {
    var name: String
    var valueInDollars: Int
    var serialNumber: String?
    var dateCreated: Date
    var itemKey: String
    
    init(name: String,
         serialNumber: String?,
         valueInDollars: Int){
        
        self.name = name
        self.valueInDollars = valueInDollars
        self.serialNumber = serialNumber
        self.dateCreated = Date()
        self.itemKey = NSUUID().uuidString
        
        //super.init()
    }
    
    convenience init(random: Bool = false){
        if random == false {
            self.init(name: "", serialNumber: nil, valueInDollars: 0)
            return
        }
        
        let adjectives = ["Fluffy", "Rusty", "Shiny"]
        let nouns = ["Bear", "Spork", "Mac"]
        
        var index = Int(arc4random_uniform(UInt32(adjectives.count)))
        let  randdomAdjective = adjectives[index]
        
        index = Int(arc4random_uniform(UInt32(nouns.count)))
        let randdomNoun = nouns[index]
        
        let randomName = "\(randdomAdjective) \(randdomNoun)"
        let randomValue = Int(arc4random_uniform(100))
        let randomSerial = NSUUID().uuidString.components(separatedBy: "-").first!
        
        self.init(name: randomName, serialNumber: randomSerial, valueInDollars: randomValue)
    }
    
}

