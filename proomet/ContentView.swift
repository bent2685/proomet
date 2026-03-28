//
//  ContentView.swift
//  proomet
//
//  Created by bent on 2026/3/28.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .home

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
        } detail: {
            DetailView(selectedItem: selectedItem)
        }
    }
}

#Preview {
    ContentView()
}
