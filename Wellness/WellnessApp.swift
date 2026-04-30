//
//  PhysicalRecord.swift
//  Wellness
//
//  Created by Jianhui Tan on 2023/8/19.
//

import Foundation
import SwiftUI

struct PhysicalRecordView: View {
    var body: some View {
        ScrollView{
            
            VStack{
                
                
                NavigationLink(destination: BloodSugarRecordView()){
                    HStack{
                        RecordCardView(name:"Poster4", content: "还未记录过", color: .red)
                    }
                }
                NavigationLink(destination: BloodPressure()){
                    HStack{
                        RecordCardView(name:"Poster3", content: "己记录195天", color: .blue)
                    }
                }
                
                NavigationLink(destination: HealthGuideView()){
                    HStack{
                        RecordCardView(name:"Poster2", content: "已完成11天", color: .orange)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("体质记录")
    }
}



struct PhysicalRecordView_Previews: PreviewProvider {
    static var previews: some View {
        PhysicalRecordView()
    }
}



struct RecordCardView: View {
    let name: String
    let content: String
    let color: Color
    
    var body: some View {
        
            ZStack(alignment: .leading){
                
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(15, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 120, height: 30)
                        .foregroundColor(color)
                        .opacity(0.6)
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth:1)
                        .frame(width: 120, height: 30)
                    Text(content)
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding()
                .offset(y:28)
            
        }
        
    }
}


