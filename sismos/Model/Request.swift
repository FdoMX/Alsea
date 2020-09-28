//
//  Request.swift
//  sismos
//
//  Created by Familia Juarez Martinez on 9/25/20.
//

import Foundation

enum ResponseError: Error {
    case noData
    case CanNoProcess
}

struct Request {
    let resourceURL: URL

    init(startTime: String, endTime: String, minMagnitude: Float) {
        let resourceString = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=\(startTime)&endtime=\(endTime)&minmagnitude=\(minMagnitude)"
        
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func getStations (completion: @escaping(Result<[Properties], ResponseError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let recordsResponse = try decoder.decode(Response.self, from: jsonData)
                let recordsDetails = recordsResponse.features
                print("Array of eartquakes: \(recordsDetails)")
                completion(.success(recordsDetails))
            }
            catch {
                completion(.failure(.CanNoProcess))
            }
        }
        dataTask.resume()
    }
}
