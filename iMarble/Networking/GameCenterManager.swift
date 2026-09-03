import Combine
import Foundation
import GameKit
import UIKit

final class GameCenterManager: ObservableObject {
    enum AuthState: Equatable {
        case notAuthenticated
        case authenticating
        case authenticated
        case failed(String)
    }

    static let shared = GameCenterManager()

    @Published private(set) var authState: AuthState = .notAuthenticated

    private init() {}

    var isAuthenticated: Bool { GKLocalPlayer.local.isAuthenticated }
    var localPlayer: GKLocalPlayer { GKLocalPlayer.local }

    func authenticate() {
        guard authState != .authenticating else { return }
        authState = .authenticating

        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if let viewController {
                    self.present(viewController)
                    return
                }
                if GKLocalPlayer.local.isAuthenticated {
                    self.authState = .authenticated
                } else {
                    self.authState = .failed(error?.localizedDescription ?? "unknown")
                }
            }
        }
    }

    private func present(_ viewController: UIViewController) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow })?.rootViewController
        else { return }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        top.present(viewController, animated: true)
    }
}
