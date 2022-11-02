//
//  SignUpViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import SnapKit
import Then

final class SignUpViewController: BaseViewController {
    
    private lazy var imagePicker = UIImagePickerController().then {
        $0.sourceType = .photoLibrary
        $0.allowsEditing = true
        $0.delegate = self
    }
    
    private lazy var photoImageView = UIImageView().then {
        $0.image = ImageLiteral.btnProfile
        $0.layer.cornerRadius = 40
        $0.clipsToBounds = true
        
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectButtonTouched)))
    }
    
    private let emailField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.mainBlack,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        $0.backgroundColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "Email", attributes: attributes)
        $0.autocapitalizationType = .none
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
        $0.makeShadow(color: .black, opacity: 0.08, offset: CGSize(width: 0, height: 4), radius: 20)
    }
    
    private let passwordField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.mainBlack,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        $0.backgroundColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
        $0.isSecureTextEntry = true
        $0.makeShadow(color: .black, opacity: 0.08, offset: CGSize(width: 0, height: 4), radius: 20)
    }
    
    private let nameField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.mainBlack,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        $0.backgroundColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "Name", attributes: attributes)
        $0.autocapitalizationType = .none
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
        $0.makeShadow(color: .black, opacity: 0.08, offset: CGSize(width: 0, height: 4), radius: 20)
    }

    private lazy var signUpButton = UIButton().then {
        $0.backgroundColor = .mainBlack
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Start", for: .normal)
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidekeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }

    override func render() {
        view.addSubviews(photoImageView, emailField, passwordField, nameField, signUpButton)
        
        photoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(80)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(photoImageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        nameField.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(nameField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        title = "Sign Up"
    }
    
    
    @objc private func selectButtonTouched(_ recognizer: UITapGestureRecognizer) {
        self.present(imagePicker, animated: true)
    }
    
    @objc private func didTapSignUpButton() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty,
              let profileImage = photoImageView.image
        else {
            print("Missing field data")
            return
        }
        
        Task {
            await FirebaseManager.shared.createNewAccount(email: email, password: password)
            await FirebaseManager.shared.storeUserInformation(email: email, name: name, profileImage: profileImage)
        }
        
        let navigationController = UINavigationController(rootViewController: ChannelsViewController())
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage : UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage    // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage        // 원본 이미지가 있을 경우
        }
        self.photoImageView.image = newImage
        dismiss(animated: true, completion: nil)
    }
}
