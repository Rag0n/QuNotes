//
//  NoteViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 29.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

protocol NoteViewControllerHandler: class {
    func didChangeContent(newContent: String)
}

class NoteViewController: UIViewController {

    func inject(handler: NoteViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NoteViewModel) {
        self.viewModel = viewModel
        noteTextView?.text = viewModel.content
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
    }

    fileprivate weak var handler: NoteViewControllerHandler?
    fileprivate var viewModel: NoteViewModel?
    @IBOutlet private weak var noteTextView: UITextView?
}

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        handler?.didChangeContent(newContent: textView.text)
    }
}
