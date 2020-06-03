//
//  CreatePostViewController.swift
//  InstagramApp
//
//  Created by Gwinyai on 24/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

import FirebaseDatabase

import FirebaseAuth

import  FirebaseStorage


class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postCaptionTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var postImage: UIImage!
    
    var activeTextView: UITextView?
    
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
    
    lazy var progressIndicator: UIProgressView = {
        
        let _progressIndicator = UIProgressView()
        
        _progressIndicator.trackTintColor = UIColor.lightGray
        
        _progressIndicator.progressTintColor = UIColor.black
        
        _progressIndicator.progress = Float(0)
        
        _progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return _progressIndicator
        
    }()
    
    lazy var cancelButton: UIButton = {
        
        let  _cancelButton = UIButton()
        
        _cancelButton.setTitle("Cancel Upload", for: .normal)
        
        _cancelButton.setTitleColor(UIColor.black, for: .normal)
        
        _cancelButton.addTarget(self, action: #selector(cancelUpload), for: .touchUpInside)
        
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        return _cancelButton
        
    }()
    
    var uploadTask: StorageUploadTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        postImageView.image = postImage
        
        postCaptionTextView.layer.borderWidth = CGFloat(0.5)
        
        postCaptionTextView.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).cgColor
        
        postCaptionTextView.layer.cornerRadius = CGFloat(3.0)
        
        postCaptionTextView.delegate = self
        
//        view.addSubview(progressIndicator)
//
//        view.addSubview(cancelButton)
//        
//        let constrains: [NSLayoutConstraint] = [
//
//            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
//
//            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
//
//            progressIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//
//            progressIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),//向右20
//
//            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
//
//            cancelButton.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 5),
//
//        ]
//
//        NSLayoutConstraint.activate(constrains)
//
//        progressIndicator.isHidden = true
//
//        cancelButton.isHidden = true
        
    }
    
    func uploadImage(data: Data, caption: String) {
        
        if let user = Auth.auth().currentUser {
            
            progressIndicator.isHidden = false
            
            cancelButton.isHidden = false
            
            progressIndicator.progress = Float(0)//初始进度0
            
            let imageId: String = UUID().uuidString.lowercased().replacingOccurrences(of: "_", with: "_")
            
            let imageName: String = "\(imageId).jpg"
            
            let pathTopPic = "image/\(user.uid)/\(imageName)"
            
            let storageRef = Storage.storage().reference(withPath: pathTopPic)
            
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/jpg"
            
            uploadTask = storageRef.putData(data, metadata: metaData, completion: { [weak self] (metaData, error) in
                
                guard let strongSelf = self else {return}
                
                DispatchQueue.main.async {
                    
                    strongSelf.progressIndicator.isHidden = true
                    
                    strongSelf.cancelButton.isHidden = true
                    
                }
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                    let alert = Helper.errorAlert(title: "Upload Error", message: "There was a problem uploading the image")
                    
                    DispatchQueue.main.async {
                        
                        strongSelf.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                else {
                    
                    storageRef.downloadURL { (url, error) in
                        
                        if let url = url, error == nil {
                            //post特有的,区别于profileImage上传
                            PostModel.newPost(userId: user.uid, caption: caption, imageDownloadURL: url.absoluteString)
                            
                        }
                        else {
                            
                            let alert = Helper.errorAlert(title: "Upload Error", message: "There was a problem uploading the image")
                            
                            DispatchQueue.main.async {
                                
                                strongSelf.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    }
                }
                
            })
            
            uploadTask!.observe(.progress) { [weak self](snapshot) in
                
                guard let strongSelf = self else {return}
                
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                
                DispatchQueue.main.async {
                    
                    strongSelf.progressIndicator.setProgress(Float(percentComplete), animated: true)
                    
                }
                
            }
            
        }
        
    }
    
    @objc func cancelUpload(){
        
        progressIndicator.isHidden = true
        
        cancelButton.isHidden = true
        
        uploadTask?.cancel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterFromKeyboardNotification()
        
    }
    
    func registerForKeyboardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterFromKeyboardNotification() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
        view.addSubview(touchView)
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 10.0), right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = UIScreen.main.bounds
        
        aRect.size.height -= keyboardSize!.height
        
        if activeTextView != nil {
            
            if (aRect.contains(activeTextView!.frame.origin)) {
                
                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
                
            }
            
        }
        
    }
    
    @objc func keyboardWasHidden(notification: NSNotification) {
        
        touchView.removeFromSuperview()
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        
        self.scrollView.contentInset = contentInsets
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    

    @IBAction func postButtonDidTouch(_ sender: Any) {
        
        guard let caption = postCaptionTextView.text,
                !caption.isEmpty else {return}
        
        if let resizedImage = postImage.resized(toWidth: 1080) {
            
            if let imageData = resizedImage.jpegData(compressionQuality: 0.75) {
                
                uploadImage(data: imageData, caption: caption)
                
            }
            
        }
        
    }
    

}

extension CreatePostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        activeTextView = textView
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        activeTextView = nil
        
    }
    
}
