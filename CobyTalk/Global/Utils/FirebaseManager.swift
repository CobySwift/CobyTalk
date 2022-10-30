//
//  FirebaseManager.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    static let store = Firestore.firestore()
    static let auth = Auth.auth()
    
    private init() { }
    
    func signInUser(email: String, password: String) async -> String? {
        do {
            let data = try await FirebaseManager.auth.signIn(withEmail: email, password: password)
            print("Success LogIn")
            return data.user.uid
        } catch {
            print("Failed to LogIn")
            return nil
        }
    }
    
    func createNewAccount(email: String, password: String) async {
        do {
            try await FirebaseManager.auth.createUser(withEmail: email, password: password)
            print("Successfully created user")
        } catch {
            print("Failed to create user")
        }
    }
    
    func deleteAccount() async {
        do {
            try await FirebaseManager.auth.currentUser?.delete()
        } catch {
            print("Failed to disconnect friend")
        }
    }
    
    func storeUserInformation(email: String, name: String) async {
        guard let uid = FirebaseManager.auth.currentUser?.uid else { return }
        do {
//            let appDelegate = await UIApplication.shared.delegate as! AppDelegate
//            let userToken = await appDelegate.userToken
            let userData = ["email": email, "uid": uid, "name": name]
        
            try await FirebaseManager.store.collection("users").document(uid).setData(userData)
        } catch {
            print("Store User error")
        }
    }
    
    func getUser() async -> User? {
        guard let uid = FirebaseManager.auth.currentUser?.uid else { return nil }
        do {
            let data = try await FirebaseManager.store.collection("users").document(uid).getDocument(as: User.self)
            print("Success get user")
            return data
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
        guard let userId = FirebaseManager.auth.currentUser?.uid else { return nil }
        do {
            var users = [User]()
            
            let documentsSnapshot = try await FirebaseManager.store.collection("users").getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                let user = try? snapshot.data(as: User.self)
                if user == nil { return }
                if user!.uid != userId {
                    users.append(user!)
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
        guard let userId = FirebaseManager.auth.currentUser?.uid else { return nil }
        do {
            var friends = [User]()
            
            let documentsSnapshot = try await FirebaseManager.store.collection("users").document(userId).collection("friends").getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                let friend = try? snapshot.data(as: User.self)
                if friend == nil { return }
                friends.append(friend!)
            })
            
            print("Success get friends")
            
            return friends
        } catch {
            print("Get Friends error")
            return nil
        }
    }
    
    func getFriendIds() async -> [String]? {
        guard let userId = FirebaseManager.auth.currentUser?.uid else { return nil }
        do {
            var friendIds = [String]()
            
            let documentsSnapshot = try await FirebaseManager.store.collection("users").document(userId).collection("friends").getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                let friend = try? snapshot.data(as: User.self)
                if friend == nil { return }
                friendIds.append(friend!.uid)
            })
            
            print("Success get friendIds")
            
            return friendIds
        } catch {
            print("Get Friends error")
            return nil
        }
    }
    
    func connectUser(user: User, friend: User) {
        let documentUser = FirebaseManager.store
            .collection("users")
            .document(user.id!)
            .collection("friends")
            .document(friend.uid)
        
        let dataUser = [
            "uid": friend.uid,
            "email": friend.email,
            "name": friend.name,
        ] as [String : Any]
        
        documentUser.setData(dataUser)
        
        let documentFriend = FirebaseManager.store
            .collection("users")
            .document(friend.uid)
            .collection("friends")
            .document(user.id!)
        
        let dataFriend = [
            "uid": user.id!,
            "email": user.email,
            "name": user.name,
        ] as [String : Any]
        
        documentFriend.setData(dataFriend)
        
        print("Success to make friend")
    }
    
    func getChannels() async -> [Channel]? {
        guard let userId = FirebaseManager.auth.currentUser?.uid else { return nil }
        do {
            var channels = [Channel]()
            
            let documentsSnapshot = try await FirebaseManager.store.collection("users").getDocuments()
            
            documentsSnapshot.documents.forEach({ snapshot in
                guard let user = try? snapshot.data(as: User.self) else { return }
                if user.uid != userId {
                    channels.append(Channel(name: user.name))
                }
            })
            
            print("Success get channels")
            return channels
        } catch {
            print("Get Users error")
            return nil
        }
    }
}
