//
//  NoteDetail-Config.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/26/24.
//

import Foundation
import ImageSlideshow
import GrowingTextView
import FirebaseAuth

extension NoteDetailVC{
    func config(){
        imageSlideShow.zoomEnabled = true
        imageSlideShow.circular = false
        imageSlideShow.contentScaleMode = .scaleAspectFill
        imageSlideShow.activityIndicator = DefaultActivityIndicator() //loading indicator
        let pageIndicator = UIPageControl()
        pageIndicator.pageIndicatorTintColor = UIColor.systemGray
        pageIndicator.currentPageIndicatorTintColor = UIColor.accent
        imageSlideShow.pageIndicator = pageIndicator
        
        if Auth.auth().currentUser == nil {
            likeBtn.setToNormal()
            favBtn.setToNormal()
        }
        
        //textView - Grow text, default top&bottom is 8
        textView.textContainerInset = UIEdgeInsets(top: 11.5, left: 16, bottom: 11.5, right: 16)
        textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //register table view header and footer for commment
        tableView.register(UINib(nibName: "CommentView", bundle: nil), forHeaderFooterViewReuseIdentifier: kCommentViewID)
        tableView.register(CommentSectionFooterView.self, forHeaderFooterViewReuseIdentifier: kCommentSectionFooterViewID)
    }
    
    func adjustTableHeaderViewHeight(){
        let height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeaderView.frame
        
        if frame.height != height{
            frame.size.height = height
            tableHeaderView.frame = frame
        }
    }
}

extension NoteDetailVC: GrowingTextViewDelegate{
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
       UIView.animate(withDuration: 0.2) {
           self.view.layoutIfNeeded()
       }
    }
}

extension NoteDetailVC{
    @objc private func keyboardWillChangeFrame(_ notification: Notification){
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            let keyboradH = screenRect.height - endFrame.origin.y
            
            if keyboradH > 0 {
                view.insertSubview(overlayView, belowSubview: textViewBarView)
            }else{
                overlayView.removeFromSuperview()
                textViewBarView.isHidden = true
            }
            
            textViewBarBottomConstraint.constant = keyboradH
            view.layoutIfNeeded()
        }
    }
}
