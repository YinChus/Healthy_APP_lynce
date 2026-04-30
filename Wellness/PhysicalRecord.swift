//
//  HealthGuide.swift
//  Wellness
//
//  Created by Jianhui Tan on 2023/8/28.
//

import SwiftUI

struct HealthGuideView: View {
    var body: some View {
        
        ScrollView{
            VStack{
                
                VStack{
                    HStack{
                        Image(systemName: "figure.mind.and.body")
                        Text("按摩")
                        Spacer()
                        Text("已完成2次")
                    }
                    .padding(6)
                    .foregroundColor(.white)
                    .background(ThemeColor.tint)
                    
                    VStack{
                        HealthGuideCard(title: "公孙", subscribe: "按揉。2-3分钟", imageName: "gongsun")
                        Divider()
                        HealthGuideCard(title: "委中", subscribe: "身体坐直，手腕放松，轻轻按揉。2-3分钟。", imageName: "weizhong")
                        Divider()
                        HealthGuideCard(title: "合阳", subscribe: "用同侧拇指的指间关节敲击2-3分钟。", imageName: "heyang")
                        Divider()
                        HealthGuideCard(title: "承山", subscribe: "用同侧大拇指的指间关节垂直发力，敲击。2-3分钟。", imageName: "heyang")
                        
                        Button{
                            
                        }label: {
                            Text("完成按摩打卡")
                                .padding()
                                .padding(.horizontal)
                                .background(ThemeColor.tint)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    
                }
                .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 4)
                    .foregroundColor(ThemeColor.tint)
                )
                .cornerRadius(10)
                
                
                
            }//VStack
            .padding()
            .navigationTitle("我的养生计划")
        }//ScrollView
        
    }
}


struct HealthGuideCard: View {
    
    let title:String
    let subscribe:String
    let imageName:String
    
    var body: some View {
        HStack(spacing:10){
            Image(imageName)  // 从 Assets 中加载图片
                .resizable()
                    .scaledToFill()  // 填充整个frame，但可能会裁剪
                    .frame(width: 100, height: 100)
                    .clipped()  // 确保图片不超出框架
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
            VStack(alignment:.leading){
                Text(title)
                    .font(.title2)
                    .bold()
                Spacer(minLength: 0)
                Text(subscribe)
                    .foregroundColor(ThemeColor.tint)
                
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }
}


struct HealthGuideView_Previews: PreviewProvider {
    static var previews: some View {
        HealthGuideView()
    }
}
