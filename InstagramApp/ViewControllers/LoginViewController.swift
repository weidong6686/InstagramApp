//
//  LoginViewController.swift
//  InstagramApp
//
//  Created by Gwinyai on 20/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var animatedGradientView: AnimatedGradient!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    
    var keyboardNotification: NSNotification?
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha: 0.0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginButton.layer.borderWidth = CGFloat(0.5)
        
        loginButton.layer.borderColor = UIColor.white.cgColor
        
        loginButton.layer.cornerRadius = CGFloat(3.0)
        
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animatedGradientView.startAnimation()
        
        registerForKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        animatedGradientView.stopAnimation()
        
        deregisterFromKeyboardNotifications()
        
    }
    
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
        view.addSubview(touchView)
        
        self.keyboardNotification = notification
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 10.0), right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = UIScreen.main.bounds
        
        aRect.size.height -= keyboardSize!.height
        
        if activeField != nil {
            
            if (!aRect.contains(activeField!.frame.origin)) {
                
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                
            }
            
        }
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        touchView.removeFromSuperview()
        
        let contentInsets : UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    @IBAction func loginButtonDidTouch(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        
        guard let password = passwordTextField.text else { return }
        
        let spinner  = UIViewController.displayLoading(withView: self.view)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            
            guard let strongSelf = self else {return}
            
            DispatchQueue.main.async {
                
                UIViewController.removeLoading(spinner: spinner)
                
            }
            
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    //login func
                    Helper.login()
                    
                }
                
            }
            else if let error = error {
                
                var errorTitle: String = "Login Error"
                
                var errorMessage: String = "There was a problem logging in"
                
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    
                    switch errCode {
                        
                    case .wrongPassword:
                        
                        errorTitle = "Wrong Password"
                        errorMessage = "The password you enter is wrong"
                        
                    case .invalidEmail:
                        
                        errorTitle = "Email Invalid"
                        errorMessage = "Please enter a valid email"
                                               
                    default:
                        break
                    }
                    
                    let alert = Helper.errorAlert(title: errorTitle, message: errorMessage)
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func dontHaveAccountButtonDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "SignupSegue", sender: nil)
        
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeField = nil
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        
    }
    
}
