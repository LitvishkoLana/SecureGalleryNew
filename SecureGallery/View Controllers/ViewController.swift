//
//  ViewController.swift
//  SecureGallery
//
//  Created by Светлана on 3.11.22.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var pinField: UITextField!
    @IBOutlet weak var showPinButton: UIButton!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let passwordTranslit = NSLocalizedString("localizationPassword", comment: "translation of pinFild password")
        
        pinField.placeholder = passwordTranslit
        pinField.delegate = self
        unlockButton.isEnabled = false
        showPinButton.isEnabled = false
        
        showPinButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        showPinButton.setImage(UIImage(systemName: "eye"), for: .selected)
        registerKeyboardNotifications()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // MARK: - objc methods
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
    
        bottomConstraint.constant =  50 + keyboardSize.height
        view.layoutIfNeeded()
    }

    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        bottomConstraint.constant = 50
        view.layoutIfNeeded()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - IBActions
    @IBAction func unlock(_ sender: Any) {
        view.endEditing(true)
        guard pinField.text == "1111" else {
            pinField.text = ""
            textFieldDidChangeSelection(pinField)
            return
        }
        
        let gallery = GalleryViewController()
        let navigation = UINavigationController(rootViewController: gallery)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: false)
    }
    @IBAction func showPin(_ sender: Any) {
        pinField.isSecureTextEntry.toggle()
        showPinButton.isSelected = !pinField.isSecureTextEntry
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        unlock(self)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        unlockButton.isEnabled = textField.text?.count ?? 0 == 4
        showPinButton.isEnabled = textField.text?.count ?? 0 > 0
     
        if textField.text?.count ?? 0 > 4 {
            textField.text?.removeLast()
        }
        print("\(#function)")
    }
}
