//
//  MainView.swift
//  swiftapp
//
//  Created by James Wilson on 1/12/22.
//

import SwiftUI

struct MainView: View {
    @State var title: String = ""

    var body: some View {
        HStack {
            List {
                Button("Note Title\nNote Description"){}.padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 50 / 255, green: 50 / 255, blue: 50 / 255)))
                    .buttonStyle(PlainButtonStyle())
                
            }
            .frame(width: 300, height: 500, alignment: .leading)
            ZStack {
                TextField("Note Title", text: $title)
                    .frame(width: 500, height: 500, alignment: .topLeading)
                TextEditor(text: .constant("Note Body"))
                    .frame(width: 500, height: 500, alignment: .topLeading)
                    .padding(.top, 50)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
