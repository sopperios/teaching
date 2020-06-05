//
//  FlickrSearchCollectionViewController.swift
//  FlickrDemo
//
//  Created by apple on 2020/5/22.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import CoreData

enum CollectionViewType{
    case favorites
    case serchPage
}

class FlickrSearchCollectionViewController: UICollectionViewController, PhotoCollectionViewCellDelegate {
    
    private let reuseIdentifier = "Cell"
    var photos:[Photo] = []
    var favoritesPhotos: [Photo] = []
    var inputText: String?
    var numberText: String?
    let apiKey = "7f2e7c8fd464ffcf5afa9afcc5239f40"
    var page = 1
    var currentInsInBottom = false
    var isReloadData = true
    var collectionViewType: CollectionViewType = .favorites
    var prefect = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let width = (view.bounds.width - 10) / 2
        layout?.itemSize = CGSize(width: width, height: width + 80)
        
        self.title = "我的最愛"
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.photos = []
        self.favoritesPhotos = []
        
        self.collectionView.reloadData()
        let moc = CoreDataHelper.shared.persistentContainer.viewContext
        let myEntityName = "SearchCoreData"
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
        do {
            let results =
                try moc.fetch(request) as! [SearchCoreData]
            
            for i in 0..<results.count {
                let photo = Photo.init(farm: Int(results[i].farm), secret: results[i].secret, id: results[i].id, server: results[i].server, isFavorites: results[i].isFavorites, indexPathItem: Int(results[i].indexPathItem), title: results[i].title, favoritesImageUrl: "")
                self.favoritesPhotos.append(photo)
            }
        } catch {
            fatalError("\(error)")
        }
        switch self.collectionViewType {
        case .favorites:
            self.title = "我的最愛"
            
        case .serchPage:
            self.title = "搜尋結果 \(inputText!)"
            fetchData()
        }
    }
    
    func parse(data: Data) -> Bool? {
        return String(data: data, encoding: .utf8).flatMap(Bool.init)
    }
    
    func fetchData() {
        var encodedString: String?
        isReloadData = false
        
        //判斷輸入的字串是否為漢字
        if isIncludeChineseIn(string: inputText!) {
            encodedString = inputText!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        } else {
            encodedString = inputText!
        }
        
        //b1f2069dbe375757c1c5da8a7a76de47
        if let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\( encodedString!)&per_page=\(numberText!)&page=\(page)&format=json&nojsoncallback=1") {
            print(url)
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        var searchData = try JSONDecoder().decode(SearchData.self, from: data)
                        self.favoritesPhotos.forEach { (photo) in
                            for i in 0..<searchData.photos.photo.count {
                                if photo.id == searchData.photos.photo[i].id{
                                    searchData.photos.photo[i].isFavorites = true
                                }
                            }
                        }
                        self.photos.append(contentsOf: searchData.photos.photo)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.isReloadData = true
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }
            
            task.resume()
        }
    }
    
    /// 判斷是否為漢字
    ///
    /// - Parameter string: 判斷傳入的字串
    /// - Returns:為漢字的話回傳true
    func isIncludeChineseIn(string: String) -> Bool {
        //string.characters.enumerated()
        for (_, value) in string.enumerated() {
            
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        
        return false
    }
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch self.collectionViewType {
        case .favorites:
            return
        case .serchPage:
            if scrollView.contentSize.height != 0 {
                let height = scrollView.frame.size.height
                let contentOffsetY = scrollView.contentOffset.y
                let bottomOffset = scrollView.contentSize.height - contentOffsetY
                if bottomOffset <= height {
                    // 在最底部
                    if self.isReloadData {
                        self.currentInsInBottom = true
                        self.page += 1
                        fetchData()
                    }
                } else {
                    self.currentInsInBottom = false
                }
            }
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.collectionViewType {
        case .favorites:
            return favoritesPhotos.count
        case .serchPage:
            return photos.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        switch self.collectionViewType {
        case .favorites:
            // Configure the cell
            var photo = self.favoritesPhotos[indexPath.item]
            photo.indexPathItem = indexPath.item
            cell.collectionViewType = .favorites
            cell.setItem(photo: photo)
            cell.delegate = self
            return cell
        case .serchPage:
            // Configure the cell
            var photo = photos[indexPath.item]
            photo.indexPathItem = indexPath.item
            cell.collectionViewType = .serchPage
            cell.setItem(photo: photo)
            cell.delegate = self
            cell.callBack = { text in
                print(text)
            }
            return cell
        }
        
    }
    
    func touchItem(_ PhotoCollectionViewCell: PhotoCollectionViewCell, photo: Photo) {
        if let indexPathItem = photo.indexPathItem {
            self.photos[indexPathItem] = photo
        }
    }
    
    func setInputValue(inputText:String, numberText: String) {
        self.inputText = inputText
        self.numberText = numberText
    }
    
    
}


