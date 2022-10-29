//
//  SceneDelegate.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        AppController.shared.show(in: window)
    }
}
