//
//  FirebaseManager.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

final class FirebaseManager: NSObject {
    
    static let shared = FirebaseManager()
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
    func signInUser(email: String, password: String) async -> String? {
        do {
            let data = try await auth.signIn(withEmail: email, password: password)
            print("Success LogIn")
            return data.user.uid
        } catch {
            print("Failed to LogIn")
            return nil
        }
    }
    
    func createNewAccount(email: String, password: String) async {
        do {
            try await auth.createUser(withEmail: email, password: password)
            print("Successfully created user")
        } catch {
            print("Failed to create user")
        }
    }
    
    func deleteAccount() async {
        do {
            try await auth.currentUser?.delete()
        } catch {
            print("Failed to disconnect friend")
        }
    }
    
    func storeUserInformation(email: String, name: String) async {
        guard let uid = auth.currentUser?.uid else { return }
        do {
//            let appDelegate = await UIApplication.shared.delegate as! AppDelegate
//            let userToken = await appDelegate.userToken
            let userData = ["email": email, "uid": uid, "name": name]
        
            try await firestore.collection("users").document(uid).setData(userData)
        } catch {
            print("Store User error")
        }
    }
    
    func getUser() async -> User? {
        guard let uid = auth.currentUser?.uid else { return nil }
        do {
            let user = try await firestore.collection("users").document(uid).getDocument(as: User.self)
            print("Success get user")
            return user
        } catch {
            print("Get User error")
            return nil
        }
    }
    
    func getUserWithId(id: String) async -> User? {
        do {
            let user = try await firestore.collection("users").document(id).getDocument(as: User.self)
            print("Success get user")
            return user
        } catch {
            print("Get User error")
            return nil
        }
    }
    
    func updateUserToken(uid: String) async {
        do {
//            let appDelegate = await UIApplication.shared.delegate as! AppDelegate
//            let userToken = await appDelegate.userToken
//            try await FirebaseManager.store.collection("users").document(uid).updateData(["token" : userToken])
            print("Success Update")
        } catch {
            print("Update User error")
        }
    }
    
    func getUsers() async -> [User]? {
        guard let uid = auth.currentUser?.uid else { return nil }
        do {
            var users = [User]()
            
            let documentsSnapshot = try await firestore.collection("users").getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                guard let user = try? snapshot.data(as: User.self) else { return }
                if user.uid != uid {
                    users.append(user)
                }
            })
            
            print("Success get users")
            return users
        } catch {
            print("Get Users error")
            return nil
        }
    }
    
    func createChatMessage(currentUser: User, chatUser: User, chatText: String) {
        
        guard let fromId = currentUser.id, let toId = chatUser.id else { return }
        
        let document = firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())
        
        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                return
            }
            
            print("Successfully saved current user sending message")
        }
        
        let recipientMessageDocument = firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
                return
            }
            
            print("Recipient saved message as well")
        }
        
        persistRecentMessage(currentUser: currentUser, chatUser: chatUser, chatText: chatText)
    }
    
    func persistRecentMessage(currentUser: User, chatUser: User, chatText: String) {
        
        guard let fromId = currentUser.id, let toId = chatUser.id else { return }
        
        let document = firestore
            .collection("recentMessages")
            .document(fromId)
            .collection("messages")
            .document(toId)
        
        let data = [
            "timestamp": Timestamp(),
            "text": chatText,
            "fromId": fromId,
            "toId": toId,
            "userName": chatUser.name
        ] as [String : Any]
   
        document.setData(data) { error in
            if let error = error {
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        let recipientMessageDocument = firestore
            .collection("recentMessages")
            .document(toId)
            .collection("messages")
            .document(fromId)
        
        let recipientMessageData = [
            "timestamp": Timestamp(),
            "text": chatText,
            "fromId": toId,
            "toId": fromId,
            "userName": currentUser.name
        ] as [String : Any]
        
        recipientMessageDocument.setData(recipientMessageData) { error in
            if let error = error {
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
}
