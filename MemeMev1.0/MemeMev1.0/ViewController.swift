//
//  ViewController.swift
//  MemeMev1.0
//
//  Created by Marcos V. S. Matsuda on 14/11/18.
//  Copyright © 2018 Marcos V. S. Matsuda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var toolBarTop: UIToolbar!
    @IBOutlet weak var toolBarBottom: UIToolbar!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
   
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBotton: UITextField!
    
    var textFieldTag: Int = 0
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldTop.text = "TOP"
        textFieldBotton.text = "BOTTOM"
        textFieldTop.delegate = self
        textFieldBotton.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    // MARK: Meme
    
    @IBAction func share(_ sender: Any) {
        save()
    }
    
    func save() {
        
        let memedImage: UIImage = generateMemedImage()
        
        // Create the meme
//        let meme = Meme(topTextField: textFieldTop.text!, bottomTextField: textFieldBotton.text!, originalImage: imagePickerView, memedImage: memedImage)
        
        let activityItem: [AnyObject] = [memedImage as AnyObject]
        
        let activityViewController = UIActivityViewController(activityItems: activityItem , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // Especifica se a Controller View prefere que a status bar seja ocultada ou mostrada.
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    // MARK: TextField
    
    // textField deve começar a edição
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldTag = textField.tag
        return true
    }
    
    /// textField começou a edição
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 { textFieldTop.text = "" }
        if textField.tag == 1 { textFieldBotton.text = "" }
    }
    
    // textField deve retornar
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    // MARK: KeyBoard
    
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
    
    // MARK: Image
    
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
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        self.toolBarTop.isHidden = true
        self.toolBarBottom.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        self.toolBarTop.isHidden = false
        self.toolBarBottom.isHidden = false
        
        return memedImage
    }
}
