//
//  ViewController.swift
//  MemeMev1.0
//
//  Created by Marcos V. S. Matsuda on 14/11/18.
//  Copyright © 2018 Marcos V. S. Matsuda. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var toolBarTop: UIToolbar!
    @IBOutlet weak var toolBarBottom: UIToolbar!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
   
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBotton: UITextField!
    
    var textFieldTag: Int = 0
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!,
        .foregroundColor: UIColor.white,
        .strokeColor: UIColor.black,
        .strokeWidth: -3.0
    ]
    var memesArray = [Meme]()
    let imagePicker = UIImagePickerController()    
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        configure(textField: textFieldTop, withText: "TOP")
        configure(textField: textFieldBotton, withText: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        let activityItem: [AnyObject] = [memedImage as AnyObject]
        
        let activityViewController = UIActivityViewController(activityItems: activityItem , applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed {
                
                let meme = Meme(
                    topTextField: self.textFieldTop.text!,
                    bottomTextField: self.textFieldBotton.text!,
                    originalImage: self.imagePickerView,
                    memedImage: memedImage)
                
                self.memesArray.append(meme)
            }
            
        }
        
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
    
    func configure(textField: UITextField, withText text: String) {
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.delegate = self
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
        
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageForCamera(_ sender: Any) {
        
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
        
        self.hideTopAndBottomBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.hideTopAndBottomBars(false)
        
        return memedImage
    }
    
    // MARK: toolbar
    
    func hideTopAndBottomBars(_ hide: Bool) {
        self.toolBarTop.isHidden = hide
        self.toolBarBottom.isHidden = hide
    }
}
