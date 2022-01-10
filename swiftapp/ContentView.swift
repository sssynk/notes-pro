//
//  ContentView.swift
//  swiftapp
//
//  Created by James Wilson on 1/10/22.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @AppStorage("name") var name = "User"
    
    var body: some View {
        ZStack {
            Text("james.baby notes")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("sign in")
                .padding(.top, 60)
                .font(.title)
            ZStack {
                TextField("Username", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    .frame(width: 400, height: 50)
                    .padding(.top, 350)
                    .textFieldStyle(.automatic)
                    .font(Font.system(size: 20, design: .default))
                TextField("Password", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    .frame(width: 400, height: 50)
                    .padding(.top, 420)
                    .textFieldStyle(.automatic)
                    .font(Font.system(size: 20, design: .rounded))
                
                Button("Log In") {
                    logUser()
                }
                .padding(.top, 500)
            }
            
        }
        .padding(.leading, 50.0)
        .padding(.trailing, 50.0)
        .padding(.bottom, 300.0)
    }
    func logUser() {
        let request = requestLogin(username: "synk", password: "synk")
        
    }
    func requestLogin(username: String, password: String) {
        let req = query(address: URL(string: "https://api.james.baby/s/internal/login?username=\(username)&password=\(password)")!)
        if(req.statusCode == 200) {
            print("WELCOME!!")
        } else {
            print("BRUH")
        }
    }
    func query(address: URL) -> HTTPURLResponse {
        var url = URLRequest(url: address)
        url.setValue("https://james.baby", forHTTPHeaderField: "origin")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: HTTPURLResponse
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            result = (response as? HTTPURLResponse)!
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
