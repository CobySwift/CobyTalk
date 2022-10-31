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
    
    func getFriends() async -> [User]? {
        guard let uid = auth.currentUser?.uid else { return nil }
        do {
            var friends = [User]()
            
            let documentsSnapshot = try await firestore.collection("users").document(uid).collection("friends").getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                guard let friend = try? snapshot.data(as: User.self) else { return }
                friends.append(friend)
            })
            
            print("Success get friends")
            
            return friends
        } catch {
            print("Get Friends error")
            return nil
        }
    }
    
    func getRecentMessages() async -> [RecentMessage]? {
        guard let uid = auth.currentUser?.uid else { return nil }
        do {
            var recentMessages = [RecentMessage]()
            
            let documentsSnapshot = try await firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .order(by: "timestamp")
                .getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                guard let recentMessage = try? snapshot.data(as: RecentMessage.self) else { return }
                
                if let index = recentMessages.firstIndex(where: { rm in
                    return rm.id == recentMessage.id
                }) {
                    recentMessages.remove(at: index)
                }
                
                do {
                    if let rm = try? recentMessage {
                        recentMessages.insert(rm, at: 0)
                    }
                } catch {
                    print(error)
                }
            })
            
            return recentMessages
        } catch {
            print("Get RecentMessages error")
            return nil
        }
    }
}
