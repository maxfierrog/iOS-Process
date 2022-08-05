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
     theoretically take. 0% means they are the same string, while 100% percent
     means you need to rewrite the entire 'to' string to get it from self. */
    public func similarityPercentage(to: String) -> Float {
        let distance = Float(self.levenshtein(to))
        let max = Float(max(self.count, to.count))
        return String.activationFunction(distance/max, parameter: 1)
    }
    
    /** Activation function which gives greater weight to high percetnages than
     lower ones. A cost function can be defined as Cost(parameter) for future
     training of the string similarity model for Process task descriptions. The
     parameter should be in the interval of (0, inf), where 1 is giving equal
     weight to all percentages, and close to 0 is giving more and more weight
     to lower percentages. Undefined behavior if paremeter is outside this
     interval. */
    private static func activationFunction(_ percentage: Float, parameter: Float) -> Float {
        return pow(percentage, parameter)
    }
}


/** Helper methods to the due date estimation feature. */
class DueDateUtils {
    
    /** Returns an estimate for when a task with TASKTITLE and TASKDESCRIPTION
     would be completed based on USER's historic performance with similar tasks. */
    public static func getDueDateEstimate(taskTitle: String, taskDescription: String, user: User) -> Date {
        
        // All the tasks that the user finished
        let completedTasks = DueDateUtils.getCompletedTasks(user: user)
        
        // If there are no completed tasks, there is no data to analyze
        guard completedTasks.count != 0 else {
            return Date() // FIXME: Return something meaningful if there is no data to analyze
        }
        
        /* Compute the average of completion times, weighted by similarity */
        
        var completionTimes: [Float] = []
        var weights: [Float] = []
        var weightedSum: Float = 0.0
        var weightSum: Float = 0.0
        
        // Task similarity parameters
        var currTitleSimilarity: Float
        var currDescriptionSimilarity: Float
        var currTaskSimilarityWeight: Float
        
        // Use the levenshtein distance to quantify similarity
        for task in completedTasks {
            currTitleSimilarity = task.data.name.similarityPercentage(to: taskTitle)
            if task.data.description == nil {
                currDescriptionSimilarity = "".similarityPercentage(to: taskDescription)
            } else {
                currDescriptionSimilarity = task.data.description!.similarityPercentage(to: taskDescription)
            }
            
            // Average between name and description similarities
            currTaskSimilarityWeight = currTitleSimilarity + currDescriptionSimilarity / 2
            weights.append(currTaskSimilarityWeight)
            weightSum += currTaskSimilarityWeight
        }
        
        // Populate completion times array
        for task in completedTasks {
            completionTimes.append(DueDateUtils.secondsToCompletion(task: task))
        }
        
        // Compute weighted sum
        for index in completionTimes.indices {
            weightedSum += completionTimes[index] * weights[index]
        }
        
        // Estimate in the amount of seconds it will take to finish TASK
        let secondsToCompletionEstimate: Double = Double(weightedSum / weightSum)
        
        return Date(timeIntervalSinceNow: secondsToCompletionEstimate)
    }
    
    /** Obtains the tasks which a user has completed by putting all the ones
     which have a due date into an array. */
    private static func getCompletedTasks(user: User) -> [Task] {
        var taskList: [Task] = []
        var completedTasks: [Task] = []
        for taskItem in user.taskList.items {
            taskList.append(taskItem.task)
        }
        for task in taskList {
            if task.data.dateCompleted != nil {
                completedTasks.append(task)
            }
        }
        return completedTasks
    }
    
    /** Calculates the amount of seconds spanned from when TASK was created
     to when it was marked completed. */
    private static func secondsToCompletion(task: Task) -> Float {
        let completionDate = task.data.dateCompleted!
        let startedDate = task.data.dateCreated
        let diffSeconds = completionDate.timeIntervalSinceReferenceDate - startedDate.timeIntervalSinceReferenceDate
        return Float(diffSeconds)
    }
}
