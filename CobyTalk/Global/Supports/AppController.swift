//
//  AppController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit
import Firebase

final class AppController {
    static let shared = AppController()
    
    private var window: UIWindow!
    private var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppState),
            name: .AuthStateDidChange,
            object: nil)
    }
    
    // MARK: - Helpers
    func configureFirebase() {
        FirebaseApp.configure()
    }
    
    func show(in window: UIWindow?) {
        guard let window = window else {
            fatalError("Cannot layout app with a nil window.")
        }
        
        self.window = window
        window.tintColor = .black
        window.backgroundColor = .white
        
        handleAppState()
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Notifications
    @objc private func handleAppState() {
        if Auth.auth().currentUser != nil {
            rootViewController = UINavigationController(rootViewController: ChannelsViewController())
        } else {
            rootViewController = UINavigationController(rootViewController: LogInViewController())
        }
    }
}
