//
//  LoginViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import FirebaseAuth
import SnapKit
import Then

final class LoginViewController: UIViewController {
    
    private lazy var displayNameField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        $0.backgroundColor = .white
        $0.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: attributes)
        $0.autocapitalizationType = .none
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
        $0.addTarget(
            self,
            action: #selector(textFieldDidReturn),
            for: .primaryActionTriggered)
    }
    
    private lazy var logInbutton = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Log In", for: .normal)
        $0.addTarget(
            self,
            action: #selector(actionButtonPressed),
            for: .primaryActionTriggered)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(displayNameField)
        view.addSubview(logInbutton)
        
        displayNameField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        logInbutton.snp.makeConstraints {
            $0.top.equalTo(displayNameField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayNameField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    @IBAction private func actionButtonPressed() {
        signIn()
    }
    
    @objc private func textFieldDidReturn() {
        signIn()
    }
    
    private func signIn() {
        guard
            let name = displayNameField.text,
            !name.isEmpty
        else {
            showMissingNameAlert()
            return
        }
        
        displayNameField.resignFirstResponder()
        
        AppSettings.displayName = name
        Auth.auth().signInAnonymously()
    }
    
    private func showMissingNameAlert() {
        let alertController = UIAlertController(
            title: "Display Name Required",
            message: "Please enter a display name.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "Okay",
            style: .default) { _ in
                self.displayNameField.becomeFirstResponder()
            }
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
