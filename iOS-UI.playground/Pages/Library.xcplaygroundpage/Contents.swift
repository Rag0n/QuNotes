import UIKit
import PlaygroundSupport
import QuNotesUI

let useEnglishLanguage = true
let language: Language = useEnglishLanguage ? .en : .ru
AppEnvironment.push(environment: Environment(language: language))
let controller = LibraryViewController { (event) in print(event) }
let navigationController = UINavigationController(rootViewController: controller)
ThemeExecuter.applyTheme(forView: navigationController.view)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait,
                                        child: navigationController)

let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame

let firstNotebook = Library.NotebookViewModel(title: "First notebook title")
let secondNotebook = Library.NotebookViewModel(title: "Second notebook title")
let thirdNotebook = Library.NotebookViewModel(title: "Third notebook title")
controller.perform(effect: .updateAllNotebooks([firstNotebook, secondNotebook, thirdNotebook]))
