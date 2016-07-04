//
//  MainMenu.swift
//  SpriteKitIntro
//
//  Created by Dave Vo on 7/4/16.
//  Copyright © 2016 DaveVo. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .AspectFill
        let transition: SKTransition = SKTransition.crossFadeWithDuration(0.5)
        
        self.view?.presentScene(game, transition: transition)
    }
}
