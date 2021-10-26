//
//  TrainInfo.swift
//  TrainUtil
//
//  Created by Paul Dellinger on 10/19/21.
//

import Foundation
import WidgetKit
import SwiftUI

//struct TrainInfo {
//    static let ROSSLYN_STATION_CODE = "C05";
//    static let MCLEAN_STATION_CODE = "N01";
//    static let SV_WEST = "N06";
//    static let SV_EAST = "G05";
//    
//    static func getNextTrain(stationCode: String, destinationCode: String, completionHandler:@escaping(_ data: Timeline<Entry>) -> ()){
//        var url = "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/"
//        url += stationCode
//        url += "?DestinationCode=" + destinationCode
//        var trainPredictionRequest = URLRequest(url: URL(string:url)!)
//        trainPredictionRequest.httpMethod = "GET"
//        trainPredictionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let API_KEY = Bundle.main.infoDictionary?["WMATA_API_KEY"] as! String
//        trainPredictionRequest.addValue(API_KEY, forHTTPHeaderField: "api_key")
//        
//        
//        let task = URLSession.shared.dataTask(with: trainPredictionRequest) { data, response, error in
//          guard let data = data else {
//            print(String(describing: error))
//            return
//          }
//            completionHandler(SimpleEntry(date: Date(), exampleText: String(data)))
//        }
//
//        task.resume()
//        
//          
//        
//    }
////    static func main(){
////        getNextTrain(stationCode: ROSSLYN_STATION_CODE, destinationCode: SV_WEST)
////        print("hello world")
////    }
//}
