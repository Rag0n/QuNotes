//
// Created by Alexander Guschin on 28.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

struct AppDependency: HasNoteUseCase, HasNotebookUseCase, HasFileExecuter {
    let noteUseCase: NoteUseCase
    let notebookUseCase: NotebookUseCase
    let fileExecuter: FileExecuter
}
