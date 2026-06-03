//
//  SelectionExampleView.swift
//  AdaptivePanelExample
//  
//  Created by Masato Takimoto on 2026/05/28.
//  
//

import SwiftUI
import AdaptivePanel

struct SelectionExampleView: View {
    @State private var isPresented = false
    @State private var nativeIsPresented = false
    @State private var selectedDetent: PanelDetent = .medium
    @State private var nativeSelectedDetent: PresentationDetent = .medium

    var body: some View {
        NavigationStack {
            Spacer()

            Button {
                nativeSelectedDetent = .medium
                nativeIsPresented = true
            } label: {
                Label("Native Sheet", systemImage: "gearshape.fill")
                    .frame(maxWidth: .infinity)
                    .padding(7)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 30)

            Button {
                selectedDetent = .medium
                isPresented = true
            } label: {
                Label("Custom Panel", systemImage: "shippingbox.fill")
                    .frame(maxWidth: .infinity)
                    .padding(7)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Selection")
        }
        .sheet(isPresented: $nativeIsPresented) {
            DetentSelectionContent(
                selectedLabel: nativeSelectedDetent == .medium ? "medium" : "large",
                onMedium: { nativeSelectedDetent = .medium },
                onLarge: { nativeSelectedDetent = .large }
            )
            .presentationDetents([.medium, .large], selection: $nativeSelectedDetent)
        }
        .panel(isPresented: $isPresented) {
            DetentSelectionContent(
                selectedLabel: selectedDetent == .medium ? "medium" : "large",
                onMedium: { selectedDetent = .medium },
                onLarge: { selectedDetent = .large }
            )
            .panelDetents([.medium, .large], selection: $selectedDetent)
        }
    }
}

private struct DetentSelectionContent: View {
    let selectedLabel: String
    let onMedium: () -> Void
    let onLarge: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Selected: \(selectedLabel)")
                .font(.headline)
                .padding(.top, 24)

            Button("Switch to medium", action: onMedium)
                .buttonStyle(.bordered)

            Button("Switch to large", action: onLarge)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SelectionExampleView()
}
