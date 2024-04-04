//
//  ContentView.swift
//  SwiftUI-iOS
//
//  Created by Pallab Maiti on 11/02/24.
//

import SwiftUI
import Rudder

struct ContentView: View {
    let client: RSClient
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .recordScreen(name: "Hello", in: client)
    }
        
}

#Preview {
    ContentView(client: RSClient.client)
}
