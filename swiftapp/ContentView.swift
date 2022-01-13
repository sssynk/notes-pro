//
//  ContentView.swift
//  swiftapp
//
//  Created by James Wilson on 1/10/22.
//

import SwiftUI
import WebKit
import Combine


struct Note: Identifiable, Equatable {
    let id = UUID()
    var noteid: String
    var title: String
    var contents: String
    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.noteid == rhs.noteid
    }
}

class CurrentApp: ObservableObject {
    @Published var token = ""
    @Published var all_notes = [Note(noteid: "", title: "Start Typing on the Right to Make a Note!", contents: "")]
    @Published var note = Note(noteid: "", title: "none", contents: "none")
}

struct ContentView: View {
    @StateObject var current_data = CurrentApp()
    @State var username: String = ""
    @State var password: String = ""
    @State var errortext: String = ""
    @Environment(\.openURL) var openURL
    let myWindow:NSWindow?
    
    var body: some View {
        ZStack {
            Text("james.baby notes")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("sign in")
                .padding(.top, 60)
                .font(.title)
            ZStack {
                TextField("Username", text: $username)
                    .frame(width: 400, height: 50)
                    .padding(.top, 350)
                    .textFieldStyle(.automatic)
                    .font(Font.system(size: 20, design: .default))
                SecureField("Password", text: $password)
                    .frame(width: 400, height: 50)
                    .padding(.top, 420)
                    .textFieldStyle(.automatic)
                    .font(Font.system(size: 20, design: .rounded))
                    .privacySensitive()
                
                Button("Log In") {
                    logUser()
                }
                .padding(.top, 500)
                
                Button("Sign Up") {
                    guard let url = URL(string: "https://james.baby/signup") else { return }
                    openURL(url)
                }
                .padding(.top, 550)
                
                Text(errortext)
                    .foregroundColor(Color.orange)
                    .padding(.top, 600)
            }
            
        }
        .padding(.leading, 50.0)
        .padding(.trailing, 50.0)
        .padding(.bottom, 300.0)
    }
    func logUser() {
        let request = requestLogin(username: username, password: password)
        if (request == true) {
            NSApplication.shared.keyWindow?.close()
            
            //openURL(url)
            let notes = getWithAuth(address: URL(string: "https://api.james.baby/s/notes")!)
            print(notes["notes"]!)
            if let notes_arr = notes["notes"] as? [[String:String]] {
                if(notes_arr.count > 0) { current_data.all_notes.removeAll() }
                for note in notes_arr {
                    let title = note["title"]
                    let content = note["contents"]
                    let noteid = note["noteid"]
                    current_data.all_notes.append(Note(noteid: noteid ?? "load_failed", title: title ?? "Load Failed", contents: content ?? "Load Failed"))
                }
            }
            
            let window = NSWindow(contentRect: NSRect(x: 20, y: 20, width: 480, height: 300), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.contentView = NSHostingView(rootView: Login().environmentObject(current_data))
            window.makeKeyAndOrderFront(nil)
            window.title = "Notes Pro"
        } else {
            errortext = "Incorrect Username or Password!"
            password = ""
        }
    }
    func requestLogin(username: String, password: String) -> Bool {
        let req = query(address: URL(string: "https://api.james.baby/s/internal/login?username=\(username)&password=\(password)")!)
        if(req.statusCode == 200) {
            let r2 = queryFData(address: URL(string: "https://api.james.baby/s/internal/login?username=\(username)&password=\(password)")!)
            let tkn = r2["internal_token"]
            current_data.token = tkn as! String
            return true
        } else {
            return false
        }
    }
    func query(address: URL) -> HTTPURLResponse {
        var url = URLRequest(url: address)
        url.setValue("https://james.baby", forHTTPHeaderField: "Origin")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Any? = nil
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            result = (response as? HTTPURLResponse)!
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result as! HTTPURLResponse
    }
    func queryFData(address: URL) -> [String: Any] {
        var url = URLRequest(url: address)
        url.setValue("https://james.baby", forHTTPHeaderField: "Origin")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: [String: Any]? = nil
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                result = responseJSON
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result!
    }
    func getWithAuth(address: URL) -> [String: Any] {
        var url = URLRequest(url: address)
        url.setValue("https://james.baby", forHTTPHeaderField: "Origin")
        url.setValue(current_data.token, forHTTPHeaderField: "Authorization")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: [String: Any]? = nil
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                result = responseJSON
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result!
    }
}

struct Login: View {
    @State var title: String = ""
    @State var cont: String = ""
    @State var savestr: String = ""
    @State var autoSaveEnabled = true
    @State var currentNote: Note = Note(noteid: "n/a", title: "n/a", contents: "n/a")
    @EnvironmentObject private var current_data: CurrentApp
    var body: some View {
        HStack {
            List {
                ForEach(current_data.all_notes.reversed()) { note in
                    Button("\(note.title)\n\(note.contents)"){
                        loadNote(note: note)
                    }.padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 50 / 255, green: 50 / 255, blue: 50 / 255)))
                        .buttonStyle(PlainButtonStyle())
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(1)
                }
            }.animation(.interactiveSpring())
            .frame(width: 300, height: 500, alignment: .leading)
            ZStack {
                HStack {
                    Button("New Note") {
                        newVis()
                    }
                    .padding(.bottom, 70)
                    Button("Save Note") {
                        handleSave()
                    }
                    .padding(.bottom, 70)
                    Text(savestr)
                    .padding(.bottom, 70)
                }
                .frame(width: 500, height: 500, alignment: .topTrailing)
                .padding(.bottom, 80)
                .padding(.top, 10)
                
                TextField("Note Title", text: $title)
                    .background(
                           RoundedRectangle(cornerRadius: 5)
                               .fill(Color.white.opacity(0)
                           )
                    )
                    .font(.largeTitle)
                    .textFieldStyle(.plain)
                    .frame(width: 500, height: 500, alignment: .topLeading)
                    .onDebouncedChange(of: $title, debounceFor: 2) {
                        value in
                        autoSave()
                    }
                TextField("Note Contents", text: $cont)
                    .background(
                           RoundedRectangle(cornerRadius: 5)
                               .fill(Color.white.opacity(0)
                           )
                    )
                    .textFieldStyle(.plain)
                    .frame(width: 500, height: 500, alignment: .topLeading)
                    .padding(.top, 70)
                    .onDebouncedChange(of: $cont, debounceFor: 2) {
                        value in
                        autoSave()
                    }
            }
        }.onAppear(perform: {
            print("loaded!")
        })
    }
    func autoSave() {
        if(autoSaveEnabled == true && currentNote.contents != cont || currentNote.title != title) {
            handleSave()
        }
    }
    func loadNote(note: Note) {
        title = note.title
        cont = note.contents
        currentNote = note
    }
    func newVis() {
        title = ""
        cont = ""
        currentNote = Note(noteid: "n/a", title: "", contents: "")
    }
    func setStr(text: String) {
        savestr = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if (savestr == text) {
                savestr = ""
            }
        }
    }
    func handleSave() {
        if(currentNote.noteid == "n/a") {
            setStr(text: "Saving new note...")
            newNote(note: Note(noteid: "n/a", title: title, contents: cont))
        } else {
            setStr(text: "Saving note...")
            updateNote(note: Note(noteid: currentNote.noteid, title: title, contents: cont))
        }
    }
    func newNote(note: Note) { // no noteid required
        let ret = postWithAuth(address: URL(string: "https://api.james.baby/s/notes")!, body: ["title": note.title, "contents": note.contents], req_type: "POST")
        if(ret["status"] as! Int == 201) {
            current_data.all_notes.append(Note(noteid: ret["note_id"] as! String, title: note.title, contents: note.contents))
            currentNote = Note(noteid: ret["note_id"] as! String, title: note.title, contents: note.contents)
            setStr(text: "Created new note!")
        } else {
            setStr(text: "New note creation failed!")
            print(ret)
            print("the funny occurred!!! (unable to make new note)")
        }
    }
    func updateNote(note: Note) { // requires a noteid
        let ret = postWithAuth(address: URL(string: "https://api.james.baby/s/notes/\(note.noteid)")!, body: ["title": note.title, "contents": note.contents], req_type: "PUT")
        if(ret["status"] as! Int == 200) {
            if let index = current_data.all_notes.firstIndex(of: note) {
                current_data.all_notes.remove(at: index)
            }
            current_data.all_notes.append(Note(noteid: note.noteid, title: note.title, contents: note.contents))
            currentNote = Note(noteid: note.noteid, title: note.title, contents: note.contents)
            setStr(text: "Saved note!")
        } else {
            setStr(text: "Unable to save note!")
            print("the funny occurred!!! (unable to update note)")
        }
    }
    func getWithAuth(address: URL) -> [String: Any] {
        var url = URLRequest(url: address)
        url.setValue("https://james.baby", forHTTPHeaderField: "Origin")
        url.setValue(current_data.token, forHTTPHeaderField: "Authorization")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: [String: Any]? = nil
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                result = responseJSON
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result!
    }
    
    func postWithAuth(address: URL, body: Dictionary<String, String>, req_type: String) -> [String: Any] {
        var url = URLRequest(url: address)
        do {
            url.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }
        url.setValue("https://james.baby", forHTTPHeaderField: "Origin")
        url.setValue(current_data.token, forHTTPHeaderField: "Authorization")
        url.setValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = req_type
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: [String: Any]? = nil
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                result = responseJSON
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result ?? ["status": 200]
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(myWindow: nil)
    }
}

