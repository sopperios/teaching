//
//  ViewController.swift
//  FlickrDemo
//
//  Created by apple on 2020/5/21.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //搜尋的輸入框
    @IBOutlet weak var inputTextField: UITextField!
    //每頁要呈現的數量的輸入框
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        var dateArray: [Date] = []
//        let date = Date()
//        for _ in 0...10 {
//            let formatter = DateFormatter()
//            formatter.locale = Locale.init(identifier: "zh_CN")
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let number = Int.random(in: 24...2000)
//            let lastTime: TimeInterval = TimeInterval(-(number*60*60))
//            let lastDate = date.addingTimeInterval(lastTime)
//
//            print(formatter.string(from: lastDate))
//            dateArray.append(lastDate)
//        }
//        print("排列後")
//        dateArray.sort(by: {$0 < $1 })
//
//        for i in 0..<dateArray.count {
//            let formatter = DateFormatter()
//            formatter.locale = Locale.init(identifier: "zh_CN")
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            print(formatter.string(from: dateArray[i]))
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeButtonColor), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    func setup(){
        
        inputTextField.placeholder = "欲搜尋內容"
        numberTextField.placeholder = "每頁呈現數量"
        searchButton.setTitle("搜尋", for: [])
        searchButton.backgroundColor = UIColor.gray
        searchButton.setTitleColor(UIColor.white, for: [])
        searchButton.isEnabled = false
        self.title = "搜尋輸入頁"
    }
    

    @IBAction func searchHandler(_ sender: UIButton) {

        if let controller = storyboard?.instantiateViewController(withIdentifier: "SecondVC") as? FlickrSearchCollectionViewController {
            controller.setInputValue(inputText: inputTextField.text!, numberText: numberTextField.text!)
            controller.collectionViewType = .serchPage
            navigationController?.pushViewController(controller, animated: true)
            
        }

    }
    
    @objc func changeButtonColor(){
        
        if !self.inputTextField.text!.isEmpty && !self.numberTextField.text!.isEmpty {
            
            searchButton.backgroundColor = UIColor.blue
            searchButton.isEnabled = true
            
        } else {
            
            searchButton.backgroundColor = UIColor.gray
            searchButton.isEnabled = false
        }
    }
    
}

