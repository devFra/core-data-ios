//
//  ContentView.swift
//  study-core-data
//
//  Created by Francesco on 06/10/22.
//

import SwiftUI

struct DetailsBookView: View {
    @StateObject private var vm = ContentViewModel.shared
    @StateObject var book: Book
    var body: some View {
        TextField("Enter your name", text: $book.title.toUnwrapped(defaultValue: "test"))
        Button(action: {
            save()
        }) {
            Text("save")
        }
    }
    

}

extension DetailsBookView {
    private func save(){
        vm.updateBook(book: book)
    }
}

struct ContentView: View {
    
    @StateObject private var vm = ContentViewModel.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Book count: \(vm.books.count)")
                VStack {
                    List {
                        ForEach(vm.books, id: \.self) { book in
                        
                            NavigationLink(destination: DetailsBookView(book: book)){
                                Text("\(book.title!) - \(book.author!)")
                            }
                            
                        }.onDelete(perform: deleteBook)
                        
                    }
                }
                Button("add Book") {
                    addBook()
                }
                
            }
            .padding()
        }
    }
                 
}

/** EVENTS */
extension ContentView {
    private func addBook(){
        vm.addBook(title: "TITOLO \(UUID())", author: "AUTORE")
    }
    
    private func deleteBook(at offset: IndexSet){
        vm.deleteBook(at: offset)
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
