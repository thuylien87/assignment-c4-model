workspace {

    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "A staff of the bookstore" "User"

        # Software Systems
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "iBookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            frontStoreApp = container "Front-store Application" "Provide all the bookstore functionalities to both public and authorized users" "JavaScript & ReactJS"
            backOfficeApp = container "Back-office Application:" "Provide all the bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchApi = container "Search API" "Allows ONLY authorized users to search books information using HTTPs" "Go"
            searchDatabase = container "Search Database" "Stores searchable book information" "ElasticSearch" "Database"
            publicWebApi = container "Public Web API" "Allows public users getting books information using HTTPs" "Go"
            adminWebApi = container "Admin Web API" "Allow ONLY internal users to manage books and purchases information using HTTPs" "Go" {
                # Level 3: Components
                # <variable> = component <name> <description> <technology> <tag>
                bookService = component "Book Service" "Allows administrating book details" "Go"
                authService = component "Authorizer" "Authorize internal users by using external Identity Provider System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Book Event System" "Go"
            }
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventSystem = container "Book Event System" "Handle the book published event and forward to the Book Event Consumer" "Apache Kafka 3.0"
            bookSearchEventConsumer = container "Book Search Event Consumer" "Handle book update events and write to Search Database." "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events from Publisher System, and update book information" "Go"           
        }
         

        # External Software Systems
        authSystem = softwareSystem "Indentity Provider System" "The external Identiy Provider Platform" "External System"
        publisherSystem = softwareSystem "Publisher System" "The 3rd party system of publishers that gives details about books published by them" "External System"
        shippingServiceSystem = softwareSystem "Shipping Service" "The 3rd party system to handle the book delivery" "External System"

        # Relationship between People and Software Systems
        # <variable> -> <variable> <description> <protocol>
        publicUser -> bookstoreSystem "View book information"
        authorizedUser -> bookstoreSystem "Search book with more details, administrate books and their details"
        internalUser -> bookstoreSystem "Manage (add, update, delete) book details and User"
        bookstoreSystem -> authSystem "Register new user, and authorize user access"
        publisherSystem -> bookstoreSystem "Publish events for new book publication, and book information updates" 
        shippingServiceSystem -> bookstoreSystem "Handle the detail for book's orders, shipping" 

         # Relationship between Containers
        frontStoreApp -> publicWebApi "Search book and place order" "JSON/HTTPS"
        frontStoreApp -> searchApi "Search book and place order" "JSON/HTTPS"
        backOfficeApp -> adminWebApi "Administrate books and purchases" "JSON/HTTPS"
        searchApi -> authSystem "Authorize user" "JSON/HTTPS"
        searchApi -> searchDatabase "Retrieve book search data" "ODBC"
        publicUser -> publicWebApi "View book information" "JSON/HTTPS"
        publicWebApi -> bookstoreDatabase "Read/write the data" "PostgreSQL"
        adminWebApi -> authSystem "Authorize user" "JSON/HTTPS" 
        authorizedUser -> adminWebApi "manage books and purchases information" "JSON/HTTPS"
        adminWebApi -> bookstoreDatabase "Reads/Write book detail data" "ODBC"
        adminWebApi -> bookEventSystem "Publish book update events"
        bookEventSystem -> bookSearchEventConsumer "Consume book update events"
        bookSearchEventConsumer -> searchDatabase "Write book update data" "ODBC"        
        publisherRecurrentUpdater -> adminWebApi "Update the data changes" "JSON/HTTPS"

         # Relationship between Containers and External System
        publisherSystem -> publisherRecurrentUpdater "External events" {
            tags "Async Request"
        }

        # Relationship between Components
        authorizedUser -> bookService "Administrate book details" "JSON/HTTPS" 

        # Relationship between Components and Other Containers
        bookService -> bookstoreDatabase "Reads/Write book detail data" "ODBC"
        authService -> authSystem "Authorize internal users" "JSON/HTTPS"
        bookEventPublisher -> bookEventSystem "Publish book-related events"
    }

    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout lr
        }
        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout lr
        }

         # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout lr
        }

        styles {
            # element <tag> {}
            # element "Customer" {
            #     background #08427B
            #     color #ffffff
            #     fontSize 22
            #     shape Person
            # }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }
}