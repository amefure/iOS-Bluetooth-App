//
//  MyBluetoothTestApp.swift
//  MyBluetoothTest
//
//  Created by t&a on 2024/01/04.
//

import SwiftUI

@main
struct MyBluetoothTestApp: App {
    private var isBlueJay = false
    var body: some Scene {
        WindowGroup {
            if isBlueJay {
                // BlueJay
                BlueJayRootView()
            } else {
                // Core Bluetooth
                CoreBlueRootView()
            }
        }
    }
}
