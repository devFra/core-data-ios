||||
| :- | :-: | -: |

Guide – Code Data – iOS

# Cos'è Core Data

Core Data è un framework di modellazione dati orientato agli oggetti, sviluppato dalla Apple per i propri sistemi operativi (macOS, iOS, iPadOS, tvOS e watchOS).

Core Data fornisce agli sviluppatori le funzionalità per la gestione, l'archiviazione e il recupero degli oggetti, e per altre attività del ciclo di vita degli oggetti, come la persistenza.

Definizione del datamodel 

Nel progetto aggiungere un file di tipo “Data Model” in seguito possiamo iniziare con la definizione del nostro database. 

![Image](https://user-images.githubusercontent.com/110390906/195062446-9e8a8046-00a9-466c-b73f-c5b0899d4661.png)

Una volta aperto il file appena creato procediamo con la definizione delle Entries e I relativi attributi: 

![Image](https://user-images.githubusercontent.com/110390906/195062657-3d0d3468-b38f-440e-a720-22d696f56e1a.png)

Ora passiamo con la scrittura del controller, creare un nuovo file swift e procedere con la definizione della seguente classe:

```swift

import CoreData

class DataController: ObservableObject {

    let container = NSPersistentContainer(name: "rsidatamodel")

    init(){
        container.loadPersistentStores { description, error **in**

            if let error = error {
                print ("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
```

Notare che nel costrutturore della classe **NSPeristentContainer** va inserito il nome del file data model. 


Nello step successivo si andrà a instanziare nella @main della nostra app il controller definito in precedenza come segue:

```swift
@StateObject **private** **var** dataController = DataController()
```

Poi si andrà a definire nel contentVIew tramite modificatore l’ambiente con l’ instanza di “dataController”:

```swift
var body: some Scene {
    WindowGroup {
        ContentView().environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
```

Una volta preparato il context della view principale, si potra richiamare il data core controller dalle sotto view. 

Ora andiamo a richiamare il dataController:

```swift
@Environment(\.managedObjectContext) var moc
```

**Scrittura**

Per poter aggiungere un’ alemento all’ entità “Book” bisognerà prima instanziare un’ oggetto di tipo “Book” ( generato dinamicamente da Code Data ) compilare I sui attributi e in fine salvare le modifche tramie il metodo “save” del controller.

Esempio:

```swift
let newBook = Book(context: moc)
newBook.id = UUID()
newBook.title = "Title book"
newBook.author = "Mario Rossi"
try? moc.save()
```

**Lettura**

Per poter leggere un dato da entità, come per I tradizionali data base bisognerà fare una richiesta, in questo caso andremo a richiedere la lista degli elementi presenti nell’ entità “Book”, nel seguente modo:

```swift
@FetchRequest(sortDescriptors: []) var books: FetchedResults<Book>
```

La richiesta ritorneà una collezione di elementi “**Book**” sotto forma di observable, che la view potrà aggiornare in caso di cambiamenti. 

```swift
VStack {
    List {
        ForEach(books, id: \.self) { book in
            Text(book.title ?? "Unkown")
        }.onDelete(perform: deleteBook)
    }
}
```


# Core Data e MVVM

In questa sezione andremo ad applicare Core Data nel contesto di un architettura MVVM. Come nella sezione precedere andreamo a creare il file coredatamodel dove si andrà a definire le entities  I relativi attributi. 

Di seguito si andrà a procedere con la creazione del controller generico dovè indicheremo il file coredatamodel. 

```swift
import CoreData

class DataController: ObservableObject {

    let container = NSPersistentContainer(name: "<coredatamodel file>")

    init(){
        container.loadPersistentStores { description, error in
            if let error = error {
                print ("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
```

Successivamente andremo a creare il controller specifico per la specifica Entry, questo controller andrà ad estendere il controller creato precedentemente.

```swift
import SwiftUI
import CoreData

class BookDataController: DataController {

    static let shared: BookDataController = BookDataController()
    private let entityName = "<entry name>"
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
        }catch let error {
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
```

Oltre all’ observable “data” che conterrà I valori della entry, forniremo anche i metodi CRUD. 

A questo punto andiamo a creare il ViewModel, predisposto per la gestione della modalità offline:

```swift
mport SwiftUI

@MainActor
class ContentViewModel: ObservableObject {

    static** let shared = ContentViewModel()
    @Published var books: [Book]
    private var BookCtrl = BookDataController.shared
    
    private init(){
        self.books = []
        loadBooks()
    }

    func loadBooks(){

        if(false) { // ONLINE
            //simulazione Chiamata HTTP 
            let** book = Book(context: BookCtrl.container.viewContext)
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

    func updateBook(book: Book){
        let index = self.books.firstIndex(of: book)
        self.books[index!] = book
        BookCtrl.updateBook(update: book)
    }

    func deleteBook(at offset: IndexSet){
        self.books.remove(atOffsets: offset)
        BookCtrl.deleteBook(at: offset)
    }

}
```

Dettagli: 
```swift
@Published var books: [Book] //-> observable che esporremo alla view 

**private** var BookCtrl = BookDataController.shared. //-> instanza del controller della entry
```

In fine nella view andremo ad inserire la subscription nella view per la book list:

```swift
@StateObject private var vm = ContentViewModel.shared

NavigationView {
    VStack {
        Text("Book count: \(vm.books.count)")
        VStack {
            List {
                ForEach(vm.books, id: \.**self**) { book in
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
```

Defininiamo un' exstention per gestire gli eventi
```swift
extension** ContentView {
    private** func addBook(){
        vm.addBook(title: "TITOLO \(UUID())", author: "AUTORE")
    }

    private func deleteBook(at offset: IndexSet){
        vm.deleteBook(at: offset)
    }
}
```

Definiamo anche la view di dettaglio:

```swift
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
```
E la relativa extension per gli eventi:

```swift
extension DetailsBookView {
    private func save(){
        vm.updateBook(book: book)
    }
}
```



