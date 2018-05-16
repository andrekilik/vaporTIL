import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        let acronymsRoute = router.grouped("api", "acronyms")
//        router.get("api", "acronyms", use: getAllHandler)
        acronymsRoute.get(use: getAllHandler)
        acronymsRoute.post(Acronym.self, use: createHandler)
        acronymsRoute.get(Acronym.parameter, use: getHandler)
        acronymsRoute.put(Acronym.parameter, use: updateHandler)
        acronymsRoute.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoute.get("search", use: searchHandler)
        acronymsRoute.get("first", use: getFirstHandler)
        acronymsRoute.get("sorted", use: sortedHandler)
        acronymsRoute.get(Acronym.parameter, "user",  use: getUserHandler)
        
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    // Simplified create handling method
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    // old create method.
//    func createHandler(_ req: Request) throws -> Future<Acronym> {
//        return try req.content
//            .decode(Acronym.self)
//            .flatMap(to: Acronym.self) { acronym in
//                return acronym.save(on: req)
//        }
//    }
    
    // executa um select acronym where
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    // executa Update
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
    return try flatMap(to: Acronym.self,
                       req.parameters.next(Acronym.self),
                       req.content.decode(Acronym.self)) {
                        acronym, updatedAcronym in
                        acronym.short = updatedAcronym.short
                        acronym.long = updatedAcronym.long
                        acronym.userID = updatedAcronym.userID
                        return acronym.save(on: req)
        }
    }
    
    // executa um delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    // performs search
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
    guard let searchTerm = req.query[String.self, at: "term"] else {
        throw Abort(.badRequest)
        }
    // Busca um parametro individual
    // return try Acronym.query(on: req)
    //.filter(\.short == searchTerm)
    // busca multiplos parametros
    return try Acronym.query(on: req).group(.or) { or in
        try or.filter(\.short == searchTerm)
        try or.filter(\.long == searchTerm)
        }.all()
    }
    
    // returns the first
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
        }
    }
    // sort the results
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                try acronym.user.get(on: req)
            }
    }
}
