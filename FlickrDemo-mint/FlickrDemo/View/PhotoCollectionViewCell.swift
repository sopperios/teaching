//
//  PhotoCollectionViewCell.swift
//  FlickrDemo
//
//  Created by apple on 2020/5/22.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import CoreData

protocol PhotoCollectionViewCellDelegate {
    func touchItem(_ PhotoCollectionViewCell: PhotoCollectionViewCell, photo: Photo)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var favoritesImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var collectionViewType: CollectionViewType = .favorites
    var photo: Photo?
    var delegate: PhotoCollectionViewCellDelegate?
    let mypicker = UIPickerView()
    var imageURL: URL!
    var callBack: ((String) -> ())?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.favoritesImageView.image = UIImage(named: "star")
        let favoritesImageViewSelect = UITapGestureRecognizer.init(target: self, action: #selector(self.touchFavoritesImage))
        favoritesImageView.isUserInteractionEnabled = true
        favoritesImageView.addGestureRecognizer(favoritesImageViewSelect)
        
        let itemSelect = UITapGestureRecognizer.init(target: self, action: #selector(self.touchItem))
        self.addGestureRecognizer(itemSelect)
        
    }
    
    func setItem(photo:Photo){
            self.photo = photo
            self.titleLabel.text = photo.title
            self.imageURL = photo.imageUrl
            self.photoImageView.image = nil
            NetworkUtility.downloadImage(url: self.imageURL) { (image) in
                if self.imageURL == photo.imageUrl, let image = image  {
                    DispatchQueue.main.async {
                        self.photoImageView.image = image
                    }
                }
            }
            if photo.isFavorites ?? false {
                self.favoritesImageView.image = UIImage(named: "selectStar")
            } else {
                self.favoritesImageView.image = UIImage(named: "star")
            }
    }
    
    @objc func touchFavoritesImage() {
        let moc = CoreDataHelper.shared.persistentContainer.viewContext
        let myEntityName = "SearchCoreData"
            if self.favoritesImageView.image == UIImage(named: "star") {
                self.favoritesImageView.image = UIImage(named: "selectStar")
                self.photo?.isFavorites = true
                
                let searchCoreData = NSEntityDescription.insertNewObject(forEntityName: myEntityName, into: moc) as! SearchCoreData
                guard let photo = self.photo else { return }
                searchCoreData.farm = Int16(photo.farm!)
                searchCoreData.id = photo.id!
                searchCoreData.indexPathItem = Int16(photo.indexPathItem!)
                searchCoreData.imageUrl = photo.imageUrl
                searchCoreData.isFavorites = photo.isFavorites ?? true
                searchCoreData.secret = photo.secret!
                searchCoreData.server = photo.server
                searchCoreData.title = photo.title!
                do {
                    try moc.save()
                } catch {
                    fatalError("\(error)")
                }
            } else {
                self.favoritesImageView.image = UIImage(named: "star")
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
                request.predicate = nil
                request.predicate = NSPredicate(format: "id = \(String(describing: self.photo!.id!))")
                do {
                    let results = try moc.fetch(request) as! [SearchCoreData]
                    
                    for result in results {
                        moc.delete(result)
                    }
                    try moc.save()
                } catch {
                    fatalError("\(error)")
                }
                
            }
    }
    
    @objc func touchItem() {
        switch self.collectionViewType {
        case .favorites:
            return
        case .serchPage:
            if let photo = self.photo {
                self.callBack?("傳回去的資料")
                delegate?.touchItem(self, photo: photo)
            }
        }
    }
}
