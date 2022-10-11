//
//  BookDataController.swift
//  study-core-data
//
//  Created by Francesco on 07/10/22.
//

import SwiftUI
import CoreData

class BookDataController: DataController {
    
    static let shared: BookDataController = BookDataController()
    
    private let entityName = "Book"
    
    @Published var data: [Book] = []
    
    override private init() {
        // Load persistent stores
        super.init()
        // Load Entity values
        fetchBook()
    }
    
    private func fetchBook(){
        
        let request = NSFetchRequest<Book>(entityName: entityName)

        do {
            self.data = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func addBook(title:String, author:String) {
        let newBook = Book(context:container.viewContext)
        newBook.id = UUID()
        newBook.title = title
        newBook.author = author
        saveData()
    }
    
    func deleteBook(at offset: IndexSet){
        do {
            for index in offset {
                let book = data[index]
                container.viewContext.delete(book)
            }
            saveData()
        } catch let error {
            print("Error deleting... \(error)")
        }
    }
    
    func updateBook(update: Book){
        do {
            var book = data.first(where: { $0.id == update.id} )
            book = update
            saveData()
        } catch let error {
            print("Error updating... \(error)")
        }
    }
    
    private func saveData() {
        do {
            try container.viewContext.save()
            fetchBook()
        } catch let error {
            print("Error saving... \(error)")
        }
    }
}
