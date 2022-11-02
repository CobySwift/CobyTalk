//
//  LogInViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import SnapKit
import Then

final class LogInViewController: BaseViewController {
    
    private let loginLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "로그인"
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
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
    
    private lazy var logInbutton = UIButton().then {
        $0.backgroundColor = .mainBlack
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("로그인", for: .normal)
        $0.addTarget(self, action: #selector(didTapLogInbutton), for: .touchUpInside)
    }
        
    private lazy var signUpButton = UIButton().then {
        $0.backgroundColor = .mainBlack
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("회원가입", for: .normal)
        $0.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    private let logInErrorLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "Failed to Log In"
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .mainBlack
        $0.isHidden = true
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
        view.addSubviews(loginLabel, emailField, passwordField, logInbutton, signUpButton, logInErrorLabel)
        
        loginLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        logInbutton.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(logInbutton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        logInErrorLabel.snp.makeConstraints {
            $0.top.equalTo(signUpButton.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @objc private func didTapLogInbutton() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            print("Missing field data")
            logInErrorLabel.isHidden = false
            return
        }
        
        Task {
            if let uid = await FirebaseManager.shared.signInUser(email: email, password: password) {
                await FirebaseManager.shared.updateUserToken(uid: uid)
                
                let navigationController = UINavigationController(rootViewController: ChannelsViewController())
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        
        logInErrorLabel.isHidden = false
    }
    
    @objc private func didTapSignUpButton() {
        let viewController = SignUpViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
