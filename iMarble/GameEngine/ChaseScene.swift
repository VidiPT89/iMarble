import SpriteKit
import UIKit

protocol ChaseSceneDelegate: AnyObject {
    func chaseScene(_ scene: ChaseScene, canLaunch id: UUID) -> Bool
    func chaseScene(_ scene: ChaseScene, didLaunch id: UUID, dragVector: CGVector)
    func chaseScene(_ scene: ChaseScene, didUpdatePower ratio: Double)
    func chaseSceneShotSettled(_ scene: ChaseScene)
}

final class ChaseScene: SKScene {
    weak var chaseDelegate: ChaseSceneDelegate?
    var reduceMotion = false

    private var marbleNodes: [UUID: MarbleNode] = [:]
    private var draggingID: UUID?
    private var dragStart: CGPoint = .zero
    private var dragOrigin: CGPoint = .zero
    private var anyMoving = false
    private var wasMoving = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.16, green: 0.10, blue: 0.05, alpha: 1.0)
        isUserInteractionEnabled = true
    }

    func layoutField(sceneSize: CGSize) {
        size = sceneSize
    }

    func addMarble(id: UUID, position: CGPoint, color: SKColor, readyToLaunch: Bool) {
        let node = MarbleNode(marbleID: id, radius: CGFloat(GameRules.marbleRadius), color: color)
        node.position = position
        node.isReadyToLaunch = readyToLaunch
        node.configureMotion(reduceMotion: reduceMotion)
        addChild(node)
        marbleNodes[id] = node
    }

    func setReadyToLaunch(_ id: UUID) {
        for (nodeID, node) in marbleNodes {
            node.isReadyToLaunch = nodeID == id
        }
    }

    func removeMarble(_ id: UUID) {
        marbleNodes[id]?.removeFromParent()
        marbleNodes.removeValue(forKey: id)
    }

    func position(of id: UUID) -> CGPoint? {
        marbleNodes[id]?.position
    }

    func removeAllMarbles() {
        for node in marbleNodes.values { node.removeFromParent() }
        marbleNodes.removeAll()
    }

    func launch(id: UUID, dragVector: CGVector) {
        guard let node = marbleNodes[id] else { return }
        node.velocity = PhysicsEngine.velocity(fromDrag: dragVector, rules: GameRules.default)
        chaseDelegate?.chaseScene(self, didLaunch: id, dragVector: dragVector)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        for (id, node) in marbleNodes where node.frame.insetBy(dx: -14, dy: -14).contains(point) {
            guard chaseDelegate?.chaseScene(self, canLaunch: id) == true else { continue }
            draggingID = id
            dragStart = point
            dragOrigin = node.position
            break
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let id = draggingID, let node = marbleNodes[id] else { return }
        let point = touch.location(in: self)
        let drag = CGVector(dx: dragStart.x - point.x, dy: dragStart.y - point.y)
        let length = sqrt(drag.dx * drag.dx + drag.dy * drag.dy)
        let ratio = min(length / CGFloat(GameRules.maximumDragDistance), 1.0)
        chaseDelegate?.chaseScene(self, didUpdatePower: Double(ratio))
        guard length > 0 else { return }
        let normalized = CGVector(dx: drag.dx / length, dy: drag.dy / length)
        let pullBack = min(min(length, CGFloat(GameRules.maximumDragDistance)) * 0.35, 30)
        node.position = CGPoint(
            x: dragOrigin.x - normalized.dx * pullBack,
            y: dragOrigin.y - normalized.dy * pullBack
        )
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let id = draggingID, let node = marbleNodes[id] else {
            draggingID = nil
            return
        }
        let point = touch.location(in: self)
        let drag = CGVector(dx: dragStart.x - point.x, dy: dragStart.y - point.y)
        node.position = dragOrigin
        draggingID = nil
        chaseDelegate?.chaseScene(self, didUpdatePower: 0)
        let velocity = PhysicsEngine.velocity(fromDrag: drag, rules: GameRules.default)
        guard velocity.dx != 0 || velocity.dy != 0 else { return }
        launch(id: id, dragVector: drag)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingID = nil
        chaseDelegate?.chaseScene(self, didUpdatePower: 0)
    }

    override func update(_ currentTime: TimeInterval) {
        anyMoving = false
        let bounds = CGRect(origin: .zero, size: size).insetBy(dx: 20, dy: 20)

        for (_, node) in marbleNodes {
            guard node.currentSpeed > 0 else { continue }
            node.position.x += node.velocity.dx * (1.0 / 60.0)
            node.position.y += node.velocity.dy * (1.0 / 60.0)
            node.velocity = PhysicsEngine.applyFriction(velocity: node.velocity)
            node.position = PhysicsEngine.clampPosition(node.position, in: bounds, radius: node.radius)
            if !PhysicsEngine.hasStopped(velocity: node.velocity) {
                anyMoving = true
            } else {
                node.velocity = .zero
            }
        }

        resolveCollisions()

        if wasMoving, !anyMoving {
            chaseDelegate?.chaseSceneShotSettled(self)
        }
        wasMoving = anyMoving
    }

    private func resolveCollisions() {
        let ids = Array(marbleNodes.keys)
        guard ids.count > 1 else { return }
        for i in 0..<ids.count {
            for j in (i + 1)..<ids.count {
                guard let a = marbleNodes[ids[i]], let b = marbleNodes[ids[j]] else { continue }
                let minDistance = a.radius + b.radius
                let distance = a.position.distance(to: b.position)
                guard distance < minDistance, distance > 0 else { continue }
                let overlap = (minDistance - distance) / 2
                let nx = (b.position.x - a.position.x) / distance
                let ny = (b.position.y - a.position.y) / distance
                a.position.x -= nx * overlap
                a.position.y -= ny * overlap
                b.position.x += nx * overlap
                b.position.y += ny * overlap
                let (newA, newB) = PhysicsEngine.resolveCollision(velocityA: a.velocity, velocityB: b.velocity, positionA: a.position, positionB: b.position)
                a.velocity = newA
                b.velocity = newB
            }
        }
    }
}
