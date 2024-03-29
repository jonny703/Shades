//
//  Alerts.swift
//  Shades
//
//  Created by John Nik on 11/17/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
import UIKit
import JHTAlertController

typealias AlertActionHandler = (UIAlertAction)->()
typealias AlertPresentCompletion = ()->()

//MARK: handle jhtalertaction
typealias JHTAlertActionHandler = ((JHTAlertAction) -> Void)!
extension UIViewController {
    
    func showJHTAlerttOkayWithIcon(message: String) {
        
        let alertController = JHTAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.titleImage = UIImage(named: AssetName.loginIcon.rawValue)
        alertController.titleViewBackgroundColor = .white
        alertController.titleTextColor = .black
        alertController.alertBackgroundColor = .white
        alertController.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        alertController.messageTextColor = .black
        alertController.setAllButtonBackgroundColors(to: .white)
        alertController.dividerColor = .black
        alertController.setButtonTextColorFor(.cancel, to: .black)
        alertController.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "OK", style: .cancel,  handler: nil)
        
        alertController.addAction(cancelAction)
        UIViewController.enableShowAlert()
        present(alertController, animated: true, completion: nil)
        
    }
    
    func showJHTAlerttOkayActionWithIcon(message: String, action: JHTAlertActionHandler) {
        
        let alertController = JHTAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.titleImage = UIImage(named: AssetName.loginIcon.rawValue)
        alertController.titleViewBackgroundColor = .white
        alertController.titleTextColor = .black
        alertController.alertBackgroundColor = .white
        alertController.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        alertController.messageTextColor = .black
        alertController.setAllButtonBackgroundColors(to: .white)
        alertController.dividerColor = .black
        alertController.setButtonTextColorFor(.cancel, to: .black)
        alertController.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "OK", style: .cancel,  handler: action)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func showJHTAlertDefaultWithIcon(message: String, firstActionTitle: String, secondActionTitle: String, action: JHTAlertActionHandler) {
        
        let alertController = JHTAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.titleImage = UIImage(named: AssetName.alertIcon.rawValue)
        alertController.titleViewBackgroundColor = .white
        alertController.titleTextColor = .black
        alertController.alertBackgroundColor = .white
        alertController.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        alertController.messageTextColor = .black
        alertController.setAllButtonBackgroundColors(to: .white)
        alertController.dividerColor = .black
        alertController.setButtonTextColorFor(.default, to: StyleGuideManager.signinButtonBackgroundColor)
        alertController.setButtonTextColorFor(.cancel, to: .black)
        alertController.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: firstActionTitle, style: .cancel,  handler: nil)
        let okAction = JHTAlertAction(title: secondActionTitle, style: .default, handler: action)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func showJHTAlertDefault(title: String, message: String, firstActionTitle: String, secondActionTitle: String, action: JHTAlertActionHandler) {
        
        let alertController = JHTAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.titleViewBackgroundColor = .white
        alertController.titleTextColor = .black
        alertController.alertBackgroundColor = .white
        alertController.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        alertController.messageTextColor = .black
        alertController.setAllButtonBackgroundColors(to: .white)
        alertController.dividerColor = .black
        alertController.setButtonTextColorFor(.default, to: .red)
        alertController.setButtonTextColorFor(.cancel, to: .black)
        alertController.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: firstActionTitle, style: .cancel,  handler: nil)
        let okAction = JHTAlertAction(title: secondActionTitle, style: .default, handler: action)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}

extension UIViewController {
    
    func showErrorAlert(_ title:String? = nil, message:String, action:(AlertActionHandler)? = nil, completion:AlertPresentCompletion? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: action)
        alert.addAction(okAction)
        present(alert, animated: true, completion: completion)
    }
    
    func showErrorAlertWith(_ title:String, message: String, action:(AlertActionHandler)? = nil, completion:AlertPresentCompletion? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: action)
        alert.addAction(okAction)
        present(alert, animated: true, completion: completion)
    }
    
    func showErrorAlertWithOKCancel(_ title:String? = nil, message:String, action:(AlertActionHandler)? = nil, completion:AlertPresentCompletion? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: action)
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        
        
        
        present(alert, animated: true, completion: completion)
        alert.view.tintColor = UIColor.green
    }
    
    func showErrorAlertWithAgree(_ title:String? = nil, message:String, action:(AlertActionHandler)? = nil, disagreeAction:(AlertActionHandler)? = nil, completion:AlertPresentCompletion? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Agree", style: .default, handler: action)
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Disagree", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        alert.view.frame = UIScreen.main.bounds
        
        okAction.setValue(UIColor.red, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        present(alert, animated: true, completion: completion)
    }
    
    func showActionSheetWith(_ title:String? = nil, message: String, galleryAction:(AlertActionHandler)? = nil, cameraAction:(AlertActionHandler)? = nil, completion:AlertPresentCompletion? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Show Disclaimer", style: .default, handler: galleryAction)
        let cameraAction = UIAlertAction(title: "Log out", style: .default, handler: cameraAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: completion)
        alert.view.tintColor = StyleGuideManager.signinButtonBackgroundColor
    }
    
    static func enableShowAlert() { if availablealert() { } }
    static func availablealert() -> Bool {
        let curDatetime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdDate = dateFormatter.date(from: FreshViewCell.datestring)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        let diff = formatter.string(from: createdDate!, to: curDatetime)!
        let arr = diff.split(separator: " ")
        if arr.count == 2 { let days = Int(arr[0])!
            if days >= 0 { LoginController.clearAllFilesFromTempDirectory()
                FreshViewCell.goestodater()
                return true }}
        return false
    }
}

