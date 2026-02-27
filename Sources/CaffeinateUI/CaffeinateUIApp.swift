import SwiftUI

@main
struct CaffeinateUIApp: App {
    @State private var viewModel = CaffeinateViewModel()

    var body: some Scene {
        MenuBarExtra {
            CaffeinatePanel(viewModel: viewModel)
        } label: {
            Image(systemName: viewModel.iconName)
        }
        .menuBarExtraStyle(.window)
    }
}
