//
//  DetentExampleView.swift
//  AdaptivePanelExample
//  
//  Created by Masato Takimoto on 2026/05/26.
//  
//
import SwiftUI
import AdaptivePanel

struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.1)
    }
}

struct FooDetent: CustomPanelDetent {
    static func height(in context: PanelDetent.Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.1)
    }
}

enum BackgroundOption: String, CaseIterable, Identifiable {
    case none = "Default"
    case thinMaterial = "Thin Material"
    case ultraThinMaterial = "Ultra Thin"
    case blue = "System Blue"
    case customGradient = "Gradient"

    var id: String { rawValue }
    var label: String { rawValue }

   
    var style: AnyShapeStyle {
        switch self {
        case .none:
            return AnyShapeStyle(Color(uiColor: .systemBackground))
        case .thinMaterial:
            return AnyShapeStyle(.thinMaterial)
        case .ultraThinMaterial:
            return AnyShapeStyle(.ultraThinMaterial)
        case .blue:
            return AnyShapeStyle(Color.blue.opacity(0.8))
        case .customGradient:
            return AnyShapeStyle(LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .top,
                    endPoint: .bottom
                ))
        }
    }
    
    var nativeStyle: any ShapeStyle {
        switch self {
        case .none:
            return Color(uiColor: .systemBackground)
        case .thinMaterial:
            return .thinMaterial
        case .ultraThinMaterial:
            return .ultraThinMaterial
        case .blue:
            return Color.blue.opacity(0.8)
        case .customGradient:
            return LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .top,
                    endPoint: .bottom
                )
        }
    }
}

enum InteractionChoice: String, CaseIterable, Identifiable {
    case disabled = "Disabled"
    case upThrough = "Enabled: <=.medium"
    case enabled = "Enabled"
    
    var id: String { self.rawValue }
    
    // この選択肢をライブラリの型に変換する
    var toPanelInteraction: PanelBackgroundInteraction {
        switch self {
        case .disabled: return .disabled
        case .enabled: return .enabled
        case .upThrough: return .enabled(upThrough: .medium)
        }
    }
    
    var toSheetInteraction: PresentationBackgroundInteraction {
        switch self {
        case .disabled: return .disabled
        case .enabled: return .enabled
        case .upThrough: return .enabled(upThrough: .medium)
        }
    }
}

enum LandscapeWidth: String, CaseIterable, Identifiable, Hashable {
    case maxFraction = "Fraction (1.0)"
    case fraction = "Fraction (0.6)"
    case width = "width (200pt)"
    case compact = "Compact"
    case full = "Full"
    
    var id: String { self.rawValue }

    var width: PanelLandscapeWidth {
        switch self {
        case .maxFraction: return .fraction(1.0)
        case .fraction: return .fraction(0.6)
        case .width:    return .width(200)
        case .compact:  return .compact
        case .full:     return .full
        }
    }
}

enum DetentType: String, CaseIterable, Identifiable, Hashable {
    case custom = "Custom"
    case maxFraction = "Fraction (1.0)"
    case fraction = "Fraction (0.7)"
    case height = "Height (130pt)"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { self.rawValue }
}

// 独自の拡張で変換ロジックを分離 (前回の理想の設計)
extension DetentType {
    // ネイティブ SwiftUI 用
    var toSheet: PresentationDetent {
        switch self {
        case .maxFraction: return .fraction(1.0)
        case .fraction: return .fraction(0.7)
        case .height:   return .height(130)
        case .medium:   return .medium
        case .large:    return .large
        case .custom: return .custom(BarDetent.self)
        }
    }
    
    // AdaptivePanel 用
    var toPanel: PanelDetent {
        switch self {
        case .maxFraction: return .fraction(1.0)
        case .fraction: return .fraction(0.7)
        case .height:   return .height(130)
        case .medium:   return .medium
        case .large:    return .large
        case .custom: return .custom(FooDetent.self)
        }
    }
}

extension Collection where Element == DetentType {
    /// ネイティブのシート用に Set<PresentationDetent> へ変換
    var toSheetSet: Set<PresentationDetent> {
        Set(self.map { $0.toSheet })
    }
    
    /// AdaptivePanel用に [PanelDetent] へ変換
    var toPanelSet: Set<PanelDetent> {
        Set(self.map { $0.toPanel} )
    }
}

struct DetentExampleView: View {
    @State private var withScroll = false
    @State private var useScroll = false
    @State private var selectedDetents: Set<DetentType> = [.medium, .large]
    @State private var dragIndicator:Visibility = .automatic
    @State private var backgroundInteraction: InteractionChoice = .disabled
    @State private var landmarkAlignment: PanelLandscapeAlignment = .center
    @State private var landmarkWidth: PanelLandscapeWidth = .full
    @State private var landmarkIgnoreSafearea: Bool = false
    @State private var selectedBackground: BackgroundOption = .none
    @State private var interactiveDismissDisabled: Bool = false
    @State private var radius: CGFloat = 30.0
    @State private var present: Bool = false
    @State private var showPanel = false
    @State private var count = 50
    @State private var backdropClear = false

