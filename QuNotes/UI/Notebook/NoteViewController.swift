//
//  NoteViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 29.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Notepad
import WSTagsField

protocol NoteViewControllerHandler: class {
    func didChangeContent(newContent: String)
    func didChangeTitle(newTitle: String)
    func onDeleteButtonClick()
    func didAddTag(tag: String)
    func didRemoveTag(tag: String)
    func willDisappear()
}

class NoteViewController: UIViewController {
    // MARK: - API

    func inject(handler: NoteViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NoteViewModel) {
        self.viewModel = viewModel
        dirty = true
        view?.setNeedsLayout()
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTagView()
        setupEditorTextView()
        setupTitleTextField()
        setupNavigationBar()
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handler?.willDisappear()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard dirty else { return }
        guard let viewModel = viewModel else { return }
        editor?.text = viewModel.content
        titleTextField?.text = viewModel.title
        if viewModel.isTitleActive {
            titleTextField?.becomeFirstResponder()
        }
        unsubscribeFromChangeTagEvents()
        viewModel.tags.forEach { self.tagView?.addTag($0) }
        subscribeOnChangeTagEvents()
    }

    override func viewDidLayoutSubviews() {
        dirty = false
    }

    // MARK: - Private

    private enum Constants {
        static let themeName = "one-dark"
        static let backButtonIconName = "backIcon"
    }

    fileprivate weak var handler: NoteViewControllerHandler?
    private var viewModel: NoteViewModel?
    private var editor: Notepad?
    private var tagView: WSTagsField?
    @IBOutlet private var stackView: UIStackView?
    @IBOutlet private var titleTextField: UITextField?

    private var dirty = false

    @objc private func onDeleteButtonClick() {
        handler?.onDeleteButtonClick()
    }

    @objc private func onTitleTextFieldChange() {
        handler?.didChangeTitle(newTitle: titleTextField!.text ?? "")
    }

    private func setupTagView() {
        let tagView = WSTagsField()
        tagView.backgroundColor = .white
        tagView.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tagView.spaceBetweenTags = 10.0
        tagView.font = .systemFont(ofSize: 12.0)
        tagView.tintColor = .green
        tagView.textColor = .black
        tagView.fieldTextColor = .blue
        tagView.selectedColor = .black
        tagView.selectedTextColor = .red
        subscribeOnChangeTagEvents()

        stackView!.addArrangedSubview(tagView)
        self.tagView = tagView
    }

    private func subscribeOnChangeTagEvents() {
        guard let tagView = tagView else { return }

        tagView.onDidAddTag = { [weak self] _, tag in
            self?.handler?.didAddTag(tag: tag.text)
        }

        tagView.onDidRemoveTag = { [weak self] _, tag in
            self?.handler?.didRemoveTag(tag: tag.text)
        }
    }

    private func unsubscribeFromChangeTagEvents() {
        guard let tagView = tagView else { return }

        tagView.onDidAddTag = nil;
        tagView.onDidRemoveTag = nil;
    }

    private func setupEditorTextView() {
        editor = Notepad(frame: view.bounds, themeFile: Constants.themeName)
        editor!.delegate = self;
        stackView!.addArrangedSubview(editor!)
    }

    private func setupTitleTextField() {
        titleTextField!.addTarget(self,
                                  action: #selector(NoteViewController.onTitleTextFieldChange),
                                  for: .editingChanged)
    }

    private func setupNavigationBar() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(NoteViewController.onDeleteButtonClick))
        self.navigationItem.rightBarButtonItem = deleteButton
    }
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        handler?.didChangeContent(newContent: textView.text)
    }
}
