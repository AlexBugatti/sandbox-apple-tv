//
//  SettingsVC.swift
//  AndreySandbox
//
//  Created by Александр on 01.11.2017.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class SettingsVC: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoutTitle: UILabel!
    @IBOutlet weak var logoutFooter: UILabel!
    @IBOutlet var subsciptionTitle: UILabel!
    @IBOutlet var expireDateTitle: UILabel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        //self.configureView()
        self.setupText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSubsciptionStatus()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.checkSubsciptionStatus),
                                               name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupText() {
        let pageHeaderText = UserDefaults.standard.object(forKey: kLogoutPageHeader)
        if (pageHeaderText != nil) {
            self.logoutTitle.text = pageHeaderText as? String
        }
        let pageFooterText = UserDefaults.standard.object(forKey: kLogoutPageFooter)
        if (pageFooterText != nil) {
            self.logoutFooter.text = pageFooterText as? String
        }
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
        ZypeAppleTVBase.sharedInstance.logOut()
        
        UserDefaults.standard.removeObject(forKey: kUserEmail)
        UserDefaults.standard.removeObject(forKey: kUserPassword)
        
        let defaults = UserDefaults.standard
        
        if let favorites = defaults.object(forKey: "favoritesViaAPI") as? Bool {
            if favorites {
                let favorites = [String]()
                defaults.set(favorites, forKey: kFavoritesKey)
                defaults.synchronize()
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }

    @IBAction func restorePurchaseClicked(_ sender: Any) {
        InAppPurchaseManager.sharedInstance.restorePurchases()
    }
    
    func checkSubsciptionStatus() {
        
        if Const.kNativeToUniversal {
            if let subscriptionCount = ZypeAppleTVBase.sharedInstance.consumer?.subscriptionCount {
                if subscriptionCount > 0 {
                    self.expireDateTitle.text = "Subscribed"
                    return
                } else {
                    self.expireDateTitle.text = "Not subscriptions"
                }
            }
        }
        
        if Const.kNativeSubscriptionEnabled {
            InAppPurchaseManager.sharedInstance.checkSubscription { (isExpired, expirationDate, error) in
                if expirationDate != nil {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM dd, YYYY"
                    self.expireDateTitle.text = "Expires on \(dateFormatter.string(from: expirationDate!))"
                } else {
                    self.expireDateTitle.text = "Not subscriptions"
                }
            }
        }
        
    }
    
}
