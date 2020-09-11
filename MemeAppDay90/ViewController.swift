//
//  ViewController.swift
//  MemeAppDay90
//
//  Created by Samat on 26.08.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit

enum MemePosition {
    case top, bottom
}

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    var editedImages = [UIImage]()
    let accentColor = UIColor.systemRed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navbarFont = UIFont(name: "SignPainter", size: 20) {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: navbarFont]
        }
        title = "Meme App"
        navigationController?.navigationBar.tintColor = accentColor
        navigationController?.toolbar.tintColor = accentColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        configureToolbar()
    }

    
    func configureUndoButton() {
        if editedImages.count > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undoMeme))
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    
    func configureToolbar() {
        let topMeme = UIBarButtonItem(title: "Top Text", style: .plain, target: self, action: #selector(setTopMeme))
        let bottomMeme = UIBarButtonItem(title: "Bottom Text", style: .plain, target: self, action: #selector(setBottomMeme))
        
        if let navbarFont = UIFont(name: "SignPainter", size: 22) {
            topMeme.setTitleTextAttributes([NSAttributedString.Key.font: navbarFont], for: .normal)
            bottomMeme.setTitleTextAttributes([NSAttributedString.Key.font: navbarFont], for: .normal)
        }
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let addPicture = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        
        
        navigationController?.setToolbarHidden(false, animated: false)
        toolbarItems = [topMeme, space, addPicture, space, bottomMeme]
    }
    
    
    @objc func undoMeme() {
        editedImages.removeLast()
        imageView.image = editedImages.last
        configureUndoButton()
    }
    
    
    @objc func setTopMeme() { showAlertToAddMeme(at: .top) }
    @objc func setBottomMeme() { showAlertToAddMeme(at: .bottom) }
    
    
    func showAlertToAddMeme(at position: MemePosition) {
        let ac = UIAlertController(title: "Add Text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            if let text = ac.textFields?[0].text {
                self?.addMeme(with: text, at: position)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.view.tintColor = accentColor
        present(ac, animated: true)
    }
    
    
    func addMeme(with text: String, at position: MemePosition) {
        guard let size = imageView.image?.size else { return }
        
        let memeFontSize = size.height / 7
        let memeHeight = memeFontSize + 20
        let memeY: CGFloat
            
        switch position {
        case .top:
            memeY = 20
        case .bottom:
            memeY = size.height - memeHeight
        }
        
        guard let memeFont = UIFont(name: "SignPainter", size: memeFontSize) else { return }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let imageWithMeme = renderer.image { ctx in
            
            let image = imageView.image
            image?.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: memeFont,
                .strokeWidth: 2,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attrs)
            attributedString.draw(with: CGRect(x: 0, y: memeY, width: size.width, height: memeHeight), options: .usesLineFragmentOrigin, context: nil)
        }
        
        imageView.image = imageWithMeme
        editedImages.append(imageWithMeme)
        configureUndoButton()
    }
    
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let ac = UIAlertController(title: "Import photo", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "📷 Camera", style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            }
            self?.present(picker, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "🌄 Library", style: .default, handler: { [weak self] _ in
            self?.present(picker, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.view.tintColor = accentColor
        present(ac, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        dismiss(animated: true)
        
        editedImages.removeAll()
        imageView.image = image
        editedImages.append(image)
    }
    
    
    @objc func shareTapped() {
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.8) else { return }

        let vc = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

