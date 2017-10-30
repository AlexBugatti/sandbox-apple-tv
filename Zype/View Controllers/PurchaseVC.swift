//
//  PurchaseVC.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/19/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class PurchaseVC: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureButtons()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spinForPurchase),
                                               name: NSNotification.Name(rawValue: "kSpinForPurchase"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unspinForPurchase),
                                               name: NSNotification.Name(rawValue: "kUnspinForPurchase"),
                                               object: nil)
        self.unspinForPurchase()
        self.setupUserLogin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // since the duration for a SKProduct is not available
    // we need a custtom mapper function to handle that
    func getDuration(_ productID: String) -> String {
        var duration: String = "";
        
        if productID.range(of: "monthly") != nil {duration = "(monthly)"}
        if productID.range(of: " ") != nil {duration = "(yearly)"}
        
        return duration
    }
    
    fileprivate func setupUserLogin() {
        if ZypeUtilities.isDeviceLinked() {
            setupLoggedInUser()
        }
        else {
            setupLoggedOutUser()
        }
    }
    
    fileprivate func setupLoggedInUser() {
        let defaults = UserDefaults.standard
        let kEmail = defaults.object(forKey: kUserEmail)
        guard let email = kEmail else { return }
        
        let loggedInString = NSMutableAttributedString(string: "Logged in as: \(String(describing: email))", attributes: nil)
        let buttonRange = (loggedInString.string as NSString).range(of: "\(String(describing: email))")
        loggedInString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 38.0), range: buttonRange)
        
        accountLabel.attributedText = loggedInString
        accountLabel.textAlignment = .center
        
        loginButton.isHidden = true
    }
    
    fileprivate func setupLoggedOutUser() {
        accountLabel.attributedText = NSMutableAttributedString(string: "Already have an account?")
        loginButton.isHidden = false
    }
    
    func onPlanSelected(sender: UIButton) {
        
        if !ZypeUtilities.isDeviceLinked() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onPurchased),
                                                   name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                                   object: nil)
            ZypeUtilities.presentRegisterVC(self)
        }
        else {
            if let identifier = sender.accessibilityIdentifier {
                self.purchase(identifier)
            }
        }
        
        print("\n\n HELLO PURCHASE WORLD \n\n")
        print(sender.tag)
    }
    
    func purchase(_ productID: String) {
        InAppPurchaseManager.sharedInstance.purchase(productID)
    }
    
    func configureButtons() {
        
        stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.horizontal
        stackView.distribution = UIStackViewDistribution.fill
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing = Const.kSubscribeButtonHorizontalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = false
        scrollView.addSubview(stackView)
        containerView.addSubview(scrollView)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        
        if let products = InAppPurchaseManager.sharedInstance.products {
            for product in products {
                let subscribeButton = UIButton.init(type: .system)
                subscribeButton.heightAnchor.constraint(equalToConstant: self.containerView.height).isActive = true
                subscribeButton.setTitle(String(format: localized("Subscription.ButtonFormat"), arguments: [product.value.localizedTitle, product.value.localizedPrice(), self.getDuration(product.value.productIdentifier)]), for: .normal)
                subscribeButton.accessibilityIdentifier = product.key
                subscribeButton.addTarget(self, action: #selector(self.onPlanSelected(sender:)), for: .primaryActionTriggered)
                stackView.addArrangedSubview(subscribeButton)
            }
        }
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        ZypeUtilities.presentLoginVC(self)
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func spinForPurchase() {
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        for view in self.view.subviews {
            view.isUserInteractionEnabled = false
        }
    }
    
    func unspinForPurchase() {
        self.activityIndicator.stopAnimating()
        
        for view in self.view.subviews {
            view.isUserInteractionEnabled = true
        }
    }
    
}
