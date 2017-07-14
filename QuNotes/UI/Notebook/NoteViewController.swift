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
    func onBackButtonClick()
    func onDeleteButtonClick()
    func didAddTag(tag: String)
    func didRemoveTag(tag: String)
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
        setupTagView()
        setupEditorTextView()
        setupTitleTextField()
        setupNavigationBar()
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
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
        viewModel.tags.forEach { self.tagView?.addTag($0) }
    }

    override func viewDidLayoutSubviews() {
        dirty = false
    }

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

    @objc private func onBackButtonClick() {
        handler?.onBackButtonClick()
    }

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

        tagView.onDidAddTag = { [weak self] _, tag in
            self?.handler?.didAddTag(tag: tag.text)
        }

        tagView.onDidRemoveTag = { [weak self] _, tag in
            self?.handler?.didRemoveTag(tag: tag.text)
        }

        stackView!.addArrangedSubview(tagView)
        self.tagView = tagView
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
        setupBackButton()
        setupDeleteButton()
    }

    private func setupBackButton() {
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: Constants.backButtonIconName),
                                         style: .plain,
                                         target: self,
                                         action: #selector(NoteViewController.onBackButtonClick))
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func setupDeleteButton() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(NoteViewController.onDeleteButtonClick))
        self.navigationItem.rightBarButtonItem = deleteButton
    }
}

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        handler?.didChangeContent(newContent: textView.text)
    }
}

extension NoteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
}
