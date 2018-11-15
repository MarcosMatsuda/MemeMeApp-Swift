//
//  ViewController.swift
//  MemeMev1.0
//
//  Created by Marcos V. S. Matsuda on 14/11/18.
//  Copyright © 2018 Marcos V. S. Matsuda. All rights reserved.
//

import UIKit

// MARK: struct Meme
struct Meme {
    var topTextField: String
    var bottomTextField: String
    var originalImage: UIImageView
    var memedImage: UIImageView
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
   
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBotton: UITextField!
    
    var textFieldTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldTop.text = "TOP"
        textFieldBotton.text = "BOTTOM"
        textFieldTop.delegate = self
        textFieldBotton.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        let center = NotificationCenter.default
        center.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func save() {
        // Create the meme
        _ = Meme(topTextField: textFieldTop.text!, bottomTextField: textFieldBotton.text!, originalImage: imagePickerView!, memedImage: imagePickerView)
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        
        return memedImage
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldTag = textField.tag
        return true
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if textFieldTag == 1 && self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let keyboardFrame: NSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        return keyboardHeight
    }
    
    @IBAction func pickAnImageForAlbum(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageForCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 { textFieldTop.text = "" }
        if textField.tag == 1 { textFieldBotton.text = "" }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}
