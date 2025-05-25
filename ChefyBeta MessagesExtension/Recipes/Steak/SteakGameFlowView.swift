import SwiftUI
import Foundation

struct SteakGameFlowView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    var body: some View {
        ZStack {
            switch viewModel.currentStage {
            case .seasonSteak:
                SteakSeasoningView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .cookSteak:
                SteakCookingView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .sauteMushrooms:
                SauteMushroomsView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .rollPastry:
                PastryRollingView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .prepPastry:
                PrepPastryView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .cookWelly:
                OvenCookingView(viewModel: viewModel, messagesViewController: messagesViewController)
            case .outcome:
                GameOutcomeView(gameState: viewModel.gameState, viewModel: viewModel)
            case nil:
                SteakSeasoningView(viewModel: viewModel, messagesViewController: messagesViewController)
            }
        }
    }
}
