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
        editor?.text = viewModel.content
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditorTextView()
        setupBackButton()
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
    }

    fileprivate weak var handler: NoteViewControllerHandler?
    fileprivate var viewModel: NoteViewModel?
    fileprivate var editor: Notepad?

    @objc private func onBackButtonClick() {
        handler?.onBackButtonClick()
    }

    private func setupEditorTextView() {
        editor = Notepad(frame: view.bounds, themeFile: "one-dark")
        editor!.delegate = self;
        view.addSubview(editor!)
        editor!.translatesAutoresizingMaskIntoConstraints = false
        editor!.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        editor!.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        editor!.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        editor!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
