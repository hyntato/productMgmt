//
//  DetailViewController.swift
//  ch13-HomePwner
//
//  Created by Jae Moon Lee on 13/01/2020.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var item: Item!
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateCreatedLabel: UILabel!
    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var serialNumbewrTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueTextField.delegate = self
        serialNumbewrTextField.delegate = self
        nameTextField.delegate = self

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        nameTextField.text = item.name
        valueTextField.text = String(item.valueInDollars)
        serialNumbewrTextField.text = item.serialNumber

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        dateCreatedLabel.text = formatter.string(from: item.dateCreated as Date)
        
        if let image = imageStore.imageForKey(key: item.itemKey) {
            imageView.image = image
        }
        
        navigationItem.title = item.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        item.name = nameTextField.text ?? ""
        item.serialNumber = serialNumbewrTextField.text
        item.valueInDollars = 0
        if let valueText = valueTextField.text {
            item.valueInDollars = Int(valueText) ?? 0
        }
        
        if let image = imageView.image{
            imageStore.setImage(image: image, forKey: item.itemKey)
        }
        
        itemStore.modifyItem(item: item, key: item.itemKey)  // itemStoreWithFirebase's modifyItem() call
        
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        valueTextField.resignFirstResponder()
        serialNumbewrTextField.resignFirstResponder()
    }
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        let imagePickerController = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        }else{
            imagePickerController.sourceType = .photoLibrary
        }
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}
