import SwiftUI
import SwipeMenuViewController

/// The SwiftUI counterpart of ``MenuViewController``: the same demo pages shown
/// through the SwiftUI ``SwipeMenu``, with a floating button that presents
/// ``SwiftUIOptionsView``. Both demos edit the same ``SwipeMenuSettings`` model;
/// here every change re-renders the menu declaratively instead of calling
/// `reloadData(options:default:)`.
struct SwiftUIMenuView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var settings = SwipeMenuSettings()
    @State private var selection = 0
    @State private var isPresentingOptions = false

    private static let pageTitles = [
        "Bulbasaur", "Caterpie", "Golem", "Jynx",
        "Marshtomp", "Salamence", "Riolu", "Araquanid",
    ]

    private var titles: [String] {
        Array(Self.pageTitles.prefix(settings.pageCount))
    }

    var body: some View {
        let titles = self.titles
        SwipeMenu(selection: $selection, titles: titles, options: settings.makeSwiftUIOptions()) { index in
            Text(titles[index])
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) { floatingButtons }
        .onChange(of: settings.pageCount) { _, newCount in
            // Keep the visible page in range if the page count shrank.
            selection = min(max(selection, 0), newCount - 1)
        }
        .sheet(isPresented: $isPresentingOptions) {
            SwiftUIOptionsView(settings: $settings)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var floatingButtons: some View {
        VStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Close")

            Button {
                isPresentingOptions = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.glassProminent)
            .accessibilityLabel("Options")
        }
        .padding(16)
    }
}

#Preview {
    SwiftUIMenuView()
}
