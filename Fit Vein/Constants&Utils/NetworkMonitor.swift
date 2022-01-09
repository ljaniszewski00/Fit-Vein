//
//  NetworkMonitor.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 09/01/2022.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    
    public private(set) var connectionType: ConnectionType?
    
    enum ConnectionType {
        case wifi
        case cellurar
        case ethernet
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.setConnectionType(path)
            print()
            print()
            print(self?.isConnected)
            print()
            print()
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }
    
    func setConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self.connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            self.connectionType = .cellurar
        } else if path.usesInterfaceType(.wiredEthernet) {
            self.connectionType = .ethernet
        }
    }
}
