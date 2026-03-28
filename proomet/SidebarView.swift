//
//  SidebarView.swift
//  proomet
//
//  Created by bent on 2026/3/28.
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case home = "主页"
    case explore = "探索"
    case settings = "设置"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: return "house"
        case .explore: return "safari"
        case .settings: return "gear"
        }
    }
}

struct SidebarView: View {
    @Binding var selectedItem: SidebarItem?

    var body: some View {
        List(SidebarItem.allCases, selection: $selectedItem) { item in
            Label(item.rawValue, systemImage: item.icon)
                .tag(item)
        }
        .navigationTitle("Proomet")
    }
}
