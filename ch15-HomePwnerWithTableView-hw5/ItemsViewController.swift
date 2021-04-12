//
//  ItemsViewController.swift
//  ch09-HomePwner
//
//  Created by Jae Moon Lee on 13/01/2020.
//  Copyright © 2020 Jae Moon Lee. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    var queryStr: String!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // 검색 기능 활성화 상태에서 삽입,삭제,수정 기능 수행하기 위한 변수
    var isSearchItemClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Firestore로부터 알림을 받은 ItemStoreWithFireStore에서 ItemsViewController에게도 알림을 줌
        (itemStore as! ItemStoreWithFireStore).setListener {
            (notifyAction, index) in
            
            let indexPath = IndexPath(row: index, section: 0)
            
            if notifyAction == .removed {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if notifyAction == .modified {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            // 검색 수행 후 테이블뷰 다시 로드
            if notifyAction == .searched {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        navigationItem.title = "Home page"
    }
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        
        if isSearchItemClicked {
            let newItem = Item(random: true)
            itemStore.addItem(item: newItem)  // itemStoreWithFireStore의 addItem() 함수 호출
        }
        else {
            print("search not enabled")
        }
        
    }
    
    @IBAction func toggleEditingMode(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            print("Editing")
            sender.title = "Edit"
            tableView.setEditing(false, animated: true)
        }else{
            print("Done")
            sender.title = "Done"
            tableView.setEditing(true, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItem" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = itemStore.allItems[row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
                detailViewController.itemStore = itemStore
            }
        }
    }
    
    // 검색 버튼 클릭 시
    @IBAction func onSearchButtonClicked(_ sender: UIButton) {
        isSearchItemClicked = true
        
        if let text = searchTextField.text {
            // 데이터 초기화
            itemStore.allItems.removeAll()
            tableView.reloadData()
            
            // 텍스트 필드의 스트링으로 시작하는 아이템들을 찾아 알려주는 notifyItemSearched() 시작 시키기
            queryStr = text
            (itemStore as! ItemStoreWithFireStore).notifyItemSearched(queryStr: text)
        }
    }
    
}

extension ItemsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        let item = itemStore.allItems[indexPath.row]

        cell.textLabel!.text = item.name
        cell.detailTextLabel?.text = String(item.valueInDollars)
        cell.imageView!.image = imageStore.imageForKey(key: item.itemKey)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "삭제", message: "정말로 삭제하나요?", preferredStyle: .alert)
            let yesAlertAction =  UIAlertAction(title: "Yes", style: .default){
                (action) in

                let item = self.itemStore.allItems[indexPath.row]
                self.imageStore.deleteImage(key: item.itemKey)  // imageStoreWithFirebase's deleteImage() call
                self.itemStore.removeItem(key: item.itemKey)   // itemStoreWithFirebase's removeItem() call
                // self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            let noAlertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(yesAlertAction)
            alertController.addAction(noAlertAction)

            present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
        tableView.reloadData()
    }
}
