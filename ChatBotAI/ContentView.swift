//
//  ContentView.swift
//  ChatBotAI
//
//  Created by Mukesh Shama on 2023-01-01.
//

import SwiftUI

struct ContentView: View {
    
    var swiftUISpeech = SwiftUISpeech();// initialize the class here
    
    var body: some View {
        ChatView()
            .onAppear(perform: setup)
            .foregroundColor(.white)
            .environmentObject(swiftUISpeech)


    }
    
    func setup() {
        APICaller.shared.setup()
    }

}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
