//
//  MainMenu.swift
//  SpaceShip
//
//  Created by Андрей Антонов on 15.02.2021.
//  Copyright © 2021 Андрей Антонов. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    var Starfield: SKEmitterNode!
    
    var NewGameNode: SKSpriteNode!
    var LevelNode: SKSpriteNode!
    var LabelLevelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
        Starfield = self.childNode(withName: "Starfield_animation") as? SKEmitterNode
        Starfield.advanceSimulationTime(10)
        
        NewGameNode = self.childNode(withName: "newGame") as? SKSpriteNode
        LevelNode = self.childNode(withName: "Level") as? SKSpriteNode
        LabelLevelNode = self.childNode(withName: "LabelLevel") as? SKLabelNode
        
        let userLevel = UserDefaults.standard
        
        if userLevel.bool(forKey: "hard") {
            LabelLevelNode.text = "Сложный"
        }
        else {
             LabelLevelNode.text = "Легкий"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGame" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if nodesArray.first?.name == "Level" {
                changeLevel()
            }
        }
    }
    
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if LabelLevelNode.text == "Легкий" {
            LabelLevelNode.text = "Сложный"
            userLevel.set(true, forKey: "hard")
        }
        else {
            LabelLevelNode.text = "Легкий"
            userLevel.set(false, forKey: "hard")
        }
        
        userLevel.synchronize()
    }

}
