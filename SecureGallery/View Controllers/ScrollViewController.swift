//
//  ScrollViewController.swift
//  SecureGallery
//
//  Created by Светлана on 10.11.22.
//

import UIKit

class ScrollViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotifications()
        textField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    // MARK: - IBActions
    @IBAction func closeController(_ sender: Any) {
        dismiss(animated: true)
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
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        view.layoutIfNeeded()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension ScrollViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
