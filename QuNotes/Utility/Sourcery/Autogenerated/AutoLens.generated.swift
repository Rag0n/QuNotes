// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Prelude
import Core

// MARK: - Lens
extension Library.Model {
    enum lens {
        static let notebooks = Lens<Library.Model, [Core.Notebook.Meta]>(
            get: { $0.notebooks },
            set: { notebooks, model in
                Library.Model(notebooks: notebooks)
            }
        )
    }
}
extension Note.Model {
    enum lens {
        static let meta = Lens<Note.Model, Core.Note.Meta>(
            get: { $0.meta },
            set: { meta, model in
                Note.Model(meta: meta, content: model.content, isNew: model.isNew)
            }
        )
        static let content = Lens<Note.Model, String>(
            get: { $0.content },
            set: { content, model in
                Note.Model(meta: model.meta, content: content, isNew: model.isNew)
            }
        )
        static let isNew = Lens<Note.Model, Bool>(
            get: { $0.isNew },
            set: { isNew, model in
                Note.Model(meta: model.meta, content: model.content, isNew: isNew)
            }
        )
    }
}
extension Notebook.Model {
    enum lens {
        static let notebook = Lens<Notebook.Model, Core.Notebook.Meta>(
            get: { $0.notebook },
            set: { notebook, model in
                Notebook.Model(notebook: notebook, notes: model.notes)
            }
        )
        static let notes = Lens<Notebook.Model, [Core.Note.Meta]>(
            get: { $0.notes },
            set: { notes, model in
                Notebook.Model(notebook: model.notebook, notes: notes)
            }
        )
    }
}

// MARK: - Lens composition
