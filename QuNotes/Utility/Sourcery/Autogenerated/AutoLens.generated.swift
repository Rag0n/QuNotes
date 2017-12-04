// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - Lens
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

// MARK: - Lens composition
extension Lens where Whole == Notebook.Model, Part == Notebook.Meta {
    var uuid: Lens<Notebook.Model, String> {
        return Notebook.Model.lens.meta..Notebook.Meta.lens.uuid
    }
    var name: Lens<Notebook.Model, String> {
        return Notebook.Model.lens.meta..Notebook.Meta.lens.name
    }
}
