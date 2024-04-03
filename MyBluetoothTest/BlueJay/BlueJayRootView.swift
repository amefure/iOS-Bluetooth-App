//
//  BlueJayRootView.swift
//  MyBluetoothTest
//
//  Created by t&a on 2024/04/03.
//

import SwiftUI

struct BlueJayRootView: View {
    
    @ObservedObject var bluejayManager = BluejayCentralManager.shared
    var body: some View {
        // MARK : - Central
        VStack{
            TextEditor(text: $bluejayManager.log)
            
            Divider()
            
            
            HStack{
                
        
                Button {
                    bluejayManager.readData()
                } label: {
                    Text("読み込み")
                }.padding()
                    .frame(width:150)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                
                Button {
                    bluejayManager.registerData()
                } label: {
                    Text("書き込み")
                }.padding()
                    .frame(width:150)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
            }
            HStack{
                Button {
                    bluejayManager.startScan()
                } label: {
                    Text("スキャン")
                }.padding()
                    .frame(width:150)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Button {
                    bluejayManager.disConnect()
                } label: {
                    Text("切断")
                }.padding()
                    .frame(width:150)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
    }
}

#Preview {
    BlueJayRootView()
}
