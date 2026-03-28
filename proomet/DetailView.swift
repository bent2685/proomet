//
//  DetailView.swift
//  proomet
//
//  Created by bent on 2026/3/28.
//

import SwiftUI

struct DetailView: View {
    let selectedItem: SidebarItem?

    var body: some View {
        Group {
            switch selectedItem {
            case .home:
                HomeView()
            case .explore:
                ExploreView()
            case .settings:
                SettingsView()
            case nil:
                ContentUnavailableView("请选择一个页面", systemImage: "sidebar.left")
            }
        }
        .navigationTitle(selectedItem?.rawValue ?? "")
    }
}

// MARK: - 子页面占位视图

struct HomeView: View {
    var body: some View {
        ContentUnavailableView {
            Label("主页", systemImage: "house")
        } description: {
            Text("这里是主页内容区域")
        }
    }
}

struct ExploreView: View {
    var body: some View {
        ContentUnavailableView {
            Label("探索", systemImage: "safari")
        } description: {
            Text("这里是探索内容区域")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("设置", systemImage: "gear")
        } description: {
            Text("这里是设置内容区域")
        }
    }
}
