//
//  constant.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/17/24.
//

import UIKit


//MARK: - General Resource file
let imagePH = UIImage(named: "imagePH")!
let mainColor = UIColor(named: "AccentColor")!

//MARK: - Stroyboard ID
let kDiscoveryVCID = "DiscoveryVCID"
let kDogCulatorVCID = "DogCulatorVCID"
let kCatCulatorVCID = "CatCulatorVCID"
let kWaterFallVCID = "WaterFallVCID"
let kNoteEditVCID = "NoteEditVCID"
let kMeVCID = "MeVCID"
let kLoginVCID = "LoginVCID"
let kSocialLoginVCID = "SocialLoginVCID"
let kDraftNotesNaviID = "DraftNotesNaviID"
let kNoteDetailVCID = "NoteDetailVCID"


//MARK: - Screen Size
let screenRect = UIScreen.main.bounds


//MARK: - cell
let kWaterFallCellID = "WaterFallCellID"
let kDraftNoteWaterFallCellID = "DraftNoteWaterFallCellID"
let kPhotoCellID = "PhotoCellID"
let kPhotoFooterID = "PhotoFooterID"
let kCommentViewID = "CommentViewID"
let kReplyCellID = "ReplyCellID"
let kCommentSectionFooterViewID = "CommentSectionFooterViewID"

//MARK: - WaterFall Layout
let kWaterFallPadding : CGFloat = 4.0
let kDraftNoteWaterfallCellBottomViewH : CGFloat = 82
let kChannels = ["推荐","旅行","娱乐","才艺","美妆","白富美","美食","萌宠"]




//MARK: - YPImagePicker
let kMaxCameraZoomFactor: CGFloat = 5.0
let kmaxNumberOfPhotos: Int = 9



//MARK: - General
let kMaxNoteTitleCount = 20
let kMaxNoteTextCount = 200
let kNoteCommentPH = "Great comments will be featured first"

//MARK: - CoreData
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let persistentContainer = appDelegate.persistentContainer
let context = persistentContainer.viewContext
let backgroundContext = persistentContainer.newBackgroundContext()

//MARK: - Firebase Collections
let kUserLikeTable = "UserLike"
let kUserFavTable = "UserFave"
let kUserFollowTable = "UserFollow"
let KUserCommentTable = "UserComment"
let kUserReplyTable = "UserReply"

//MARK: - user table
let kUID = "uid"
let kDate = "date"
let kPhoneNumber = "phone_number"
let kEmail = "email"
let kNickName = "nick_name"
let kAvatar = "avatar"
let kLikeCount = "like_count"
let kFaveCount = "fave_count"
let kFollowingCount = "following_count" //去关注
let kFollowerCount = "follower_count" //被关注

//MARK: - Note table
let kNoteID = "note_id"
let kCoverPhoto = "cover_photo"
let kCoverPhotoRatio = "cover_photo_ratio"
let kPhotos = "photos"
let kVideo = "video"
let kTitle = "title"
let kText = "text"
let kIsVideo = "is_video"
let kLikedCount = "liked_count"
let kFavedCount = "faved_count"
let kCommentCount = "comment_count"
let kAuthor = "author"
let kHasEdit = "has_edit"
//let kChannel = "channel"
//let kSubChannel = "subChannel"
//let kPOIName = "poiName"

//MARK: - userLike UserFave UserFollow UserComment
let kUser = "userID"
let kNote = "noteID"
let kFUser = "FollowedUser"
let kComment = "Comment"
let kCommentID = "commentID"
let kReplyComment = "replyComment"
let kReplyToUser = "replyToUser"
let kSubReplyToAuthorNicName = "replyToUserNicName"

//MARK: - Comment Table
let kHasReply = "hasReply"

//MARK: - largeIcon Global Fucntion
func largeIcon(_ iconName: String, with color: UIColor = .label) -> UIImage{
    let config = UIImage.SymbolConfiguration(scale: .large)
    let icon = UIImage(systemName: iconName, withConfiguration: config)!
    
    return icon.withTintColor(color)
}

//MARK: - showTextHUD Global Fucntion
func showGlobalTextHUD(_ title: String){
    // Get the active window scene
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.last else {
        return
    }
    let hud = MBProgressHUD.showAdded(to: window, animated: true)
    hud.mode = .text
    hud.label.text = title
    hud.hide(animated: true, afterDelay: 2)
}

