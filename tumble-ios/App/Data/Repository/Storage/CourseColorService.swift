//
//  ColorStore.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/29/22.
//

import Foundation
import SwiftUI

typealias CourseAndColorDict = [String : String]

class CourseColorService: ObservableObject, CourseColorServiceProtocol {
    
    private let serialQueue = OperationQueue()
    @Published public var courseColors: CourseAndColorDict = [:]
    
    init() {
        // Limit amount of concurrent operations to avoid
        // potentially strange state behavior
        serialQueue.maxConcurrentOperationCount = 1
        serialQueue.qualityOfService = .background
        load(completion: { _ in })
    }
    
    private func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: false)
            .appendingPathComponent("colors.data")
    }
    
    func getCourseColors() -> CourseAndColorDict {
        return courseColors
    }

    func replace(for event: Response.Event, with color: Color, completion: @escaping (Result<Int, Error>) -> Void) -> Void {
        serialQueue.addOperation { [weak self] in
            guard let self else { return }
            do {
                let fileURL = try self.fileURL()
                let encoder = JSONEncoder()
                do {
                    var newCourses = courseColors
                    newCourses[event.course.id] = color.toHex()
                    let data = try encoder.encode(newCourses)
                    try data.write(to: fileURL)
                    DispatchQueue.main.async {
                        self.courseColors = newCourses
                        completion(.success(1))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func load(completion: @escaping (Result<CourseAndColorDict, Error>) -> Void) {
        serialQueue.addOperation {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([:]))
                        }
                        return
                    }
                let courses = try decoder.decode(CourseAndColorDict.self, from: file.availableData)
                DispatchQueue.main.async {
                    self.courseColors = courses
                    completion(.success(courses))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    

    func save(coursesAndColors: [String : String], completion: @escaping (Result<Int, Error>) -> Void) {
        serialQueue.addOperation { [weak self] in
            guard let self else { return }
            do {
                let fileURL = try self.fileURL()
                let encoder = JSONEncoder()
                do {
                    let finalCourseColorDict = self.courseColors.merging(coursesAndColors) { (_, new) in new }
                    let data = try encoder.encode(finalCourseColorDict)
                    try data.write(to: fileURL)
                    DispatchQueue.main.async {
                        self.courseColors = finalCourseColorDict
                        completion(.success(1))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func removeAll(completion: @escaping (Result<Int, Error>) -> Void) {
        serialQueue.addOperation {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(1))
                    }
                    return
                }
                var courses = try decoder.decode(CourseAndColorDict.self, from: file.availableData)
                
                courses.removeAll()
                
                let data = try encoder.encode(courses)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    self.courseColors = courses
                    completion(.success(courses.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
        }
    }
    
    func remove(removeCourses: [String], completion: @escaping (Result<Int, Error>)->Void) {
        serialQueue.addOperation {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var courses = try decoder.decode(CourseAndColorDict.self, from: file.availableData)
                
                for courseId in removeCourses {
                    courses.removeValue(forKey: courseId)
                }
                
                let data = try encoder.encode(courses)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    self.courseColors = courses
                    completion(.success(courses.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
        }
    }
}
