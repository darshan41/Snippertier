//
//  NSEventsManager.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import SwiftUI
import Carbon
import OSLog
//import Sauce

public class NSEventsManager {
    
    private let shared: SnippertierApp = .shared
    
    let coreDataStack: CoreDataStackManagible = { CoreDataStack(model: .snippertier) }()
    
    @Published private var text: String = ""
    @Published public var snippets: [Snippet] = []
    
    public init() {
        self.snippets = findObjects("")
        NSEvent.addGlobalMonitorForEvents(matching: [.rightMouseDown,.leftMouseDown,.otherMouseDown]) { [weak self] event in
            guard let self,!shared.shouldPauseMonitering else {
                if !(self?.text ?? "").isEmpty {
                    self?.text = ""
                }
                return
            }
            self.text = ""
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self,!shared.shouldPauseMonitering else {
                if !(self?.text ?? "").isEmpty {
                    self?.text = ""
                }
                return
            }
            guard let characters = event.characters else { return }
            if event.isDelete,!self.text.isEmpty {
                self.text.removeLast()
            } else if event.keyCode > 100 {
                self.text = ""
            } else {
                self.text+=characters
            }
            self.matchSnippets()
        }
    }
    
    func matchSnippets() {
        if let match = snippets.first(where: { $0.matches(self.text) }) {
            insertSnippet(match)
        }
    }
    
    func findObjects(_ queryString: String) -> [Snippet] {
        do {
            let request = Snippet.coreFetchRequest(expectedType: Snippet.self)
            let descrtiptors = Snippet.nameFilterSortPredicate(queryString)
            request.predicate = descrtiptors.0
            request.sortDescriptors = descrtiptors.1
            let snippets = try coreDataStack.managedContext.fetch(Snippet.fetchRequest())
            return snippets
        } catch {
            return []
        }
    }
    
    func updateSnippets() {
        self.text = ""
        self.snippets = findObjects("")
    }
    
    func delete() {
        let eventSource = CGEventSource(
            stateID: .combinedSessionState
        )
        let keyDownEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: CGKeyCode(51),
            keyDown: true
        )
        let keyUpEvent = CGEvent(
            keyboardEventSource:eventSource,
            virtualKey: CGKeyCode(51),
            keyDown: false
        )
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    // MARK: https://github.com/Clipy/Sauce - For Other type key boards
    
    func paste() {
        //        let keyCode = Sauce.shared.keyCode(for: .v)
        let keyCode = CGKeyCode(kVK_ANSI_V)
        let eventSource = CGEventSource(
            stateID: .combinedSessionState
        )
        let keyDownEvent = CGEvent(
            keyboardEventSource:eventSource,
            virtualKey: CGKeyCode(keyCode),
            keyDown: true
        )
        keyDownEvent?.flags.insert(.maskCommand)
        let keyUpEvent = CGEvent(
            keyboardEventSource:eventSource,
            virtualKey: CGKeyCode(keyCode),
            keyDown: false
        )
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    func insertSnippet(_ snippet: Snippet) {
        guard let trigger = snippet.trigger else { return }
        for _ in trigger {
            self.delete()
        }
        guard let content = snippet.content else { return }
        let oldClipboard = NSPasteboard.general.string(forType: .string)
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(content, forType: .string)
        paste()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let oldClipboard {
                NSPasteboard.general.setString(oldClipboard, forType: .string)
            }
        }
    }
    
    func didChangeAlphaIdentifier() throws {
        self.text = ""
        let fetchRequest: NSFetchRequest<Snippet> = Snippet.fetchRequest()
        let context = self.coreDataStack.managedContext
        let currentIdentifier = Constant.currentIdentifier
        let updatedIdentifier = String(Constant.alphaIdentifier)
        do {
            let snippets = try context.fetch(fetchRequest)
            for snippet in snippets {
                if let trigger = snippet.trigger,!trigger.isEmpty {
                    snippet.trigger = updatedIdentifier + trigger.dropFirst()
                }
            }
            try context.save()
            self.updateSnippets()
            NotificationCenter.postDefault(.userDefinedNotification(.didChangeData))
            Constant.setCurrentAlphaIdentifier(updatedIdentifier)
        } catch {
            throw CoreDataStack.Error.custom(error.localizedDescription)
        }
    }
}
