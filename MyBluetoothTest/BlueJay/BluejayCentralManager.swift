//
//  BluejayManager.swift
//  MyBluetoothTest
//
//  Created by t&a on 2024/04/03.
//

import UIKit
import SwiftUI
import Bluejay

let service = ServiceIdentifier(uuid: "00000000-0000-1111-1111-111111111111")
let readCharacteristic = CharacteristicIdentifier(uuid: "00000000-1111-1111-1111-111111111111", service: service)
let writeCharacteristic = CharacteristicIdentifier(uuid: "00000000-2222-1111-1111-111111111111", service: service)

class BluejayCentralManager: ObservableObject {
    
    /// シングルトン
    static var shared = BluejayCentralManager()
    
    /// ログ出力用
    @Published var log = ""
    
    /// bluejayインスタンス
    private var bluejay = Bluejay()
    
    /// スキャン時に発見したペリフェラル一覧
    private var discoveries: [ScanDiscovery] = []
    
    init() {
        config()
    }
    
    /// 初期設定
    private func config() {
        self.bluejay.register(logObserver: self)
        bluejay.registerDisconnectHandler(handler: self)
        bluejay.register(connectionObserver: self)
        bluejay.register(serviceObserver: self)
        self.bluejay.start()
    }
    
    public func getStatus() {
        log.append("\(bluejay.isConnecting)")
        log.append("\(bluejay.isConnected)")
        log.append("\(bluejay.isScanning)")
    }
    
    /// スキャン&コネクト処理
    public func startScan() {
        log.append("スキャン開始\n")
    
        bluejay.scan(
            serviceIdentifiers: [service],
            discovery: { [weak self] (discovery, discoveries) -> ScanAction in
                guard let self = self else { return .stop }
                
                if discoveries.count != 0 {
                    self.log.append("発見: \(discoveries.count)個\n")
                    self.discoveries = discoveries
                    return .connect(discoveries.first!, .none, .default) { result in
                        switch result {
                        case .success:
                            self.log.append("コネクト成功: \n")
                        case .failure(let error):
                            self.log.append("コネクト失敗エラー: \(error.localizedDescription)\n")
                        }
                    }
                } else {
                    self.log.append("見つかりませんでした\n")
                    return .continue
                }
                
            },
            stopped: { [weak self]  (discoveries, error) in
                guard let self = self else { return }
                if let error = error {
                    self.log.append("スキャン停止エラー: \(error.localizedDescription)\n")
                } else {
                    self.log.append("スキャン停止\n")
                }
            })
    }
    
    /// コネクト(未使用)
    private func connect() {
        log.append("コネクト\n")
        guard let peripheral = discoveries.first else {
            log.append("サービスなし\n")
            return
        }
        bluejay.connect(peripheral.peripheralIdentifier, timeout: .seconds(15)) { result in
            switch result {
            case .success:
                self.log.append("コネクト成功: \(peripheral.peripheralIdentifier)\n")
            case .failure(let error):
                self.log.append("コネクト失敗エラー: \(error.localizedDescription)\n")
            }
        }
    }
    
    /// Read処理
    public func readData() {
        bluejay.read(from: readCharacteristic) { [weak self] (result: ReadResult<UInt8>) in
            guard let self = self else { return }
            switch result {
            case .success(let location):
                self.log.append("Read成功: \(location)\n")
            case .failure(let error):
                self.log.append("Read失敗: \(error.localizedDescription)\n")
            }
        }
    }
    
    /// Write処理
    public func registerData() {
        bluejay.write(to: writeCharacteristic, value: "Hello") { [weak self] (result: WriteResult) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.log.append("Write成功: \n")
            case .failure(let error):
                self.log.append("Write失敗: \(error.localizedDescription)\n")
            }
        }
    }
    
    /// 切断
    public func disConnect() {
        if bluejay.isConnected {
            log.append("切断\n")
            /// 切断(キューの終了を待って)
            bluejay.disconnect()
            /// 即時切断(キューの終了を待たずに)
            // bluejay.disconnect(immediate: true)
        }
    }
    
    /// リセット
    public func cancelEverything() {
        log.append("リセット\n")
        /// キューをリセット
        bluejay.cancelEverything()
    }

}

extension BluejayCentralManager: LogObserver, ConnectionObserver, ServiceObserver, DisconnectHandler {
    
    func didDisconnect(from peripheral: PeripheralIdentifier, with error: Error?, willReconnect autoReconnect: Bool) -> AutoReconnectMode {
        AutoReconnectMode.noChange
    }
    
    func didModifyServices(from peripheral: PeripheralIdentifier, invalidatedServices: [ServiceIdentifier]) { }
    
    func bluetoothAvailable(_ available: Bool) { }
    
    func connected(to peripheral: PeripheralIdentifier) { }
    
    func disconnected(from peripheral: PeripheralIdentifier) { }
    
    func debug(_ text: String) { }
}
