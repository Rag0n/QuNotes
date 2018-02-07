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

//delay(for: .seconds(1)) {
//    controller.perform(effect: .addCell(index: 1, cells: ["cell1", "cell3", "cell2"]))
//}
//
//delay(for: .seconds(2)) {
//    controller.perform(effect: .removeCell(index: 1, cells: ["cell1", "cell2"]))
//}
//
//delay(for: .seconds(3)) {
//    let cell1 = """
//        Lorem Ipsum - это текст-рыба, часто используемый в печати и вэб-дизайне. Lorem Ipsum является стандартной рыбой для текстов на латинице с начала XVI века. В то время некий безымянный печатник создал большую коллекцию размеров и форм шрифтов, используя Lorem Ipsum для распечатки образцов. Lorem Ipsum не только успешно пережил без заметных изменений пять веков, но и перешагнул в электронный дизайн. Его популяризации в новое время послужили публикация листов Letraset с образцами Lorem Ipsum в 60-х годах и, в более недавнее время, программы электронной вёрстки типа Aldus PageMaker, в шаблонах которых используется Lorem Ipsum.
//    """
//    controller.perform(effect: .updateCell(index: 0, cells: [cell1, "cell2"]))
//}
//
//delay(for: .seconds(4)) {
//    controller.perform(effect: .updateCell(index: 0, cells: ["cell1", "cell2"]))
//}

