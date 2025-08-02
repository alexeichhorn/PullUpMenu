//
//  ConcurrencyExtensions.swift
//  PullUpMenu
//
//  Created by Alexander Eichhorn on 02.08.2025.
//

import Foundation

extension DispatchQueue {
    
    /// only adds to async block when not running on main thread
    /// - note: using it for anything other than `DispatchQueue.main` doesn't make any difference
    func asyncIfNeeded(_ execute: @escaping @Sendable () -> Void) {
        if self == DispatchQueue.main && Thread.isMainThread {
            execute()
        } else {
            async(execute: execute)
        }
    }
    
}

extension MainActor {
    
    /// same as `DispatchQueue.main.asyncIfNeeded`, but with `MainActor` access guarantees for the code inside
    static func runAsync(_ body: @escaping @MainActor @Sendable () -> Void) {
        DispatchQueue.main.asyncIfNeeded {
            MainActor.assumeIsolated {
                body()
            }
        }
    }
    
    
    /// same as `DispatchQueue.main.sync`, but with `MainActor` access guarantees for the code inside
    static func runSync<T>(resultType: T.Type = T.self, _ body: @MainActor @Sendable () throws -> T) rethrows -> T where T: Sendable {
        if Thread.isMainThread {
            try MainActor.assumeIsolated {
                return try body()
            }
        } else {
            try DispatchQueue.main.sync {
                try MainActor.assumeIsolated {
                    return try body()
                }
            }
        }
    }
    
}
