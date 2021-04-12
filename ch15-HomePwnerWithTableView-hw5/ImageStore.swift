//
//  ImageStore.swift
//  ch15-HomePwner
//
//  Created by Jae Moon Lee on 13/01/2020.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import UIKit

class ImageStore: NSObject{
    let cache = NSCache<AnyObject, AnyObject>()
    
    func setImage(image: UIImage, forKey key: String){
        cache.setObject(image, forKey: key as AnyObject)
    }
    
    func imageForKey(key: String) -> UIImage? {
        return cache.object(forKey: key as AnyObject) as? UIImage
    }
    
    func deleteImage(key: String){
        cache.removeObject(forKey: key as AnyObject)
    }
}
