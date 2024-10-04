//
//  NoteEditVC-CollectionView.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/26/24.
//

import Foundation
import YPImagePicker
import SKPhotoBrowser
import AVKit


extension NoteEditVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoCount
    }
    
    //request a cell for a specific item at the given indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoCellID, for: indexPath) as! PhotoCell
        
        cell.imageView.image = photos[indexPath.item]
        return cell
    }
    
    //footer | header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionFooter:
            let photoFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kPhotoFooterID, for: indexPath) as! PhotoFooter
            photoFooter.addPhotoBtn.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            
            return photoFooter
        default:
            fatalError("collection view footer has error")
        }
    }
    
    
}

//MARK: - UICollectionViewDelegate
extension NoteEditVC: UICollectionViewDelegate{
    //点击缩略图
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isVideo{
            let playerVC = AVPlayerViewController()
            playerVC.player = AVPlayer(url: videoURL!)
            present(playerVC, animated: true){
                playerVC.player?.play()
            }
        }else{
            // 1. create SKPhoto Array from UIImage
            var images: [SKPhoto] = []
            
            for photo in photos{
                images.append(SKPhoto.photoWithImage(photo))
            }
            
            // 2. create PhotoBrowser Instance, and present from your viewController.
            let browser = SKPhotoBrowser(photos: images, initialPageIndex: indexPath.item)
            browser.delegate = self
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayDeleteButton = true
            present(browser, animated: true, completion: {})
        }
    }
}


//MARK: - SKPhotoBrowserDelegate (delete photo)
extension NoteEditVC: SKPhotoBrowserDelegate{
    func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
        photos.remove(at: index)
        photoCollectionView.reloadData()
        reload()
    }
}



//MARK: - listener: check how many photos can add
extension NoteEditVC{
    @objc private func addPhoto(){
        if photoCount < kmaxNumberOfPhotos{
            var config = YPImagePickerConfiguration()
            
            //General configuration setting
            config.albumName = "PetFoodCalculator"
            config.screens = [.library]
        
            //Library configuration setting
            config.library.defaultMultipleSelection = true
            config.library.maxNumberOfItems = kmaxNumberOfPhotos - photoCount //max number of pictures can selected
            config.library.preSelectItemOnMultipleSelection = true
            
            
            //Gallery configuration setting
            config.gallery.hidesRemoveButton = false
            
            let picker = YPImagePicker(configuration: config)
            
            picker.didFinishPicking { [unowned picker] items, _ in
                for item in items {
                    if case let .photo(photo) = item{ //get photo from user
                        self.photos.append(photo.image) //add photo to global variable in photos
                    }
                }
                self.photoCollectionView.reloadData()
                
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }else{
            showTextHUD("The Max Photo can selected is \(kmaxNumberOfPhotos)")
        }
    }
}
