//
//  StringDistance.swift
//  process
//
//  Created by maxfierro on 8/5/22.
//

import Foundation


/** Extension  facilitating the determination of string distnaces for generating
 due date suggestion. */
extension String {
    
    /** Algorithm for levenshtein distance between a string an another, implemented
     as an instance method. The Levenshtein distance between two sequences is the
     number of operations (remove, insert, substitute) which must be performed on
     one string before it can be turned into the other. Less is closer. */
    public func levenshtein(_ other: String) -> Int {
        
        // Character count in both strings
        let sCount = self.count
        let oCount = other.count

        // Trivial if one of the two strings are empty
        guard sCount != 0 else {
            return oCount
        }
        guard oCount != 0 else {
            return sCount
        }

        // Constructing a matrix of oCount X sCount
        let line : [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat : [[Int]] = Array(repeating: line, count: sCount + 1)

        // Matrix gets indexed for counting (will only 'use' mat[x > 1][y > 1])
        for i in 0...sCount {
            mat[i][0] = i
        }
        for j in 0...oCount {
            mat[0][j] = j
        }

        // Determine if/which operation we need to do, add one to the count
        for j in 1...oCount {
            for i in 1...sCount {
                if self[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                } else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }
        
        // Return the count of the indices
        return mat[sCount][oCount]
    }

    /** Returns the amount of removals, insertions, or substitutions needed to
     transfrom S1 into S2, divided by the maximum amount of operations it could
     theoretically take. 100% means they are the same string, while 0 percent
     means you need to rewrite the entire 'to' string to get it from self. */
    public func similarityPercentage(to: String) -> Float {
        let distance = Float(self.levenshtein(to))
        let max = Float(max(self.count, to.count))
        return String.activationFunction(distance/max, parameter: 0.0)
    }
    
    /** Activation function which gives greater weight to high percetnages than
     lower ones. A cost function can be defined as Cost(parameter) for future
     training of the string similarity model for Process task descriptions. The
     parameter should be in the interval of (0, inf), where 1 is giving equal
     weight to all percentages, and close to 0 is giving more and more weight
     to lower percentages. */
    private static func activationFunction(_ percentage: Float, parameter: Float) -> Float {
        return percentage // FIXME: Should be percentage ^^ parameter
    }
}


class StringDistance {
    
    public static func getDueDateEstimate(taskTitle: String, taskDescription: String, user: User) -> Date {
        return Date()
    }
}