extension View {
    func onDebouncedChange<V>(
        of binding: Binding<V>,
        debounceFor dueTime: TimeInterval,
        perform action: @escaping (V) -> Void
    ) -> some View where V: Equatable {
        modifier(ListenDebounce(binding: binding, dueTime: dueTime, action: action))
    }
}

private struct ListenDebounce<Value: Equatable>: ViewModifier {
    @Binding
    var binding: Value
    @StateObject
    var debounceSubject: ObservableDebounceSubject<Value, Never>
    let action: (Value) -> Void

    init(binding: Binding<Value>, dueTime: TimeInterval, action: @escaping (Value) -> Void) {
        _binding = binding
        _debounceSubject = .init(wrappedValue: .init(dueTime: dueTime))
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: binding) { value in
                debounceSubject.send(value)
            }
            .onReceive(debounceSubject) { value in
                action(value)
            }
    }
}

private final class ObservableDebounceSubject<Output: Equatable, Failure>: Subject, ObservableObject where Failure: Error {
    private let passthroughSubject = PassthroughSubject<Output, Failure>()

    let dueTime: TimeInterval

    init(dueTime: TimeInterval) {
        self.dueTime = dueTime
    }

    func send(_ value: Output) {
        passthroughSubject.send(value)
    }

    func send(completion: Subscribers.Completion<Failure>) {
        passthroughSubject.send(completion: completion)
    }

    func send(subscription: Subscription) {
        passthroughSubject.send(subscription: subscription)
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        passthroughSubject
            .removeDuplicates()
            .debounce(for: .init(dueTime), scheduler: RunLoop.main)
            .receive(subscriber: subscriber)
    }
}
