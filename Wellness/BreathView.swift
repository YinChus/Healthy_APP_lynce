import SwiftUI
import Foundation
import Charts

struct BloodSugarRecordView: View {
    @ObservedObject var viewModel = BloodSugarVM()
    @State var showAddPage = false
    
    var filteredRecentBloodSugarRecords: [BloodSugarModel.BloodSugar] {
        let currentDate = Date()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: currentDate)!
        
        return viewModel.bloodSugarRecords
            .filter { record in
                return record.date >= sevenDaysAgo
            }
            .sorted { $0.date > $1.date } // Sort records by date in descending order
    }
    
    
    var filteredPastBloodSugarRecords: [BloodSugarModel.BloodSugar] {
        let currentDate = Date()
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: currentDate)!
        
        return viewModel.bloodSugarRecords
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
                    
                    Chart(filteredRecentBloodSugarRecords){
                        bloodSuar in
                        PointMark(x: .value("Date",dateFormatTimeChart(bloodSuar.date)), y: .value("level",bloodSuar.level))
                        
                    }
                    .chartXScale(domain:getLastSevenDaysFormatted())
                    .padding(.vertical)
                    
                    
                    ForEach(filteredRecentBloodSugarRecords){ record in
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
                                    Text("血糖")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(record.level) 毫摩尔/升")
                                }
                                Divider()
                                HStack{
                                    Text("用餐时间")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(record.postMeal ? "饭后" : "饭前")
                                } 
                            }
                            
                        }
                    }
                    .onDelete(perform: delete)
                    if filteredPastBloodSugarRecords.count != 0{
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
                    
                    
                    ForEach(filteredPastBloodSugarRecords){ record in
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
                                    Text("血糖")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(record.level) 毫摩尔/升")
                                }
                                Divider()
                                HStack{
                                    Text("用餐时间")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(record.postMeal ? "饭后" : "饭前")
                                } 
                            }
                            
                        }
                    }
                    .onDelete(perform: delete)
                    
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("血糖记录")
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
                AddBloodSugarView(showAddPage: $showAddPage, viewModel: viewModel)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.removeBloodSugarRecords(at: offsets)
    }
}

struct AddBloodSugarView: View {
    @Binding var showAddPage: Bool
    @State private var bloodSugarLevel = ""
    @State private var date = Date()
    @State private var mealOption = 0
    let mealOptions = ["饭前", "饭后"]
    @ObservedObject var viewModel: BloodSugarVM
    
    var body: some View {
        NavigationView{
            Form {
                DatePicker("日期", selection: $date, displayedComponents: .date)
                DatePicker("时间", selection: $date, displayedComponents: .hourAndMinute)
                
                HStack{
                    Text("血糖")
                    Spacer()
                    TextField("血糖", text: $bloodSugarLevel)
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    
                    Text("(毫摩尔/升)")
                }
                HStack{
                    Text("用餐时间")
                    Picker("用餐时间", selection: $mealOption) {
                        ForEach(0 ..< mealOptions.count) {
                            Text(self.mealOptions[$0])
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.leading)
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
                        viewModel.addBloodSugarRecord(date: date, level: Int(bloodSugarLevel) ?? 0, postMeal: mealOption == 1)
                        showAddPage = false
                    }
                    .disabled(bloodSugarLevel == "")
                }
            }
        }
    }
}

struct BloodSugarModel : Codable{
    private(set) var bloodSugarRecords: Array<BloodSugar>
    
    init(){
        bloodSugarRecords = Array<BloodSugar>()
    }
    
    struct BloodSugar: Identifiable, Hashable, Codable{
        var date: Date
        var level: Int
        var postMeal: Bool
        var id: UUID
    }
    
    func json() throws -> Data{
        return try JSONEncoder().encode(self)
    }
    
    init(json:Data) throws {
        self = try JSONDecoder().decode(BloodSugarModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf:url)
        self = try BloodSugarModel(json: data)
    }
    
    mutating func addBloodSugarRecord(date: Date, level: Int, postMeal: Bool) {
        let newRecord = BloodSugar(date: date, level: level, postMeal: postMeal, id: UUID())
        bloodSugarRecords.append(newRecord)
    }
    
    mutating func removeBloodSugarRecords(at offsets: IndexSet) {
        offsets.forEach { index in
            bloodSugarRecords.remove(at: index)
        }
    }
}

class BloodSugarVM: ObservableObject {
    @Published private var model : BloodSugarModel{
        didSet{
            autosave()
        }
    }
    
    init(){
        if let url = Autosave.url, let autosavedText = try? BloodSugarModel(url: url){
            model = autosavedText
        }else{
            model = BloodSugarModel()
        }
    }
    
    var bloodSugarRecords: Array<BloodSugarModel.BloodSugar>{
        return model.bloodSugarRecords
    }
    
    func addBloodSugarRecord(date: Date, level: Int, postMeal: Bool) {
        model.addBloodSugarRecord(date: date, level: level, postMeal: postMeal)
    }
    
    func removeBloodSugarRecords(at offsets: IndexSet) {
        model.removeBloodSugarRecords(at: offsets)
    }
    
    private struct Autosave{
        static let filename = "bloodSugarRecords"
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

func timeFormatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

func dateFormatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY年M月d日"
    return formatter.string(from: date)
}

func dateFormatTimeChart(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M.dd"
    return formatter.string(from: date)
}
