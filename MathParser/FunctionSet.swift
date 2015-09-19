//
//  FunctionSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/18/15.
//
//

import Foundation

internal class FunctionSet {
    private var functionsByName: Dictionary<String, FunctionRegistration>
    private let caseSensitive: Bool
    
    internal init(usesCaseSensitiveFunctions: Bool) {
        caseSensitive = usesCaseSensitiveFunctions
        let functions = Function.standardFunctions.map { FunctionRegistration(function: $0, caseSensitive: usesCaseSensitiveFunctions) }
        
        var functionsByName = Dictionary<String, FunctionRegistration>()
        functions.forEach { reg in
            reg.names.forEach {
                functionsByName[$0] = reg
            }
        }
        self.functionsByName = functionsByName
    }
    
    internal func normalize(name: String) -> String {
        return caseSensitive ? name : name.lowercaseString
    }
    
    private func registeredFunctionForName(name: String) -> FunctionRegistration? {
        let casedName = normalize(name)
        return functionsByName[casedName]
    }
    
    internal func functionForName(name: String) -> Function? {
        return registeredFunctionForName(name)?.function
    }
    
    internal func addAlias(alias: String, forFunctionName name: String) throws {
        guard registeredFunctionForName(alias) == nil else {
            throw FunctionRegistrationError.FunctionAlreadyExists(alias)
        }
        guard let registration = registeredFunctionForName(name) else {
            throw FunctionRegistrationError.FunctionDoesNotExist(name)
        }
        
        let casedAlias = normalize(alias)
        registration.addAlias(casedAlias)
        functionsByName[casedAlias] = registration
    }
    
    internal func registerFunction(function: Function) throws {
        let registration = FunctionRegistration(function: function, caseSensitive: caseSensitive)
        
        // we need to make sure that every name is accounted for
        for name in registration.names {
            guard registeredFunctionForName(name) == nil else {
                throw FunctionRegistrationError.FunctionAlreadyExists(name)
            }
        }
        
        registration.names.forEach {
            self.functionsByName[$0] = registration
        }
    }
}

private class FunctionRegistration {
    var names: Set<String>
    let function: Function
    
    init(function: Function, caseSensitive: Bool) {
        self.function = function
        
        var names = Set<String>()
        names.unionInPlace(function.aliases.map { caseSensitive ? $0.lowercaseString : $0 })
        names.insert(caseSensitive ? function.name.lowercaseString : function.name)
        self.names = names
    }
    
    func addAlias(name: String) {
        names.insert(name)
    }
}
