//
//  ImageStoreWithFirebase.swift
//  ch15-HomePwnerWithTableView-hw5
//
//  Created by admin01 on 2020/06/29.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import Foundation
import FirebaseStorage

class ImageStoreWithFirebase: ImageStore {
    
    var reference: StorageReference
    
    override init() {
        reference = Storage.storage().reference().child("imageStore")
        super.init()
    }
    
    // 이미지를 스토리지에 저장
    override func setImage(image: UIImage, forKey key: String) {
        super.setImage(image: image, forKey: key)  // save at cache
        
        let data = image.jpegData(compressionQuality: 1.0)!  // save at firebaseStorage
        reference.child(key).putData(data)
    }
    
    // 이미지를 스토리지로부터 가져와서 캐시에 저장
    override func imageForKey(key: String) -> UIImage? {
        if let image = super.imageForKey(key: key) {
            return image
        }
        
        reference.child(key).getData(maxSize: 10*1024*1024, completion: {
            (data, error) in
            if error == nil {
                if let image = UIImage(data: data!) {
                    self.setImage(image: image, forKey: key)  // save at cache
                }
            }
        })
        
        return nil
    }
    
    override func deleteImage(key: String) {
        super.deleteImage(key: key)  // remove at cache
        
        reference.child(key).delete(completion: nil)
    }
    
}
