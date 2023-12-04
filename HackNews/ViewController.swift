//
//  ViewController.swift
//  HackNews
//
//  Created by Chan Gu on 2023/12/01.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func showNewsTableViewController(_ sender: UIButton) {
        let newsTableViewController = NewsTableViewController()
        let navigationController = UINavigationController(rootViewController: newsTableViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }

    @IBOutlet weak var userImageView: UIImageView!


    let photoButton = UIButton()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        addPhotoButton()

    }

    private func addPhotoButton() {
        photoButton.backgroundColor = .lightGray
        photoButton.setTitle("Add Photo", for: .normal)
        photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        photoButton.layer.cornerRadius = 10

        //don't set addSubview under position/size design
        view.addSubview(photoButton)

        photoButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -IMAGE_BUTTON_SIZE),
            photoButton.heightAnchor.constraint(equalToConstant: IMAGE_BUTTON_SIZE),
            photoButton.widthAnchor.constraint(equalToConstant: IMAGE_BUTTON_SIZE)
        ])
        photoButton.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
    }

    @objc func selectImageTapped(_ sender: UIButton) {
        presentImagePicker()
    }

    private func presentImagePicker() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             userImageView.image = pickedImage
             photoButton.isHidden = true  // Hide the button
         }
         picker.dismiss(animated: true, completion: nil)
     }

     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
     }
}

