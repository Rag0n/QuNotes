// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Prelude

// MARK: - Lens
extension CoreStruct {
    enum lens {
        static let name = Lens<CoreStruct, String>(
            get: { $0.name },
            set: { name, corestruct in
                CoreStruct(name: name, surname: corestruct.surname)
            }
        )
        static let surname = Lens<CoreStruct, String>(
            get: { $0.surname },
            set: { surname, corestruct in
                CoreStruct(name: corestruct.name, surname: surname)
            }
        )
    }
}

// MARK: - Lens composition
