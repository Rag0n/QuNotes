//
//  NoteViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 29.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Notepad

protocol NoteViewControllerHandler: class {
    func didChangeContent(newContent: String)
    func onBackButtonClick()
}

class NoteViewController: UIViewController {

    func inject(handler: NoteViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NoteViewModel) {
        self.viewModel = viewModel
//        noteTextView?.text = viewModel.content
        notepad?.text = viewModel.content
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        notepad = Notepad(frame: view.bounds, themeFile: "one-dark")
//        notepad = Notepad(frame: view.bounds)
        guard let notepad = notepad else {
            return;
        }
        notepad.delegate = self;
        view.addSubview(notepad)
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
        setupBackButton()
    }

    fileprivate var notepad: Notepad?

    fileprivate weak var handler: NoteViewControllerHandler?
    fileprivate var viewModel: NoteViewModel?
    @IBOutlet fileprivate weak var noteTextView: UITextView?

    @objc private func onBackButtonClick() {
        handler?.onBackButtonClick()
    }

    private func setupBackButton() {
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back",
                                         style: .plain,
                                         target: self,
                                         action: #selector(NoteViewController.onBackButtonClick))
        self.navigationItem.leftBarButtonItem = backButton
    }
}

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        handler?.didChangeContent(newContent: textView.text)
    }
}
