import SwiftUI
import SpriteKit

struct MoundBoardView: View {
    @ObservedObject var viewModel: MoundGameViewModel

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .background(AppTheme.groundGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                .accessibilityIdentifier("moundBoard")
                .onAppear {
                    viewModel.configureField(size: geometry.size)
                }
        }
    }
}
