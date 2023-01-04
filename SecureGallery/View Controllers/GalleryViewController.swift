//
//  GalleryViewController.swift
//  SecureGallery
//
//  Created by Светлана on 3.11.22.
//

import UIKit
import Kingfisher

class GalleryViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pickImage: UIButton!
    
    // MARK: - Public properties
    let defaultCollectionViewSpacing: CGFloat = 2
    var imagesPerLine: CGFloat = 3
    
    var images : [UIImage] = []
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadImage()
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(changeCountInRow))
        collectionView.addGestureRecognizer(gesture)
        
        pickImage.setTitle(
            NSLocalizedString("Load image", comment: "Load image button"),
            for: .normal
        )
    }
    
    @objc private func changeCountInRow(recognizer : UIPinchGestureRecognizer) {
        if recognizer.state == .ended {
            switch recognizer.scale {
            case 0...1:
                if Int(imagesPerLine) < images.count {
                    imagesPerLine += 1
                }
            default:
                if imagesPerLine > 1 {
                    imagesPerLine -= 1
                }
            }
        }
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.register(GalleryCollectionViewCell.nib(), forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - IBActions
    @IBAction func pickImage(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraTranslit = NSLocalizedString("localizationCamera", comment: "translation of Camera")
        let cameraAction = UIAlertAction(title: cameraTranslit, style: .default) { _ in
            self.showPicker(withSourceType: .camera)
        }
       
        let photoLibraryTranslit = NSLocalizedString("localizationPhoto", comment: "translation of PhotoLibrary")
        let libraryAction = UIAlertAction(title: photoLibraryTranslit, style: .default) { _ in
            self.showPicker(withSourceType: .photoLibrary)
        }
        
        let cancelTranslit = NSLocalizedString("localizationCancel", comment: "translation of Cancel")
        let urlTranslit = NSLocalizedString("localizationURL", comment: "translation of URL")
        
        let EnterURLTranslit = NSLocalizedString("localizationEnterURL", comment: "translation of Enter URL alert")
        let cancelAction = UIAlertAction(title: cancelTranslit, style: .cancel)
        let urlAction = UIAlertAction(title: urlTranslit, style: .default) { _ in
            let alert = UIAlertController(
                title: EnterURLTranslit,
                message: nil,
                preferredStyle: .alert)
            
            alert.addTextField {
                (textField) in textField.placeholder = EnterURLTranslit
            }
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: { [weak alert] (_) in
                    guard let textField = alert?.textFields?[0] else { return }
                    if textField.text != nil {
                        guard let url = URL(string: textField.text ?? "") else { return }
                        let resource = ImageResource(downloadURL: url)
                        KingfisherManager.shared.retrieveImage(with: resource) { result in
                            switch result {
                            case .success(let value):
                                self.setImage(value.image)
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                    } else { return }
                    print("Text field: \(String(describing: textField.text))")
                }))
            let cancelAction = UIAlertAction(title: cancelTranslit, style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert,animated: true, completion: nil)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(libraryAction)
        }
        alert.addAction(urlAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func setImage(_ image: UIImage, withName name: String? = nil) {
        images.append(image)
        collectionView.reloadData()
        
        let fileName = name ?? UUID().uuidString
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("png")
        guard let data = image.pngData() else { return }
        
        deletePreviousImage()
        
        try? data.write(to: fileURL)
        UserDefaults.standard.set(fileName, forKey: "\(images.count)imageName")
        UserDefaults.standard.set(images.count, forKey: "images.count")
    }
    
    // MARK: - Private methods
    private func loadImage() {
        let count = UserDefaults.standard.integer(forKey: "images.count")
        guard count > 0 else { return }
        for index in 1...count {
            guard let fileName = UserDefaults.standard.string(forKey: "\(index)imageName") else { continue }
            
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("png")
            
            guard let savedData = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: savedData) else { continue }
            
            images.append(image)
        }
        collectionView.reloadData()
    }
    
    private func deletePreviousImage() {
        guard let fileName = UserDefaults.standard.string(forKey: "imageName") else { return }
        
        UserDefaults.standard.removeObject(forKey: "imageName")
        
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("png")
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private func showPicker(withSourceType sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = sourceType
        
        present(pickerController, animated: true)
    }
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        var name: String?
        if let imageName = info[.imageURL] as? URL {
            name = imageName.lastPathComponent
        }
        setImage(image, withName: name)
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presentedViewController?.dismiss(animated: true)
        let alertTitleTranslit = NSLocalizedString("localizationAlertTitle", comment: "translation of imagePickerControllerDidCancel alert title")
        let alertMessageTranslit = NSLocalizedString("localizationAlertMessage", comment: "translation of imagePickerControllerDidCancel alert message")
        let alert = UIAlertController(title: alertTitleTranslit, message: alertMessageTranslit, preferredStyle: .alert)
        
        let okActionAlertTitleTranslit = NSLocalizedString("localizationOkActionAlertTitle", comment: "translation of imagePickerControllerDidCancel okAction alert title")
        let okAction = UIAlertAction(title: okActionAlertTitleTranslit, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView
extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let destinationViewController = storyboard.instantiateViewController(withIdentifier: "FullScreenViewController") as? FullScreenViewController else { return }
        
        destinationViewController.image = images[indexPath.row]
        destinationViewController.modalPresentationStyle = .fullScreen
        present(destinationViewController,animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.setup(with: images[index])
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (imagesPerLine - 1) * defaultCollectionViewSpacing
        let width = (collectionView.bounds.width - totalSpacing) / imagesPerLine
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return defaultCollectionViewSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return defaultCollectionViewSpacing
    }
}

