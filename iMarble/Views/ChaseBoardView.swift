import SwiftUI
import SpriteKit

struct ChaseBoardView: View {
    @ObservedObject var viewModel: ChaseGameViewModel

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .background(AppTheme.groundGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                .accessibilityIdentifier("chaseBoard")
                .onAppear {
                    viewModel.configureField(size: geometry.size)
                }
        }
    }
}
