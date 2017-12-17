//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import QuNotesUI

let controller = NoteViewController { (event) in
    print(event)
}

let navigationController = UINavigationController(rootViewController: controller)
ThemeManager.applyTheme(forView: navigationController.view)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: navigationController)

let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame

controller.perform(effect: .updateTitle(title: "Title"))
controller.perform(effect: .addTag(tag: "first tag"))
controller.perform(effect: .addTag(tag: "second tag"))
