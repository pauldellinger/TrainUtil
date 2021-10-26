//
//  NextTrain.swift
//  NextTrain
//
//  Created by Paul Dellinger on 10/21/21.
//

import WidgetKit
import SwiftUI

struct wmataPredictionResponse: Codable{
    var Trains: [wmataPrediction]
}
struct wmataPrediction: Codable {
    var Car: String
    var Destination: String
    var DestinationCode: String
    var DestinationName: String
    var Group: String
    var Line: String
    var LocationCode: String
    var LocationName: String
    var Min: String
}
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), exampleText: "placeholder", predictions: [PredictionDisplay]())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), exampleText: "snapshot", predictions: [PredictionDisplay]())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//        entries.append(SimpleEntry(date: Date(), exampleText: "hello timeline" + String(NSDate().timeIntervalSince1970)))
//        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 15, to: Date())!
//        completion(Timeline(entries: entries, policy: .after(nextUpdateDate)))
        Provider.getNextTrain(stationCode: Provider.ROSSLYN_STATION_CODE, destinationCode: Provider.SV_WEST, completionHandler: completion)

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, exampleText: "timeline")
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
    }
    static let ROSSLYN_STATION_CODE = "C05";
    static let MCLEAN_STATION_CODE = "N01";
    static let SV_WEST = "N06";
    static let SV_EAST = "G05";
    
    static func getNextTrain(stationCode: String, destinationCode: String, completionHandler:@escaping(_ data: Timeline<SimpleEntry>) -> ()){
        var url = "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/"
        url += stationCode
        url += "?DestinationCode=" + destinationCode
        var trainPredictionRequest = URLRequest(url: URL(string:url)!)
        trainPredictionRequest.httpMethod = "GET"
        trainPredictionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let API_KEY = Bundle.main.infoDictionary?["WMATA_API_KEY"] as! String
        trainPredictionRequest.addValue(API_KEY, forHTTPHeaderField: "api_key")
        var entries: [SimpleEntry] = []
        
        let task = URLSession.shared.dataTask(with: trainPredictionRequest) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                completionHandler(Timeline(entries: entries, policy:.atEnd))
                return
            }
            let jsonDecoder = JSONDecoder()
            do{
                let parsedJSON = try jsonDecoder.decode(wmataPredictionResponse.self, from: data)
                let now = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss:"
                var predictionsDisplay = [PredictionDisplay]()
                for i in 0...parsedJSON.Trains.count - 1{
                    let prediction = parsedJSON.Trains[i]
                    // filter for silver line trains headed west
                    if prediction.Line == "SV" && prediction.Group == "2"{
                    let destination = prediction.Destination
                        let arrivalTime: Int?
                        switch prediction.Min {
                        case "ARR":
                            arrivalTime = 0
                        case "BRD":
                            arrivalTime = 0
                        default:
                            arrivalTime = Int(prediction.Min) ?? nil
                        }
                        predictionsDisplay.append(PredictionDisplay(destination: destination, relativeArrivalTime: arrivalTime))
                        
                    }

                }
                let entry = SimpleEntry(date: now, exampleText: "example", predictions: predictionsDisplay)
                entries.append(entry)
            }catch{
                print("Decoding error")
            }
            completionHandler(Timeline(entries: entries, policy: .never))
        }
        
        task.resume()
        
        
        
    }
}



struct PredictionDisplay: Hashable {
    var destination: String
    var relativeArrivalTime: Int?
    
    func display()->String{
        if relativeArrivalTime == 0 {
            return destination + ": " + "ARR"
        }
        return destination + ": " + String(relativeArrivalTime!)
    }
}
struct SimpleEntry: TimelineEntry {
    let date: Date
    let exampleText: String
    let predictions: [PredictionDisplay]
    
    func displayLastUpdated()-> Text{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return Text(dateFormatter.string(from: self.date))
    }
    
}

struct NextTrainEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch family {
                case .systemMedium: Text(entry.date, style: .time)
//                case .systemMedium: GameStatusWithLastTurnResult(gameStatus)
//                case .systemLarge: GameStatusWithStatistics(gameStatus)
        default:
            ForEach(entry.predictions, id: \.self) { prediction in
            Text(prediction.display())
            }
            entry.displayLastUpdated()
            
        }
        
    }
}

@main
struct NextTrain: Widget {
    let kind: String = "NextTrain"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NextTrainEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
    
}

struct NextTrain_Previews: PreviewProvider {
    static var previews: some View {
        NextTrainEntryView(entry: SimpleEntry(date: Date(), exampleText: "preview", predictions: [PredictionDisplay]()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
