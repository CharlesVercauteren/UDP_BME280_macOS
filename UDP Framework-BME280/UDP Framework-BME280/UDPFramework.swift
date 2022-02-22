//
//  UDPFramework.swift
//  UDP Framework
//
//  Created by Charles Vercauteren on 12/01/2022.
//

import Foundation
import Network

protocol UDPMessages {
    func serverReady()
    func receivedMessage(message: String)
}

class UDPFramework {
    var delegate: UDPMessages?
    var server: NWConnection?
    var reply = ""
    
    func connect(host: NWEndpoint.Host, port: NWEndpoint.Port){
        server = NWConnection(host: host, port: port, using: NWParameters.udp)
        server?.stateUpdateHandler = stateUpdateHandler(newState:)
        server?.start(queue: .main)
    }
    
    func sendPacket(text: String) {
        server!.send(content: text.data(using: String.Encoding.ascii), completion: .contentProcessed({
            error in
                self.receiveReply()
                if let error = error {
                    print("error while sending data: \(error).")
                    return
                }
            }))}
    
    func disconnect() {
        server?.forceCancel()
    }
    
    
    private func stateUpdateHandler(newState: NWConnection.State){
        switch (newState){
        case .setup:
            print("State: Setup.")
        case .waiting:
            print("State: Waiting.")
        case .ready:
            print("State: Ready.")
            delegate?.serverReady()
        case .failed:
            print("State: Failed.")
        case .cancelled:
            print("State: Cancelled.")
        default:
            print("State: Unknown state.")
        }
    }
    
    func receiveReply() {
        server?.receiveMessage(completion: {(content, context,   isComplete, error) in
            self.reply = String(decoding: content ?? Data(), as:   UTF8.self)
            if self.reply != "", isComplete {
                self.delegate?.receivedMessage(message: self.reply)
                self.receiveReply()

            }
            })}
    
}
