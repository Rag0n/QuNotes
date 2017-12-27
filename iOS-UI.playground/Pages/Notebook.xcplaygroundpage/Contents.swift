import UIKit
import PlaygroundSupport
import QuNotesUI

AppEnvironment.push(environment: Environment(language: .ru))
let controller = NotebookViewController { (event) in print(event) }
let navigationController = UINavigationController(rootViewController: controller)
ThemeExecuter.applyTheme(forView: navigationController.view)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait,
                                        child: navigationController)

let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame

controller.perform(effect: .updateAllNotes(["First note", "Second note", "Third note"]))
controller.perform(effect: .updateTitle("Notebook title"))
