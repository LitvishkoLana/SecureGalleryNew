//
//  FullScreenViewController.swift
//  SecureGallery
//
//  Created by Светлана on 3.01.23.
//

import UIKit

class FullScreenViewController: UIViewController, UIScrollViewDelegate {

    var image = UIImage()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        imageView.image = image
        scrollView.delegate = self
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
