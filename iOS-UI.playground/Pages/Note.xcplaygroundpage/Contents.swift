import UIKit
import PlaygroundSupport
import QuNotesUI

AppEnvironment.push(environment: Environment(language: .en))
let controller = NoteViewController { (event) in print(event) }
let navigationController = UINavigationController(rootViewController: controller)
ThemeExecuter.applyTheme(forView: navigationController.view)

let (parent, _) = playgroundControllers(device: .phone4inch,
                                        orientation: .portrait,
                                        child: navigationController)

let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame

controller.perform(effect: .updateTitle("Title"))
controller.perform(effect: .addTag("first tag"))
controller.perform(effect: .addTag("second tag"))
controller.perform(effect: .updateCells(["cell1", "cell2"]))

delay(for: .seconds(1)) {
    controller.perform(effect: .addCell(index: 1, cells: ["cell1", "cell3", "cell2"]))
}

delay(for: .seconds(2)) {
    controller.perform(effect: .removeCell(index: 1, cells: ["cell1", "cell2"]))
}
