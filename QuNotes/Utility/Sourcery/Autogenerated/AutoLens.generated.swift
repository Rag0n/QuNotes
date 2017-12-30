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
        static let title = Lens<Note.Model, String>(
            get: { $0.title },
            set: { title, model in
                Note.Model(title: title, tags: model.tags, content: model.content, isNew: model.isNew)
            }
        )
        static let tags = Lens<Note.Model, [String]>(
            get: { $0.tags },
            set: { tags, model in
                Note.Model(title: model.title, tags: tags, content: model.content, isNew: model.isNew)
            }
        )
        static let content = Lens<Note.Model, String>(
            get: { $0.content },
            set: { content, model in
                Note.Model(title: model.title, tags: model.tags, content: content, isNew: model.isNew)
            }
        )
        static let isNew = Lens<Note.Model, Bool>(
            get: { $0.isNew },
            set: { isNew, model in
                Note.Model(title: model.title, tags: model.tags, content: model.content, isNew: isNew)
            }
        )
    }
}
extension Notebook.Model {
    enum lens {
        static let notebook = Lens<Notebook.Model, Core.Notebook.Meta>(
            get: { $0.notebook },
            set: { notebook, model in
                Notebook.Model(notebook: notebook, notes: model.notes, filter: model.filter)
            }
        )
        static let notes = Lens<Notebook.Model, [Core.Note.Meta]>(
            get: { $0.notes },
            set: { notes, model in
                Notebook.Model(notebook: model.notebook, notes: notes, filter: model.filter)
            }
        )
        static let filter = Lens<Notebook.Model, String>(
            get: { $0.filter },
            set: { filter, model in
                Notebook.Model(notebook: model.notebook, notes: model.notes, filter: filter)
            }
        )
    }
}

// MARK: - Lens composition
