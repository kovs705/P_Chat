//
//  ViewController.swift
//  P_Chat
//
//  Created by Eugene Kovs on 16.11.2023.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    let button1: UIButton = {
       let button1 = UIButton()
        button1.setTitle("Start hosting", for: .normal)
        button1.backgroundColor = .blue
        return button1
    }()
    
    let button2: UIButton = {
        let button2 = UIButton()
        button2.setTitle("Connect to host", for: .normal)
        button2.backgroundColor = .blue
        return button2
    }()
    
    let button3: UIButton = {
       let button = UIButton()
        button.setTitle("Send message", for: .normal)
        button.backgroundColor = . blue
        return button
    }()
    
    var message: UILabel = {
        let label = UILabel()
        label.text = "Text here"
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }()
    
    var stackView = UIStackView(frame: .zero)
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        placeStack()
        assignButtons()
    }
    
    @objc func startHosting() {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "p2p-chat", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }

    @objc func joinSession() {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "p2p-chat", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    @objc func sendMessage() {
        guard let mcSession = mcSession else { return }
            if mcSession.connectedPeers.count > 0 {
                
                if let message = "Message".data(using: .utf8) {
                    do {
                        try mcSession.send(message, toPeers: mcSession.connectedPeers, with: .reliable)
                    } catch {
                        let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        present(ac, animated: true)
                    }
                }
            }
    }
    
    func placeStack() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
        stackView.addArrangedSubview(message)
        
        view.addSubview(stackView)

        // Enable Auto Layout
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Set up constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func assignButtons() {
        button1.addTarget(self, action: #selector(startHosting), for: .touchUpInside)
        button2.addTarget(self, action: #selector(joinSession), for: .touchUpInside)
        button3.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }


}

extension ViewController: MCSessionDelegate {
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
            let str = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async { [unowned self] in
                guard let self = self else { return }
                self.message.text = str
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
    
    
}

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
}

