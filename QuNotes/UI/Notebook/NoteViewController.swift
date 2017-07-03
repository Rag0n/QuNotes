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
    func didChangeTitle(newTitle: String)
    func onBackButtonClick()
}

class NoteViewController: UIViewController {

    func inject(handler: NoteViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NoteViewModel) {
        self.viewModel = viewModel
        dirty = true
        view?.setNeedsLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditorTextView()
        setupTitleTextField()
        setupBackButton()
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard dirty else { return }
        guard let viewModel = viewModel else { return }
        editor?.text = viewModel.content
        titleTextField?.text = viewModel.title
    }

    override func viewDidLayoutSubviews() {
        dirty = false
    }

    fileprivate weak var handler: NoteViewControllerHandler?
    private var viewModel: NoteViewModel?
    private var editor: Notepad?
    @IBOutlet private var stackView: UIStackView?
    @IBOutlet private var titleTextField: UITextField?

    private var dirty = false

    @objc private func onBackButtonClick() {
        handler?.onBackButtonClick()
    }

    @objc private func onTitleTextFieldChange() {
        handler?.didChangeTitle(newTitle: titleTextField!.text ?? "")
    }

    private func setupEditorTextView() {
        editor = Notepad(frame: view.bounds, themeFile: "one-dark")
        editor!.delegate = self;
        stackView!.addArrangedSubview(editor!)
    }

    private func setupTitleTextField() {
        titleTextField!.addTarget(self,
                                  action: #selector(NoteViewController.onTitleTextFieldChange),
                                  for: .editingChanged)
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
