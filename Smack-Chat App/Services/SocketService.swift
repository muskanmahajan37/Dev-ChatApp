//
//  SocketService.swift
//  Smack-Chat App
//
//  Created by Ketan Choyal on 10/12/18.
//  Copyright © 2018 Ketan Choyal. All rights reserved.
//

import UIKit
import SocketIO

class SocketService: NSObject {
    
    static let instance = SocketService()
    
    let manger : SocketManager
    let socket : SocketIOClient
    
    override init() {
        self.manger = SocketManager(socketURL: URL(string: BASE_URL)!)
        self.socket = manger.defaultSocket
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func addChannel(channelName : String, channelDescription : String, completion : @escaping CompletionHandler) {
        
        let name = channelName.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = channelDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        socket.emit("newChannel", name, description)
        completion(true)
        
    }
    
    func getChannel(completion : @escaping CompletionHandler) {
        
        socket.on("channelCreated") { (dataArray, ack) in
            guard let channelName = dataArray[0] as? String else { return }
            guard let channelDesc = dataArray[1] as? String else { return }
            guard let channelId = dataArray[2] as? String else { return }
            
            let newChannel = Channel.init(channelTitle: channelName, channelDescription: channelDesc, id: channelId)
            
            MessageService.instance.channels.append(newChannel)
            
            completion(true)
        }
    }
    
    func addMessage(messageBody : String, channelId : String, completion : @escaping CompletionHandler) {
        let user = UserDataService.instance
        socket.emit("newMessage", messageBody, user.id, channelId, user.name, user.avatarName, user.avatarColor)
        completion(true)
    }

}