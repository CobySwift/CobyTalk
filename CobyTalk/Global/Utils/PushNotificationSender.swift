//
//  PushNotificationSender.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import Foundation

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let server_key = "AAAABvv04PU:APA91bGURYDyrar4_QkP3r9Nkk5xd28dUW3L3UbSBDlNIyJl-reloqHP8CUbO6YW6KZfMbM80EH_xlQu0WNtkOedTIHqzVCcKeK1ZVy95EjEHb8M4iL2uYMe6pr8619-qp-AgJ_51q1I"
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(server_key)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
