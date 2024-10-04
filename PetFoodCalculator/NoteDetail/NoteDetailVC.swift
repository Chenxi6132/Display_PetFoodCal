//
//  NoteDetailVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/24/24.


import UIKit
import ImageSlideshow
import FirebaseFirestore
import FirebaseAuth
import FaveButton
import AVKit
import AVFoundation
import GrowingTextView


class NoteDetailVC: UIViewController {

    var note: DocumentSnapshot
    var comments: [DocumentSnapshot] = []
    let db = Firestore.firestore()
    
    var isLikeFromWaterFallCell = false
    
    var playerLayer: AVPlayerLayer?
    
    //feed top
    @IBOutlet weak var authorAvatarBtn: UIButton!
    @IBOutlet weak var authorNickNameBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var shareOrMoreBtn: UIButton!
    
    //table header view
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    @IBOutlet weak var imageSlideShowHeight: NSLayoutConstraint!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var ChannelBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    //feedBottom
    @IBOutlet weak var likeBtn: FaveButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var favBtn: FaveButton!
    @IBOutlet weak var faveCountLabel: UILabel!
    @IBOutlet weak var CommentCountBtn: UIButton!
    @IBOutlet weak var textViewBarView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBarBottomConstraint: NSLayoutConstraint!
    
    lazy var overlayView: UIView = {
        let overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        overlayView.addGestureRecognizer(tap)
        return overlayView
    }()
    
    var likeCount = 0{
        didSet{
            likeCountLabel.text = likeCount == 0 ? "Like" : likeCount.formattedStr
        }
    }
    var currentLikeCount = 0
    
    var favCount = 0{
        didSet{
            faveCountLabel.text = favCount == 0 ? "Col" : favCount.formattedStr
        }
    }
    var currentFavCount = 0
    
    var commentCount = 0{
        didSet{
            commentCountLabel.text = "\(commentCount)"
            CommentCountBtn.setTitle(commentCount == 0 ? "Cmt" : commentCount.formattedStr, for: .normal)
        }
    }
    
    var followCount = 0{
        didSet{
            followBtn.setTitle(followCount == 0 ? "Follow" : "Following", for: .normal)
        }
    }
    var currentFollowCount = 0
    
    var isLike: Bool {likeBtn.isSelected}
    var likeStatusChanged: ((Bool) -> Void)?
    
    var isFav: Bool {favBtn.isSelected}
    
    var isFollow: Bool {followBtn.isSelected}
    
    var isReply = false
    var commentSection = 0 //user reply to which comment
    
    var isSubReply: String?
    var subReplyToAuthor: String?
    
    var replies : [ExpandableReplies] = []
    
    var isReadMyNote: Bool {
        let author = note.getExactStringVal(kUID)
        if let currentUser = Auth.auth().currentUser?.uid, currentUser == author {
            return true
        } else {
            return false
        }
    }
    
    var delNoteFinished: (() -> ())?
    
    init?(coder: NSCoder, note: DocumentSnapshot) {
        self.note = note
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("必须传一些参数进来以构造本对象,不能单纯的用storyboard!.instantiateViewController构造本对象")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setUI()
        getComments()
        getFav()
        listenForLikeCountUpdates()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableHeaderViewHeight()
    }
    
    
    @IBAction func back(_ sender: Any) { dismiss(animated: true) }
    
    @IBAction func goToAuthorMeVC(_ sender: Any) { shareOrMore() }
    
    @IBAction func follow(_ sender: Any) { follow() }
    
    @IBAction func like(_ sender: Any) { like() }
    
    @IBAction func fave(_ sender: Any) { fave() }
    
    @IBAction func comment(_ sender: Any) {comment()}
    
    @IBAction func postCommnetOrReply(_ sender: Any) { 
        if !textView.isBlank{
            if !isReply{
                print("this is comment")
                postComment()
            }else{
                print("this is reply ")
                postReply()
            }
        hideAndResetTextView()
        }
    }

    
    
}
