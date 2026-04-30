//
//  BloodPressure.swift
//  Wellness
//
//  Created by Jianhui Tan on 2023/8/25.
//

import SwiftUI
import Foundation
import Charts

struct BloodPressure: View {
    @ObservedObject var viewModel = BloodPressureVM()
    @State var showAddPage = false
    
    var filteredRecentBloodPressureRecords: [BloodPressureModel.BloodPressure] {
        let currentDate = Date()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: currentDate)!
        
        return viewModel.bloodPressureRecords
            .filter { record in
                return record.date >= sevenDaysAgo
            }
            .sorted { $0.date > $1.date } // Sort records by date in descending order
    }
    
    
    var filteredPastPressureSugarRecords: [BloodPressureModel.BloodPressure] {
        let currentDate = Date()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: currentDate)!
        
        return viewModel.bloodPressureRecords
            .filter { record in
                return record.date < sevenDaysAgo
            }
            .sorted { $0.date > $1.date } // Sort records by date in descending order
    }
    
    
    
    
    func getLastSevenDaysFormatted() -> [String] {
        var formattedDates: [String] = []
        
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i-6, to: now) {
                let formattedDate = dateFormatTimeChart(date)
                formattedDates.append(formattedDate)
            }
        }
        
        return formattedDates
    }
    
    
    
    
    
    var body: some View {
        VStack{
            
            
            VStack{
                
                List {
                    
                    Chart(filteredRecentBloodPressureRecords){
                        bloodPressure in
                        PointMark(x: .value("Date",dateFormatTimeChart(bloodPressure.date)), y: .value("systolic",bloodPressure.systolic))
                        PointMark(x: .value("Date",dateFormatTimeChart(bloodPressure.date)), y: .value("diastolic",bloodPressure.diastolic))
                            .foregroundStyle(.gray)
                        
                    }
                    .chartXScale(domain:getLastSevenDaysFormatted())
                    .padding(.vertical)
                    
                    
                    ForEach(filteredRecentBloodPressureRecords){ record in
                        Section(dateFormatTime(record.date)){
                            VStack{
                                HStack{
                                    Text("时间")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(timeFormatTime(record.date))
                                }
                                Divider()
                                HStack{
                                    Text("收缩压")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(record.systolic) ")
                                }
                                Divider()
                                HStack{
                                    Text("舒张压")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(record.diastolic) ")
                                }
                            }
                            
                        }
                    }
                    .onDelete(perform: delete)
                    if filteredPastPressureSugarRecords.count != 0{
                        HStack{
                            Rectangle()
                                .frame(height:1)
                            Text("7天前")
                            Rectangle()
                                .frame(height:1)
                        }
                        .opacity(0.5)
                        .bold()
                        .listRowBackground(Color.clear)
                    }else{
                        HStack{
                            Spacer()
                           Text("暂无数据")
                            Spacer()
                        }
                        .padding()
                        .opacity(0.5)
                        .bold()
                        .listRowBackground(Color.clear)
                    }
                    
                    
                    ForEach(filteredPastPressureSugarRecords){ record in
                        Section(dateFormatTime(record.date)){
                            VStack{
                                HStack{
                                    Text("时间")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(timeFormatTime(record.date))
                                }
                                Divider()
                                HStack{
                                    Text("收缩压")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(record.systolic) ")
                                }
                                Divider()
                                HStack{
                                    Text("舒张压")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(record.diastolic) ")
                                }
                            }
                            
                        }
                    }
                    .onDelete(perform: delete)
                    
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("血压记录")
                //                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        
                        Button{
                            showAddPage = true
                        }label: {
                            Image(systemName: "plus.circle")
                        }
                        
                        
                        
                    }
                }
                
            }
            
            .sheet(isPresented: $showAddPage) {
                AddBloodPressureView(showAddPage: $showAddPage, viewModel: viewModel)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.removeBloodPressureRecords(at: offsets)
    }
}

struct AddBloodPressureView: View {
    @Binding var showAddPage: Bool
    @State private var systolic = ""
    @State private var diastolic = ""
    @State private var date = Date()
    
    @ObservedObject var viewModel: BloodPressureVM
    
    var body: some View {
        NavigationView{
            Form {
                DatePicker("日期", selection: $date, displayedComponents: .date)
                DatePicker("时间", selection: $date, displayedComponents: .hourAndMinute)
                
                HStack{
                    Text("收缩压")
                    Spacer()
                    TextField("收缩压", text: $systolic)
                        .frame(width: 150)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    
                    
                }
                
                HStack{
                    Text("舒张压")
                    Spacer()
                    TextField("舒张压", text: $diastolic)
                        .frame(width: 150)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    
                    
                }
               
                
            }
            .navigationTitle("添加血糖记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        showAddPage = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.addBloodPressureRecord(date: date, systolic: Int(systolic) ?? 0, diastolic: Int(diastolic) ?? 0)
                        showAddPage = false
                    }
                    .disabled(diastolic == "" || systolic == "")
                }
            }
        }
    }
}

struct BloodPressureModel : Codable{
    private(set) var bloodPressureRecords: Array<BloodPressure>
    
    init(){
        bloodPressureRecords = Array<BloodPressure>()
    }
    
    struct BloodPressure: Identifiable, Hashable, Codable{
        var date: Date
        var systolic: Int
        var diastolic: Int
        var id: UUID
    }
    
    func json() throws -> Data{
        return try JSONEncoder().encode(self)
    }
    
    init(json:Data) throws {
        self = try JSONDecoder().decode(BloodPressureModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf:url)
        self = try BloodPressureModel(json: data)
    }
    
    mutating func addBloodPressureRecord(date: Date, systolic: Int, diastolic: Int) {
        let newRecord = BloodPressure(date: date, systolic: systolic, diastolic: diastolic, id: UUID())
        bloodPressureRecords.append(newRecord)
    }
    
    mutating func removeBloodPressureRecords(at offsets: IndexSet) {
        offsets.forEach { index in
            bloodPressureRecords.remove(at: index)
        }
    }
}

class BloodPressureVM: ObservableObject {
    @Published private var model : BloodPressureModel{
        didSet{
            autosave()
        }
    }
    
    init(){
        if let url = Autosave.url, let autosavedText = try? BloodPressureModel(url: url){
            model = autosavedText
        }else{
            model = BloodPressureModel()
        }
    }
    
    var bloodPressureRecords: Array<BloodPressureModel.BloodPressure>{
        return model.bloodPressureRecords
    }
    
    func addBloodPressureRecord(date: Date, systolic: Int, diastolic: Int) {
        model.addBloodPressureRecord(date: date, systolic: systolic, diastolic: diastolic)
    }
    
    func removeBloodPressureRecords(at offsets: IndexSet) {
        model.removeBloodPressureRecords(at: offsets)
    }
    
    private struct Autosave{
        static let filename = "bloodPressureRecords"
        static var url: URL?{
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
    }
    
    private func autosave(){
        if let url = Autosave.url{
            save(to: url)
        }
    }
    
    private func save(to url: URL){
        let thisfunction = "\(String(describing: self)).\(#function)"
        do{
            let data: Data = try model.json()
            try data.write(to: url)
            print("\(thisfunction) success!")
        }catch{
            print("\(thisfunction) error = \(error)")
        }
    }
}
