//
//  ContentView.swift
//  AdaptivePanelExample
//  
//  Created by Masato Takimoto on 2026/03/16.
//  
//

import SwiftUI
import AdaptivePanel


// ContentView.swift
struct ContentView: View {
    var body: some View {
        TabView {
            DetentExampleView()
                .tabItem {
                    Label("Basic", systemImage: "rectangle.bottomhalf.inset.filled")
                }
            ItemExampleView()
                .tabItem {
                    Label("Item", systemImage: "list.bullet")
                }
            SelectionExampleView()
                .tabItem {
                    Label("Selection", systemImage: "link")
                }
            BackgroundContentExampleView()
                .tabItem {
                    Label("Background(Content)", systemImage: "square.and.arrow.up")
                }
        }
    }
}

#Preview {
    ContentView()
}
