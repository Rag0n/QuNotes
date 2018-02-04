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

let firstNote = Notebook.NoteViewModel(title: "First note", tags: "tag, second tag")
let secondNote = Notebook.NoteViewModel(title: "Second note", tags: "tag, second tag")
let thirdNote = Notebook.NoteViewModel(title: "Third note with a long long long long long title",
                                       tags: "tag, second tag, really long long long long long long tag")
controller.perform(effect: .updateAllNotes([firstNote, secondNote, thirdNote]))
controller.perform(effect: .updateTitle("Notebook title"))