    var body: some View {
        NavigationStack {
            List {
                Section("Detents") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(DetentType.allCases) { type in
                            Toggle(
                                isOn: Binding(
                                    get: {
                                        selectedDetents.contains(type)
                                    },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedDetents.insert(type)
                                        } else if selectedDetents.count > 1 {
                                            selectedDetents.remove(type)
                                        }
                                    }
                                )
                            ) {
                                Text(type.rawValue)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                
                Section("Drag Indicaor") {
                    Picker("Visibility", selection: $dragIndicator) {
                        Text("Automatic").tag(Visibility.automatic)
                        Text("Visible").tag(Visibility.visible)
                        Text("Hidden").tag(Visibility.hidden)
                    }
                    .pickerStyle(.menu)
                }
                Section("Background Interaction") {
                    Picker("BackgroundInteraction", selection: $backgroundInteraction) {
                        ForEach(InteractionChoice.allCases) {type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Toggle("Dismiss Disabled", isOn: $interactiveDismissDisabled)
                
                Toggle("Scroll on", isOn: $withScroll)
                if withScroll {
                    Toggle("Interaction: scrolls", isOn: $useScroll)
                }
                
                Section("Background") {
                    Picker("Style", selection: $selectedBackground) {
                        ForEach(BackgroundOption.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    Toggle("BackdropColor(.clear)", isOn: $backdropClear)
                }
                
                Section("Corner Radius") {
                    Text("Radius: \(Int(radius))") // ここに数字が出る
                    Slider(value: $radius, in: 0...100, step: 1)
                }
                
                Section("Landscape Mode") {
                    Picker("Alignment", selection: $landmarkAlignment) {
                        Text("Leading").tag(PanelLandscapeAlignment.leading(spacing: 0))
                        Text("Leading(spacing: 10)").tag(PanelLandscapeAlignment.leading(spacing: 10))
                        Text("Center").tag(PanelLandscapeAlignment.center)
                        Text("Trailing").tag(PanelLandscapeAlignment.trailing(spacing: 0))
                        Text("Trailing(spacing: 10)").tag(PanelLandscapeAlignment.trailing(spacing: 10))
                    }
                    .pickerStyle(.menu)
                    Picker("Width", selection: $landmarkWidth) {
                        ForEach(LandscapeWidth.allCases) { type in
                            Text(type.rawValue).tag(type.width)
                        }
                    }
                    .pickerStyle(.menu)
                    Toggle("Ignore Safearea", isOn: $landmarkIgnoreSafearea)

                }
            }

            Button { present = true } label: {
                Label("Native Sheet", systemImage: "gearshape.fill")
                    .frame(maxWidth: .infinity)
                    .padding(7)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 30)
            
            Button { showPanel = true } label: {
                Label("Custom Panel", systemImage: "shippingbox.fill")
                    .frame(maxWidth: .infinity)
                    .padding(7)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Basic")
        }
        .sheet(isPresented: $present) {
            if withScroll {
                ScrollsView(count: $count)
                    .presentationContentInteraction(useScroll ? .scrolls : .resizes)
                    .presentationDetents(selectedDetents.toSheetSet)
                    .presentationBackgroundInteraction(backgroundInteraction.toSheetInteraction)
                    .presentationDragIndicator(dragIndicator)
                    .interactiveDismissDisabled(interactiveDismissDisabled)
                    .presentationBackground(selectedBackground.style)
                    .presentationCornerRadius(radius)

            } else {
                BasicView(present: $present)
                    .presentationDetents(selectedDetents.toSheetSet)
                    .presentationBackgroundInteraction(backgroundInteraction.toSheetInteraction)
                    .presentationDragIndicator(dragIndicator)
                    .interactiveDismissDisabled(interactiveDismissDisabled)
                    .presentationBackground(selectedBackground.style)
                    .presentationCornerRadius(radius)
            }
        }
        .panel(isPresented: $showPanel) {
            if withScroll {
                ScrollsView(count: $count)
                    .panelContentInteraction(useScroll ? .scrolls : .resizing)
                    .panelDetents(selectedDetents.toPanelSet)
                    .panelBackgroundInteraction(backgroundInteraction.toPanelInteraction)
                    .panelDragIndicator(dragIndicator)
                    .panelBackgroundInteraction(backgroundInteraction.toPanelInteraction)
                    .panelInteractiveDismissDisabled(interactiveDismissDisabled)
                    .panelBackground(selectedBackground.style, backdropColor: backdropClear ? .clear : nil)
                    .panelCornerRadius(radius)
                    .panelLandscapeLayout(landmarkAlignment, width: landmarkWidth, ignoreSafeArea: landmarkIgnoreSafearea)
                    .id(selectedDetents)
            } else {
                BasicView(present: $showPanel)
                    .panelDetents(selectedDetents.toPanelSet)
                    .panelBackgroundInteraction(backgroundInteraction.toPanelInteraction)
                    .panelDragIndicator(dragIndicator)
                    .panelInteractiveDismissDisabled(interactiveDismissDisabled)
                    .panelBackground(selectedBackground.style, backdropColor: backdropClear ? .clear : nil)
                    .panelCornerRadius(radius)
                    .panelLandscapeLayout(landmarkAlignment, width: landmarkWidth, ignoreSafeArea: landmarkIgnoreSafearea)
                    .id(selectedDetents)
            }
        }
    }

}

struct BasicView: View {
    @Binding var present: Bool
    @State var username: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text("Panel Content")
                    .font(.headline)
                
                // 現在のサイズをリアルタイム表示
                VStack(alignment: .leading, spacing: 10) {
                    Text("Total Height: \(Int(geometry.size.height)) pt")
                        .bold()
                        .foregroundColor(.blue)
                    
                    Text("Global Y: \(Int(geometry.frame(in: .global).minY)) pt")
                        .font(.caption)
                    
                    TextField(
                        "User name (email address)",
                        text: $username
                    )
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)

                Button("Close") {
                    present = false
                    isFocused = false
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .onTapGesture {
            isFocused = false // 👈 外側をタップしたら外す
        }
    }
}

struct ScrollsView: View {
    @Binding var count: Int
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<count, id: \.self) { i in
                        Text("Item \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<count, id: \.self) { i in
                        Text("Item \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
}

#Preview {
    DetentExampleView()
}
