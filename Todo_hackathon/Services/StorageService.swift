import Foundation

protocol StorageService: Sendable {
    func save(_ task: Task) async throws
    
    func loadAll() async throws -> [Task]
    
    func delete(_ taskId: UUID) async throws
    

    func update(_ task: Task) async throws
}

enum StorageError: LocalizedError {
    case fileNotFound
    case encodingFailed
    case decodingFailed
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            "Storage file not found"
        case .encodingFailed:
            "Failed to encode tasks"
        case .decodingFailed:
            "Failed to decode tasks"
        case .saveFailed(let error):
            "Failed to save tasks: \(error.localizedDescription)"
        }
    }
}

final class StorageServiceImpl: StorageService {
    private nonisolated(unsafe) let fileManager: FileManager
    private let fileName = "tasks.json"
    
    nonisolated init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    private func fileURL() throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw StorageError.fileNotFound
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func save(_ task: Task) async throws {
        var tasks = try await loadAll()
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        
        try await saveAll(tasks)
    }
    
    func loadAll() async throws -> [Task] {
        let url = try fileURL()
        
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            return tasks
        } catch {
            throw StorageError.decodingFailed
        }
    }
    
    func delete(_ taskId: UUID) async throws {
        var tasks = try await loadAll()
        tasks.removeAll { $0.id == taskId }
        try await saveAll(tasks)
    }
    
    func update(_ task: Task) async throws {
        try await save(task)
    }
    
    private func saveAll(_ tasks: [Task]) async throws {
        let url = try fileURL()
        
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: url, options: [.atomic])
        } catch {
            throw StorageError.saveFailed(error)
        }
    }
}
