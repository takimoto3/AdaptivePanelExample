//
//  BackgroundContentExampleView.swift
//  AdaptivePanelExample
//
//  Created by Masato Takimoto on 2026/06/10.
//

import SwiftUI
import AdaptivePanel

enum BackgroundAlignment: String, CaseIterable, Identifiable {
    case center      = "center"
    case top         = "top"
    case bottom      = "bottom"
    case leading     = "leading"
    case trailing    = "trailing"
    case topLeading  = "topLeading"
    case topTrailing = "topTrailing"

    var id: String { rawValue }

    var alignment: Alignment {
        switch self {
        case .center:      .center
        case .top:         .top
        case .bottom:      .bottom
        case .leading:     .leading
        case .trailing:    .trailing
        case .topLeading:  .topLeading
        case .topTrailing: .topTrailing
        }
    }
}

struct BackgroundContentExampleView: View {
    @State private var isPresented = false
    @State private var nativeIsPresented = false
    @State private var selectedAlignment: BackgroundAlignment = .center

    var body: some View {
        NavigationStack {
            List {
                Section("Alignment") {
                    ForEach(BackgroundAlignment.allCases) { option in
                        Button {
                            selectedAlignment = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedAlignment == option {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }

            Button {
                nativeIsPresented = true
            } label: {
                Label("Native Sheet", systemImage: "gearshape.fill")
                    .frame(maxWidth: .infinity)
                    .padding(7)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 30)

            Button {
                isPresented = true
            } label: {
                Label("Custom Panel", systemImage: "shippingbox.fill")
                    .frame(maxWidth: .infinity)
                    .padding(7)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Background Content")
        }
        .sheet(isPresented: $nativeIsPresented) {
            BackgroundContentSheet()
                .presentationBackground(.clear)
                .presentationBackground(alignment: selectedAlignment.alignment) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 300, height: 300)
                }

        }
        .panel(isPresented: $isPresented) {
            BackgroundContentSheet()
                .panelBackground(alignment: selectedAlignment.alignment) {
                    Color(.systemBackground)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 300, height: 300)

                }
        }
    }
}

private struct BackgroundContentSheet: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Background")
                .font(.headline)
                .padding(.top, 24)

            Text("Background is a circle positioned by the selected alignment.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BackgroundContentExampleView()
}
