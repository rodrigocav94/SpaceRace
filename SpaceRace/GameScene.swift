//
//  GameScene.swift
//  SpaceRace
//
//  Created by Rodrigo Cavalcanti on 09/06/24.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1180, y: 410)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 410)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) // Create a physics body based on the texture and size.
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        if isGameOver { gameTimer?.invalidate() }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...784))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1 // Collision tag.
        
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0) // Velocity going from right to left.
        sprite.physicsBody?.angularVelocity = 5 // Rotation/Spinning Velocity.
        sprite.physicsBody?.linearDamping = 0 // Movement will not slow down over time.
        sprite.physicsBody?.angularDamping = 0 // Rotation will not slow down over time.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        // Clamping vertical position
        if location.y < 100 {
            location.y = 100
        } else if location.y > 720 {
            location.y = 720
        }
        
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        let delay = SKAction.wait(forDuration: 0.5)
        let removeExplosionNode = SKAction.run { [unowned explosion] in
            explosion.removeFromParent()
        }
        player.removeFromParent()
        explosion.run(SKAction.sequence([delay, removeExplosionNode]))
        
        isGameOver = true
    }
}
