//
//  MyView.swift
//  Wellness
//
//  Created by Jianhui Tan on 2023/8/26.
//

import SwiftUI


struct MyView: View {
    var body: some View {
        
        NavigationView{
            
            
            List{
                
                HStack{
                    Spacer()
                    VStack{
                        Image("Watermelon")
                            .resizable()  // 使图片可以调整大小
                            .aspectRatio(contentMode: .fill)  // 保持原始图片的纵横比，并填充可用空间
                            .frame(width: 100, height: 100)  // 指定图片的大小
                            .clipShape(Circle())  // 应用圆形蒙版
                        
                        Text("Name")
                            .font(.title)
                            .bold()
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                
                Section(){
                    NavigationLink(destination: EmptyView()){
                        Text("我的体质")
                    }
                    NavigationLink(destination: EmptyView()){
                        Text("我的家人")
                    }
                    NavigationLink(destination: EmptyView()){
                        Text("我的疾病")
                    }
                }
//                .listRowBackground(ThemeColor.boxColor)
                .foregroundColor(ThemeColor.tint)
                .tint(ThemeColor.tint)
                
                Section(){
                    NavigationLink(destination: EmptyView()){
                        Text("意见反馈")
                    }
                    NavigationLink(destination: EmptyView()){
                        Text("分享软件")
                    }
                }
                .listRowBackground(ThemeColor.boxColor)
                .foregroundColor(ThemeColor.tint)
                .tint(ThemeColor.tint)
                
                
            }
//            .scrollContentBackground(.hidden)
//            .background(ThemeColor.background)
            .tint(ThemeColor.tint)
            
        }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
    }
}
