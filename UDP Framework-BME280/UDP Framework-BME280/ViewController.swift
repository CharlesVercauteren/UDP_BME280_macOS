//
//  ViewController.swift
//  UDP Framework-BME280
//
//  Created by Charles Vercauteren on 11/02/2022.
//

import Cocoa
import Network

let ipAddress = "10.89.1.90"
let portNumber = "2000"

let GET_TEMPERATURE = "10"
let GET_HUMIDITY = "11"
let GET_PRESSURE = "12"

let interval: TimeInterval = 1

let commands = [GET_TEMPERATURE, GET_HUMIDITY, GET_PRESSURE]
var index = 0

class ViewController: NSViewController {

    var udpClient = UDPFramework()
    var timer = Timer()

    @IBOutlet weak var temperatureLbl: NSTextField!
    @IBOutlet weak var humidityLbl: NSTextField!
    @IBOutlet weak var pressureLbl: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        udpClient.delegate = self

        //Create host
        let ip = ipAddress
        let host = NWEndpoint.Host(ip)
        //Create port
        let port = NWEndpoint.Port(portNumber)!
        //Create endpoint
        udpClient.connect(host: host, port: port)
        
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(update),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func update() {
        index += 1
        if index >= commands.count { index = 0 }
        udpClient.sendPacket(text: commands[index])
    }

}


extension ViewController: UDPMessages  {
    func serverReady() {
    }
    
    func receivedMessage(message: String) {
        // Splits message in commando en resultaat
        let firstSpace = message.firstIndex(of: " ") ?? message.endIndex
        let command = message[..<firstSpace]
        let result = String(message.suffix(from: firstSpace).dropFirst())
        switch index {
        case 0:
            temperatureLbl.stringValue = result + "°C"
        case 1:
            humidityLbl.stringValue = result + " %"
        case 2:
            pressureLbl.stringValue = result + "hPa"
        default:
            temperatureLbl.stringValue = "Fout"
    }
    
    }
}
