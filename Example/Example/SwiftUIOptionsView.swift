import SwiftUI

/// A form that edits a ``SwipeMenuSettings`` through a binding, so the menu behind
/// the sheet updates live — the SwiftUI counterpart of ``OptionsViewController``.
///
/// The rows mirror the UIKit form: the tab-width controls appear only while the
/// flexible style is active (the segmented style always fills the width), and
/// **Reset** restores the defaults.
struct SwiftUIOptionsView: View {

    @Binding var settings: SwipeMenuSettings

    @Environment(\.dismiss) private var dismiss

    /// Routes style changes through ``SwipeMenuSettings/setStyle(_:)`` so the page
    /// count is re-clamped to the new style's limit.
    private var style: Binding<SwipeMenuSettings.Style> {
        Binding(
            get: { settings.style },
            set: { settings.setStyle($0) })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $settings.pageCount, in: SwipeMenuSettings.minimumPageCount...settings.maximumPageCount) {
                        LabeledContent("Pages", value: "\(settings.pageCount)")
                    }
                }

                Section {
                    Picker("Style", selection: style) {
                        Text("Flexible").tag(SwipeMenuSettings.Style.flexible)
                        Text("Segmented").tag(SwipeMenuSettings.Style.segmented)
                    }
                    .pickerStyle(.segmented)

                    Picker("Tab decoration", selection: $settings.tabDecoration) {
                        Text("Underline").tag(SwipeMenuSettings.TabDecoration.underline)
                        Text("Circle").tag(SwipeMenuSettings.TabDecoration.circle)
                        Text("None").tag(SwipeMenuSettings.TabDecoration.none)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Tab bar")
                }

                Section {
                    if settings.style == .flexible {
                        Toggle("Adjust tab width to fit", isOn: $settings.adjustsItemWidthToFit)

                        if !settings.adjustsItemWidthToFit {
                            LabeledContent("Tab width", value: Self.format(settings.itemWidth))
                            Slider(value: $settings.itemWidth, in: 80...300)
                        }
                    }

                    LabeledContent("Tab margin", value: Self.format(settings.tabMargin))
                    Slider(value: $settings.tabMargin, in: 0...20)
                } header: {
                    Text("Layout")
                }

                Section {
                    Toggle("Swipe between pages", isOn: $settings.isContentScrollEnabled)
                }
            }
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") { settings = SwipeMenuSettings() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private static func format(_ value: CGFloat) -> String {
        String(format: "%.0f", Double(value))
    }
}

#Preview {
    @Previewable @State var settings = SwipeMenuSettings()
    SwiftUIOptionsView(settings: $settings)
}
