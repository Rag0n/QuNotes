// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Prelude
import Core

// MARK: - Lens
extension UI.Library.Model {
    enum lens {
        static let notebooks = Lens<UI.Library.Model, [Notebook.Meta]>(
            get: { $0.notebooks },
            set: { notebooks, model in
                UI.Library.Model(notebooks: notebooks)
            }
        )
    }
}
extension UI.Note.Model {
    enum lens {
        static let meta = Lens<UI.Note.Model, Note.Meta>(
            get: { $0.meta },
            set: { meta, model in
                UI.Note.Model(meta: meta, content: model.content, isNew: model.isNew)
            }
        )
        static let content = Lens<UI.Note.Model, String>(
            get: { $0.content },
            set: { content, model in
                UI.Note.Model(meta: model.meta, content: content, isNew: model.isNew)
            }
        )
        static let isNew = Lens<UI.Note.Model, Bool>(
            get: { $0.isNew },
            set: { isNew, model in
                UI.Note.Model(meta: model.meta, content: model.content, isNew: isNew)
            }
        )
    }
}
extension UI.Notebook.Model {
    enum lens {
        static let notebook = Lens<UI.Notebook.Model, Notebook.Meta>(
            get: { $0.notebook },
            set: { notebook, model in
                UI.Notebook.Model(notebook: notebook, notes: model.notes)
            }
        )
        static let notes = Lens<UI.Notebook.Model, [Note.Meta]>(
            get: { $0.notes },
            set: { notes, model in
                UI.Notebook.Model(notebook: model.notebook, notes: notes)
            }
        )
    }
}

// MARK: - Lens composition
