import UIKit
import QuNotesUI

// This needs to be called manually in playgrounds.
public func initialize(withController controller: UIViewController) {
    ThemeExecuter.applyTheme(forView: controller.view)
}
