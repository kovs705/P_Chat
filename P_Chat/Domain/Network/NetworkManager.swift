//
//  NetworkManager.swift
//  P_Chat
//
//  Created by Eugene Kovs on 21.01.2024.
//

import Foundation
import MultipeerConnectivity

protocol NetworkManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

class NetworkManager: NSObject, MCSessionDelegate {
    
    static let shared = NetworkManager()
    
    weak var delegate: NetworkManagerDelegate?
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    private override init() {
        super.init()
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    func startHosting() {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "p2p-chat", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }
    
    func stopHosting() {
        mcAdvertiserAssistant?.stop()
    }
    
    func sendMessage(_ content: String) {
        guard let mcSession = mcSession else { return }
        if mcSession.connectedPeers.count > 0 {
            if let messageData = content.data(using: .utf8) {
                do {
                    try mcSession.send(messageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    // Handle error
                }
            }
        }
    }
    
    // MCSessionDelegate methods
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
            
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async { [unowned self] in
                    guard let self = self, let delegate = self.delegate else { return }
                    delegate.didReceiveMessage(message)
                }
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Implement if needed
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Implement if needed
    }
}
