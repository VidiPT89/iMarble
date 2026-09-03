import SwiftUI
import SpriteKit

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: sceneSized(to: geometry.size), options: [.allowsTransparency])
                .background(AppTheme.groundGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                .accessibilityIdentifier("gameBoard")
                .onAppear {
                    viewModel.configureField(size: geometry.size)
                }
                .onChange(of: geometry.size) { _, newSize in
                    viewModel.layoutField(size: newSize)
                }
        }
    }

    private func sceneSized(to size: CGSize) -> MarbleScene {
        viewModel.scene
    }
}
