//
//  ItemExampleView.swift
//  AdaptivePanelExample
//  
//  Created by Masato Takimoto on 2026/05/26.
//  
//

import SwiftUI
import AdaptivePanel

struct ItemList: Identifiable {
    let id: UUID
    var items: [String]

    init(items: [String], id: UUID = UUID()) {
        self.id = id
        self.items = items
    }

    func removing(at indexSet: IndexSet) -> ItemList? {
        var updated = items
        updated.remove(atOffsets: indexSet)
        return updated.isEmpty ? nil : ItemList(items: updated, id: id)
    }
}


struct ItemExampleView: View {
    @State private var selectedItems: ItemList? = nil
    @State private var nativeSelectedItems: ItemList? = nil
    @State private var interactiveDismissDisabled: Bool = false


    var body: some View {
        NavigationStack {
            VStack{
                List {
                    Toggle("Dismiss Disabled", isOn: $interactiveDismissDisabled)
                }
                Spacer()
                Button { nativeSelectedItems = ItemList(items: ["Apple", "Banana"]) } label: {
                    Label("Native Sheet", systemImage: "gearshape.fill")
                        .frame(maxWidth: .infinity)
                        .padding(7)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 30)

                Button { selectedItems = ItemList(items: ["Apple", "Banana"]) } label: {
                    Label("Custom Panel", systemImage: "shippingbox.fill")
                        .frame(maxWidth: .infinity)
                        .padding(7)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 30)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Item")
            }
        }
        .sheet(item: $nativeSelectedItems) { itemList in
            List {
                ForEach(itemList.items, id: \.self) { item in
                    Text(item)
                }
                .onDelete { indexSet in
                    nativeSelectedItems = nativeSelectedItems?.removing(at: indexSet)
                }
            }
            .safeAreaInset(edge: .top) {
                Text("Delete all items to dismiss the panel")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .
                padding(.top, 24)
            }
            .interactiveDismissDisabled(interactiveDismissDisabled)
            .presentationDetents([.medium, .large])
        }
        .panel(item: $selectedItems) { itemList in
            List {
                ForEach(itemList.items, id: \.self) { item in
                    Text(item)
                }
                .onDelete { indexSet in
                    selectedItems = selectedItems?.removing(at: indexSet)
                }
            }
            .safeAreaInset(edge: .top) {
                Text("Delete all items to dismiss the panel")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)
            }
            .panelDetents([.medium, .large])
            .panelInteractiveDismissDisabled(interactiveDismissDisabled)
        }
    }
}

#Preview {
    ItemExampleView()
}
