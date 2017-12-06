// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

// MARK: - Lens
extension Library.Model {
    enum lens {
        static let notebooks = Lens<Library.Model, [Notebook.Model]>(
            get: { $0.notebooks },
            set: { notebooks, model in
                Library.Model(notebooks: notebooks)
            }
        )
    }
}
extension Note.Meta {
    enum lens {
        static let uuid = Lens<Note.Meta, String>(
            get: { $0.uuid },
            set: { uuid, meta in
                Note.Meta(uuid: uuid, title: meta.title, tags: meta.tags, updated_at: meta.updated_at, created_at: meta.created_at)
            }
        )
        static let title = Lens<Note.Meta, String>(
            get: { $0.title },
            set: { title, meta in
                Note.Meta(uuid: meta.uuid, title: title, tags: meta.tags, updated_at: meta.updated_at, created_at: meta.created_at)
            }
        )
        static let tags = Lens<Note.Meta, [String]>(
            get: { $0.tags },
            set: { tags, meta in
                Note.Meta(uuid: meta.uuid, title: meta.title, tags: tags, updated_at: meta.updated_at, created_at: meta.created_at)
            }
        )
        static let updated_at = Lens<Note.Meta, TimeInterval>(
            get: { $0.updated_at },
            set: { updated_at, meta in
                Note.Meta(uuid: meta.uuid, title: meta.title, tags: meta.tags, updated_at: updated_at, created_at: meta.created_at)
            }
        )
        static let created_at = Lens<Note.Meta, TimeInterval>(
            get: { $0.created_at },
            set: { created_at, meta in
                Note.Meta(uuid: meta.uuid, title: meta.title, tags: meta.tags, updated_at: meta.updated_at, created_at: created_at)
            }
        )
    }
}
extension Note.Model {
    enum lens {
        static let meta = Lens<Note.Model, Note.Meta>(
            get: { $0.meta },
            set: { meta, model in
                Note.Model(meta: meta, content: model.content, notebook: model.notebook)
            }
        )
        static let content = Lens<Note.Model, String>(
            get: { $0.content },
            set: { content, model in
                Note.Model(meta: model.meta, content: content, notebook: model.notebook)
            }
        )
        static let notebook = Lens<Note.Model, Notebook.Meta>(
            get: { $0.notebook },
            set: { notebook, model in
                Note.Model(meta: model.meta, content: model.content, notebook: notebook)
            }
        )
    }
}
extension Notebook.Meta {
    enum lens {
        static let uuid = Lens<Notebook.Meta, String>(
            get: { $0.uuid },
            set: { uuid, meta in
                Notebook.Meta(uuid: uuid, name: meta.name)
            }
        )
        static let name = Lens<Notebook.Meta, String>(
            get: { $0.name },
            set: { name, meta in
                Notebook.Meta(uuid: meta.uuid, name: name)
            }
        )
    }
}
extension Notebook.Model {
    enum lens {
        static let meta = Lens<Notebook.Model, Notebook.Meta>(
            get: { $0.meta },
            set: { meta, model in
                Notebook.Model(meta: meta, notes: model.notes)
            }
        )
        static let notes = Lens<Notebook.Model, [Note.Model]>(
            get: { $0.notes },
            set: { notes, model in
                Notebook.Model(meta: model.meta, notes: notes)
            }
        )
    }
}
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
extension Lens where Whole == Note.Model, Part == Note.Meta {
    var uuid: Lens<Note.Model, String> {
        return Note.Model.lens.meta..Note.Meta.lens.uuid
    }
    var title: Lens<Note.Model, String> {
        return Note.Model.lens.meta..Note.Meta.lens.title
    }
    var tags: Lens<Note.Model, [String]> {
        return Note.Model.lens.meta..Note.Meta.lens.tags
    }
    var updated_at: Lens<Note.Model, TimeInterval> {
        return Note.Model.lens.meta..Note.Meta.lens.updated_at
    }
    var created_at: Lens<Note.Model, TimeInterval> {
        return Note.Model.lens.meta..Note.Meta.lens.created_at
    }
}
extension Lens where Whole == Note.Model, Part == Notebook.Meta {
    var uuid: Lens<Note.Model, String> {
        return Note.Model.lens.notebook..Notebook.Meta.lens.uuid
    }
    var name: Lens<Note.Model, String> {
        return Note.Model.lens.notebook..Notebook.Meta.lens.name
    }
}
extension Lens where Whole == Notebook.Model, Part == Notebook.Meta {
    var uuid: Lens<Notebook.Model, String> {
        return Notebook.Model.lens.meta..Notebook.Meta.lens.uuid
    }
    var name: Lens<Notebook.Model, String> {
        return Notebook.Model.lens.meta..Notebook.Meta.lens.name
    }
}
extension Lens where Whole == UI.Notebook.Model, Part == Notebook.Meta {
    var uuid: Lens<UI.Notebook.Model, String> {
        return UI.Notebook.Model.lens.notebook..Notebook.Meta.lens.uuid
    }
    var name: Lens<UI.Notebook.Model, String> {
        return UI.Notebook.Model.lens.notebook..Notebook.Meta.lens.name
    }
}
