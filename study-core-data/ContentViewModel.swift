//
//  ContentViewModel.swift
//  study-core-data
//
//  Created by Francesco on 09/10/22.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    static let shared = ContentViewModel()
    @Published var books: [Book]
    
    private var BookCtrl = BookDataController.shared
    
    private init(){
        self.books = []
        loadBooks()
    }
    
    func loadBooks(){

        if(false) { // ONLINE
            let book = Book(context: BookCtrl.container.viewContext)
            book.id = UUID()
            book.title = "Pippo"
            book.author = "pluto"
            self.books.append(book)
        }else { // OFFLINE
            self.books = BookCtrl.data
        }

    }
    
    func addBook(title: String, author: String){
        let book = Book(context: BookCtrl.container.viewContext)
        book.id = UUID()
        book.title = title
        book.author = author
        
        self.books.append(book) // add book to book list
        BookCtrl.addBook(title: title, author: author) // save to local DB
    }
    
    func deleteBook(at offset: IndexSet){
        self.books.remove(atOffsets: offset)
        BookCtrl.deleteBook(at: offset)
    }
    
    func updateBook(book: Book){
        let index = self.books.firstIndex(of: book)
        self.books[index!] = book
        BookCtrl.updateBook(update: book)
    }
    
}
