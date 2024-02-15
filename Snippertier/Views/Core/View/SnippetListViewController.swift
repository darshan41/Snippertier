//
//  SnippetListViewController.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa
import SwiftUI

private let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "SnippetTableCellView")

class SnippetListViewController: NSViewController {
    
    @IBOutlet private weak var noRecentsLabel: NSTextField!
    @IBOutlet private weak var listTableView: TableView!
    @IBOutlet private weak var addSnippetButton: HoverButton!
    @IBOutlet private weak var closeButton: HoverButton!
    @IBOutlet private weak var changeAlphaTriggerBtn: HoverButton!
    
    private let model: NSEventsManager
    
    private weak var presentedSnippetExtractor: NSHostingController<SnippetExtractor>?
    private weak var presentedPencilView: NSHostingController<SingleCharacterTextField>?
    
    private var alert: CustomAlert? {
        didSet {
            alert?.show()
        }
    }
    
    weak var snippetDelegate: SnippetDelegate?
    
    private weak var focusedSnippet: Snippet? {
        didSet {
            snippetDelegate?.snippet = focusedSnippet
        }
    }
    
    init(model: NSEventsManager) {
        self.model = model
        super.init(nibName: NSNib.Name.init(String.init(describing: Self.self)), bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    @IBAction func onTapAddSnippet(_ sender: HoverButton) {
        showAddOrEdit()
    }
    
    @IBAction func onTap(_ sender: TableView) {
        print(sender.selectedRow)
    }
    
    @IBAction func onTapClose(_ sender: HoverButton) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func onChangeAlphaTrigger(_ sender: Any) {
        showChangeAlphaIdentifierBtn()
    }
    
    deinit {
        debugPrint("💥 Deininting \(Self.self)")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: NSTabViewDelegate

extension SnippetListViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        80
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }
        self.focusedSnippet = self.model.snippets[safe: tableView.selectedRow]
    }
}

// MARK: NSTableViewDataSource

extension SnippetListViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        model.snippets.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? SnippetTableCellView else {
            return nil
        }
        guard let snippet = model.snippets[safe: row] else {
            return nil
        }
        cell.configure(snippet)
        return cell
    }
}

// MARK: Helper func's


private extension SnippetListViewController {
    
