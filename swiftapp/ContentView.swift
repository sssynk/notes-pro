//
//  ContentView.swift
//  swiftapp
//
//  Created by James Wilson on 1/10/22.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var errortext: String = ""
    
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
            
        } else {
            errortext = "Incorrect Username or Password!"
            password = ""
        }
    }
    func requestLogin(username: String, password: String) -> Bool {
        let req = query(address: URL(string: "https://api.james.baby/s/internal/login?username=\(username)&password=\(password)")!)
        if(req.statusCode == 200) {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
