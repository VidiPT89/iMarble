import SpriteKit
import UIKit

protocol MoundSceneDelegate: AnyObject {
    func moundScene(_ scene: MoundScene, canLaunchShooter id: UUID) -> Bool
    func moundScene(_ scene: MoundScene, didLaunchShooter id: UUID, dragVector: CGVector)
    func moundScene(_ scene: MoundScene, didUpdatePower ratio: Double)
    func moundSceneShotSettled(_ scene: MoundScene)
}

final class MoundScene: SKScene {
    weak var moundDelegate: MoundSceneDelegate?
    var reduceMotion = false

    private var marbleNodes: [UUID: MarbleNode] = [:]
    private var circleNode: SKShapeNode?
    private var circleCenter: CGPoint = .zero
    private var circleRadius: CGFloat = 0
    private var draggingID: UUID?
    private var dragStart: CGPoint = .zero
    private var dragOrigin: CGPoint = .zero
    private var anyMoving = false
    private var wasMoving = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.16, green: 0.10, blue: 0.05, alpha: 1.0)
        isUserInteractionEnabled = true
    }

    func layoutField(sceneSize: CGSize, radius: CGFloat) {
        size = sceneSize
        circleCenter = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        circleRadius = radius

        circleNode?.removeFromParent()
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = circleCenter
        circle.strokeColor = SKColor(red: 0.95, green: 0.6, blue: 0.1, alpha: 0.9)
        circle.lineWidth = 3
        circle.fillColor = SKColor.black.withAlphaComponent(0.15)
        circle.zPosition = -1
        addChild(circle)
        circleNode = circle
    }

    func addMarble(id: UUID, position: CGPoint, color: SKColor) {
        let node = MarbleNode(marbleID: id, radius: CGFloat(GameRules.marbleRadius), color: color)
        node.position = position
        node.configureMotion(reduceMotion: reduceMotion)
        addChild(node)
        marbleNodes[id] = node
    }

    func addShooter(id: UUID, position: CGPoint, color: SKColor) {
        let node = MarbleNode(marbleID: id, radius: CGFloat(GameRules.marbleRadius) * 1.3, color: color)
        node.position = position
        node.isReadyToLaunch = true
        node.configureMotion(reduceMotion: reduceMotion)
        addChild(node)
        marbleNodes[id] = node
    }

    func removeMarble(_ id: UUID) {
        marbleNodes[id]?.removeFromParent()
        marbleNodes.removeValue(forKey: id)
    }

    func position(of id: UUID) -> CGPoint? {
        marbleNodes[id]?.position
    }

    func launchShooter(id: UUID, dragVector: CGVector) {
        guard let node = marbleNodes[id] else { return }
        node.velocity = PhysicsEngine.velocity(fromDrag: dragVector, rules: GameRules.default)
        moundDelegate?.moundScene(self, didLaunchShooter: id, dragVector: dragVector)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        for (id, node) in marbleNodes where node.frame.insetBy(dx: -14, dy: -14).contains(point) {
            guard moundDelegate?.moundScene(self, canLaunchShooter: id) == true else { continue }
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
        moundDelegate?.moundScene(self, didUpdatePower: Double(ratio))
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
        moundDelegate?.moundScene(self, didUpdatePower: 0)
        let velocity = PhysicsEngine.velocity(fromDrag: drag, rules: GameRules.default)
        guard velocity.dx != 0 || velocity.dy != 0 else { return }
        launchShooter(id: id, dragVector: drag)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingID = nil
        moundDelegate?.moundScene(self, didUpdatePower: 0)
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
            moundDelegate?.moundSceneShotSettled(self)
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
