//
//  extension.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/20/24.
//

import Foundation
import UIKit
import DateToolsSwift
import AVFoundation
import FirebaseFirestore
import FaveButton

extension Int{
    var formattedStr: String{
        let num = Double(self)
        let tenThousand = num / 10_000
        let hundredMillion = num / 100_000_000
        
        if tenThousand < 1{
            return "\(self)"
        }else if hundredMillion >= 1{
            return "\(round(hundredMillion * 10) / 10)M"
        }else{
            return "\(round(tenThousand * 10) / 10)K"
        }
    }
}

func isUserLoggedIn() -> Bool {
    return UserDefaults.standard.bool(forKey: "log_status")
}

extension Date{
    var formattedDate: String{
        let currentYear = Date().year
        
        if year == currentYear{
            if isToday{
                if minutesAgo <= 10{
                    return timeAgoSinceNow
                }else{
                    return "Today \(format(with: "HH:mm"))"
                }
            }else if isYesterday{
                return "Yesterday \(format(with: "HH:mm"))"
            }else{
                return format(with: "MM-dd")
            }
        }else if year < currentYear{ //lastYear or before
            return format(with: "yyyy-MM-dd")
        }else{
            return "Future"
        }
    }
}

extension String{
    var isBlank : Bool{
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func randomString(_ length: Int) -> String{
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func spliceAtrrStr(_ dateStr: String) -> NSMutableAttributedString{
        let attrText = toAttrStr()
        let attrDate = " \(dateStr)".toAttrStr(12, .secondaryLabel)
        attrText.append(attrDate)
        return attrText
    }
    
    func toAttrStr(_ fontSize: CGFloat = 14, _ color: UIColor = .label) -> NSMutableAttributedString {
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: color
        ]
        return NSMutableAttributedString(string: self, attributes: attr)
    }
}

extension Optional where Wrapped == String{
    var unwrappedText: String { self ?? "" }
}


//coverphoto for video
extension URL{
    var thumbnail: UIImage{
        let asset = AVAsset(url: self)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return imagePH
        }
    }
}

extension UIImage{
    
    convenience init?(_ data: Data?) {
        if let unwrappedData = data{
            self.init(data: unwrappedData)
        }else{
            return nil
        }
    }
    
    enum JPEGQUality: CGFloat{
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality:JPEGQUality) -> Data?{
        jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIView{
    @IBInspectable
    var radius :CGFloat{
        get{
            layer.cornerRadius
        }
        set{
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
    }
}

extension UITextField{
    var unwrappedText: String{ text ?? ""}
    
    var exactText: String { unwrappedText.isBlank ? "" : unwrappedText }
    
    var isBlank: Bool { unwrappedText.isBlank }
}


extension UITextView{
    var unwrappedText: String{ text ?? ""}
    
    var exactText: String{ unwrappedText.isBlank ? "" : unwrappedText }
    
    var isBlank: Bool { unwrappedText.isBlank }
}

//KVC to change titleColor under UIAlertAction
extension UIAlertAction{
    func setTitleColor(_ color: UIColor){
        setValue(color, forKey: "titleTextColor")
    }
}

extension UIViewController{
//MARK: - MBProgressHUD
    // MARK: loading indicator--manual hiden
    func showLoadHUD(_ title: String? = nil){
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = title
    }
    func hideLoadHUD(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    //MARK: indicator: hide automatically
    func showTextHUD(_ title: String, _ inCurrentView: Bool = true, _ subTitle: String? = nil){
        var viewToShow: UIView
        
        if inCurrentView {
            viewToShow = view
        } else {
            // Get the key window from the active scene
            if let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) {
                viewToShow = keyWindow
            } else {
                // Fallback to the current view if no key window is found
                viewToShow = view
            }
        }
            
            let hud = MBProgressHUD.showAdded(to: viewToShow, animated: true)
            hud.mode = .text
            hud.label.text = title
            hud.detailsLabel.text = subTitle
            hud.hide(animated: true, afterDelay: 2)
    }
    
    func showLoginHUD(){showTextHUD("Please LogIn")}
    
    // MARK: - tap blank space to hide keyboard
    func hideKeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //保证tap手势不会影响到其他touch类控件的手势
        //若不设，则本页面有tableview时，点击cell不会触发didSelectRowAtIndex（除非长按）
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true) //让view中的所有textfield失去焦点--即关闭小键盘
    }
    
    func add(child vc: UIViewController){
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    //MARK: remove specific vc
    func remove(child vc: UIViewController){
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
    
    //MARK: remove all children vc
    func removeChildren(){
        if !children.isEmpty{
            for vc in children{
                remove(child: vc)
            }
        }
    }
}


extension Bundle{
    static func loadView<T>(fromNib name: String, with type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }else{
            fatalError("load \(type) view failed")
        }
    }
}


extension FileManager{
    func save(_ data: Data?, to dirName: String, as fileName: String) -> URL?{
        guard let data = data else{ return nil }
        
        let dirURL = temporaryDirectory.appendingPathComponent(dirName, isDirectory: true)
        
        if !fileExists(atPath: dirURL.path){ //if file not exit, create dir
            guard let _ = try? createDirectory(at: dirURL, withIntermediateDirectories: true) else{
                print("create dir folder failed")
                return nil
            }
        }
        
        //save data to dir
        let fileURL = dirURL.appendingPathComponent(fileName)
        if !fileExists(atPath: fileURL.path){
            guard let _ = try? data.write(to: fileURL) else{
                print("save/create file failed")
                return nil
            }
        }
        return fileURL
    }
}


extension Notification.Name {
    static let loginStatusChanged = Notification.Name("loginStatusChanged")
}

extension DocumentSnapshot {
    func getExactStringVal(_ key: String) -> String {
        return self[key] as? String ?? ""
    }
    
    func getExactIntVal(_ key: String) -> Int {
        return self[key] as? Int ?? 0
    }
    
    func getExactDoubleVal(_ key: String) -> Double {
        return self[key] as? Double ?? 1.0
    }
    
    func getExactBoolDefaultF(_ key: String) -> Bool{
        return self[key] as? Bool ?? false
    }
    
    func getExactBoolDefaultT(_ key: String) -> Bool{
        return self[key] as? Bool ?? true
    }
    
    enum imageType{
        case avatar
        case coverPhoto
    }
    
    func getImageURL(from data: [String: Any], col: String, _ type: imageType) -> URL? {
        if let urlString = data[col] as? String {
            return URL(string: urlString)
        } else {
            switch type {
            case .avatar:
                return Bundle.main.url(forResource: "avatar_PH", withExtension: "jpeg")
            case .coverPhoto:
                return Bundle.main.url(forResource: "coverPhoto_PH", withExtension: "jpeg")
            }
        }
    }
}


//MARK: - faveBtn
extension FaveButton{
    func setToNormal(){
        selectedColor = normalColor
        dotFirstColor = normalColor
        dotSecondColor = normalColor
        circleFromColor = normalColor
        circleToColor = normalColor
    }
}
