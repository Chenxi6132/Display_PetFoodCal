//
//  TabBarC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/18/24.
//

import UIKit
import YPImagePicker

class TabBarC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }
    

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        
        if viewController is PostVC{
            //check if login
            if isUserLoggedIn(){
                var config = YPImagePickerConfiguration()
                
                //General configuration setting
                config.isScrollToChangeModesEnabled = false
                config.onlySquareImagesFromCamera = false
                config.albumName = "PetFoodCalculator"
                config.startOnScreen = .library
                config.screens = [.library, .photo, .video]
                config.maxCameraZoomFactor = kMaxCameraZoomFactor  //max zoom factor for camera
                
                config.showsVideoTrimmer = false
            
                //Library configuration setting
                config.library.defaultMultipleSelection = true
                config.library.maxNumberOfItems = kmaxNumberOfPhotos //max number of pictures can selected
                config.library.preSelectItemOnMultipleSelection = true
                
                //Video configuration setting
                config.video.recordingTimeLimit = 120.0
                config.video.libraryTimeLimit = 120.0
                config.video.minimumTimeLimit = 5.0
                config.video.trimmerMaxDuration = 120.0
                config.video.trimmerMinDuration = 5.0
                
                //Gallery configuration setting
                config.gallery.hidesRemoveButton = false
                
                let picker = YPImagePicker(configuration: config)
                
                picker.didFinishPicking { [unowned picker] items, cancelled in
                    if cancelled {
                           //print("Picker was canceled")
                        picker.dismiss(animated: true)
                    }else{
                        var photos: [UIImage] = []
                        var videoURL: URL?
                        for item in items {
                            switch item {
                            case let .photo(photo):
                                photos.append(photo.image)
                            case .video:
                                let url = URL(fileURLWithPath: "recordedVideoRAW.mov", relativeTo: FileManager.default.temporaryDirectory)
                                photos.append(url.thumbnail)
                                videoURL = url
                            }
                        }
                        
                        let vc = self.storyboard!.instantiateViewController(identifier: kNoteEditVCID) as! NoteEditVC
                        vc.photos = photos
                        vc.videoURL = videoURL
                        picker.pushViewController(vc, animated: true)
                    }
                }
                present(picker, animated: true)
            }else{
                let alert = UIAlertController(title: "prmot", message: "Please Login", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let action2 = UIAlertAction(title: "Login", style: .default) { _ in
                    tabBarController.selectedIndex = 2
                }
                alert.addAction(action1)
                alert.addAction(action2)
                
                present(alert, animated: true, completion: nil)
            }

            return false
        }
        
        return true
    }
   
}
