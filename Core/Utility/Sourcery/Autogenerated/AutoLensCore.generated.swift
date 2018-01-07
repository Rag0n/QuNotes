// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Prelude

// MARK: - Lens
extension DynamicBaseURL {
    enum lens {
        static let url = Lens<DynamicBaseURL, URL>(
            get: { $0.url },
            set: { url, dynamicbaseurl in
                DynamicBaseURL(url: url)
            }
        )
    }
}
extension Library.Model {
    enum lens {
        static let notebooks = Lens<Library.Model, [Notebook.Meta]>(
            get: { $0.notebooks },
            set: { notebooks, model in
                Library.Model(notebooks: notebooks)
            }
        )
    }
}
extension Note.Cell {
    enum lens {
        static let type = Lens<Note.Cell, Note.CellType>(
            get: { $0.type },
            set: { type, cell in
                Note.Cell(type: type, data: cell.data)
            }
        )
        static let data = Lens<Note.Cell, String>(
            get: { $0.data },
            set: { data, cell in
                Note.Cell(type: cell.type, data: data)
            }
        )
    }
}
extension Note.Content {
    enum lens {
        static let title = Lens<Note.Content, String>(
            get: { $0.title },
            set: { title, content in
                Note.Content(title: title, cells: content.cells)
            }
        )
        static let cells = Lens<Note.Content, [Note.Cell]>(
            get: { $0.cells },
            set: { cells, content in
                Note.Content(title: content.title, cells: cells)
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
        static let content = Lens<Note.Model, Note.Content>(
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
        static let notes = Lens<Notebook.Model, [Note.Meta]>(
            get: { $0.notes },
            set: { notes, model in
                Notebook.Model(meta: model.meta, notes: notes)
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
extension Lens where Whole == Note.Model, Part == Note.Content {
    var title: Lens<Note.Model, String> {
        return Note.Model.lens.content..Note.Content.lens.title
    }
    var cells: Lens<Note.Model, [Note.Cell]> {
        return Note.Model.lens.content..Note.Content.lens.cells
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
