//
//  NetworkMonitor.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 09/01/2022.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    
    private let queue = DispatchQueue.global()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true
    
    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive

            if path.status == .satisfied {
                print("We're connected!")
                // post connected notification
            } else {
                print("No connection.")
                // post disconnected notification
            }
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
