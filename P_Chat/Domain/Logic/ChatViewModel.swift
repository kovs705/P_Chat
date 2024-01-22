//
//  ChatViewModel.swift
//  P_Chat
//
//  Created by Eugene Kovs on 21.01.2024.
//

import Foundation
import MultipeerConnectivity

class ChatViewModel: ObservableObject, NetworkManagerDelegate {
    @Published var messageContent: String = ""
    @Published var messages: [Message] = []
    
    var networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func didReceiveMessage(_ message: String) {
        DispatchQueue.main.async {
            self.messageContent = message
        }
    }
    
    func startHosting() {
        networkManager.startHosting()
    }
    
    func sendMessage(_ content: String) {
        networkManager.sendMessage(content)
        messageContent = content
        //        messages.append(Message(content: content, sender: networkManager.peerID.displayName))
    }
}

