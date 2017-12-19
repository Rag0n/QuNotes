import UIKit
import PlaygroundSupport
import QuNotesUI

let controller = NotebookViewController { (event) in print(event) }
let navigationController = UINavigationController(rootViewController: controller)
initialize(withController: navigationController)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait,
                                        child: navigationController)

let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame

controller.perform(effect: .updateAllNotes(notes: ["First note", "Second note", "Third note"]))
controller.perform(effect: .updateTitle(title: "Notebook title"))