    func configureView() {
        preferredContentSize = .init(width: 500, height: 500)
        listTableView.doubleAction = #selector(doubleAction(_:))
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(NSNib(nibNamed: .init("SnippetTableCellView"), bundle: nil), forIdentifier: cellIdentifier)
        listTableView.target = self
        let menu = NSMenu(title: "Contextual Menu")
        let deleteMenuItem = NSMenuItem(title: "Delete", action: #selector(deleteItem(_:)), keyEquivalent: "")
        let editMenuItem = NSMenuItem(title: "Edit", action: #selector(editItem(_:)), keyEquivalent: "")
        deleteMenuItem.representedObject = listTableView
        editMenuItem.representedObject = listTableView
        menu.addItem(deleteMenuItem)
        menu.addItem(editMenuItem)
        listTableView.menu = menu
        checkList()
        let options: NSEvent.EventTypeMask = [.rightMouseDown]
        NSEvent.addLocalMonitorForEvents(matching: options) { [weak self] event in
            guard let self,event.type == .rightMouseDown else { return event }
            self.handleContextMenuEvent(event)
            return event
        }
        NotificationCenter.addDefaultObserver(name: .userDefinedNotification(.didChangeData), observer: self, selector: #selector(checkForResultsDataAndReloadList))
    }
    
    func checkList() {
        Task {
            let isEmpty = model.snippets.isEmpty
            self.listTableView.reloadData()
            checkForResultsData()
            guard !isEmpty else { return }
            self.listTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    func showChangeAlphaIdentifierBtn() {
        let hostingController = NSHostingController(rootView: SingleCharacterTextField(currentCharacter: Constant.currentIdentifier, onUpdate: { [weak self] character in
            guard let self else { return }
            guard Constant.alphaIdentifier != character else {
                if let presentedPencilView  {
                    dismiss(presentedPencilView)
                }
                return }
            Constant.setAlphaIdentifier(String(character))
            do {
                try model.didChangeAlphaIdentifier()
                if let presentedPencilView  {
                    dismiss(presentedPencilView)
                }
            } catch {
                Constant.setAlphaIdentifier(String(Constant.currentIdentifier))
                if let presentedPencilView  {
                    dismiss(presentedPencilView)
                }
                alert = CustomAlert(title: error.localizedDescription)
            }
        }))
        hostingController.title = "Change Identifier"
        self.presentedPencilView = hostingController
        self.presentAsModalWindow(hostingController)
    }
    
    func showAddOrEdit(_ snippet: Snippet? = nil) {
        let hostingController = NSHostingController(rootView: SnippetExtractor(onUpdate: { [weak self] latestSnippet, value in
            guard let self else { return }
            if let latestSnippet {
                self.editSnippet(latestSnippet: latestSnippet, new: value)
            } else {
                self.create(with: value)
            }
        }, snippet: snippet))
        hostingController.title = snippet == nil ? "Add Snippet" : "Edit Snippet"
        self.presentedSnippetExtractor = hostingController
        self.presentAsModalWindow(hostingController)
    }
    
    func editSnippet(latestSnippet: Snippet,new value: SnippetValue) {
        let triggeredValue = value.trigger.triggeredValue
        guard !self.isAdded(triggeredValue, except: latestSnippet) else {
            alert = .init(title: "Trigger with this \(value.trigger) is already registered!")
            return
        }
        latestSnippet.trigger = triggeredValue
        latestSnippet.content = value.content
        latestSnippet.date = Date()
        latestSnippet.desc = value.description
        latestSnippet.isABigContent = value.content.count > 30
        do {
            try self.model.coreDataStack.managedContext.save()
            self.listTableView.reloadData()
            checkForResultsData()
            if let presentedSnippetExtractor  {
                dismiss(presentedSnippetExtractor)
            }
        } catch {
            alert = .init(title: error.localizedDescription)
        }
    }
    
    func create(with value: SnippetValue) {
        do {
            let triggeredValue = value.trigger.triggeredValue
            guard !self.isAdded(triggeredValue) else {
                alert = .init(title: "This Trigger Action is already registered!")
                return
            }
            let snippet = try Snippet.insertWithSave(in: self.model.coreDataStack.managedContext, trigger: triggeredValue, content: value.content, description: value.description)
            self.model.snippets.append(snippet)
            self.listTableView.reloadData()
            checkForResultsData()
            if let presentedSnippetExtractor  {
                dismiss(presentedSnippetExtractor)
            }
        } catch {
            alert = .init(title: error.localizedDescription)
        }
    }
    
    func isAdded(_ triggerName: String?,except: Snippet? = nil) -> Bool {
        guard let triggerName else { return true }
        if let except = except {
            return model.snippets.contains(where: { ($0.trigger == triggerName) && (except.id != $0.id) })
        } else {
            return model.snippets.contains(where: { $0.trigger == triggerName })
        }
    }
}

// MARK: @objc func's

@objc private extension SnippetListViewController {
    
    @objc func checkForResultsData() {
        let isEmpty = model.snippets.isEmpty
        listTableView.isHidden = isEmpty
        noRecentsLabel.isHidden = !isEmpty
    }
    
    @objc func checkForResultsDataAndReloadList() {
        let isEmpty = model.snippets.isEmpty
        listTableView.isHidden = isEmpty
        noRecentsLabel.isHidden = !isEmpty
        listTableView.reloadData()
    }
    
    func handleContextMenuEvent(_ event: NSEvent) {
        let point = listTableView.convert(event.locationInWindow, from: nil)
        let clickedRow = listTableView.row(at: point)
        listTableView.selectRowIndexes(IndexSet(integer: clickedRow), byExtendingSelection: false)
    }
    
    func doubleAction(_ sender: NSTableView) {
        let selectedView = sender.selectedRow
        print(selectedView)
    }
    
    func deleteItem(_ sender: NSMenuItem) {
        guard let sender = sender.representedObject as? NSTableView,
              let focusedSnippet else { return }
        let context = model.coreDataStack.managedContext
        do {
            focusedSnippet.prepareForDeletion()
            context.delete(focusedSnippet)
            if let firstIndex = self.model.snippets.firstIndex(of: focusedSnippet) {
                self.model.snippets.remove(at: firstIndex)
                sender.removeRows(at: IndexSet(integer: firstIndex))
            }
            try context.save()
            checkForResultsData()
        } catch {
            alert = CustomAlert(title: error.localizedDescription)
        }
    }
    
    func editItem(_ sender: NSMenuItem) {
        guard let focusedSnippet else { return }
        showAddOrEdit(focusedSnippet)
    }
}

