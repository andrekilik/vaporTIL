import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Controller configuration
    let acronymsController = AcronymsController()
    let usersController = UsersController()
    let categoriesController = CategoriesController()
    
    try router.register(collection: acronymsController)
    try router.register(collection: usersController)
    try router.register(collection: categoriesController)
    
    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
