//
//  ViewController.swift
//  P_Chat
//
//  Created by Eugene Kovs on 16.11.2023.
//

import UIKit
import Combine
import MultipeerConnectivity

class ViewController: UIViewController {
    
    var chatViewModel: ChatViewModel!
    private var cancellables = Set<AnyCancellable>()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let networkManager = NetworkManager.shared
        chatViewModel = ChatViewModel(networkManager: networkManager)
        setupBindings()
        
        placeStack()
        assignButtons()
    }
    
    private func setupBindings() {
        chatViewModel.$messageContent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self else { return }
                self.message.text = message
            }
            .store(in: &cancellables)
        
        chatViewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                // Update chat interface here
            }
            .store(in: &cancellables)
    }
    
    
    @objc func startHosting() {
        chatViewModel.startHosting()
    }
    
    @objc func joinSession() {
        guard let mcSession = chatViewModel.networkManager.mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "p2p-chat", session: mcSession)
        mcBrowser.delegate = self
        
        self.present(mcBrowser, animated: true)
    }
    
    @objc func sendMessage() {
        chatViewModel.sendMessage("Message")
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
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
}

