import SwiftUI

struct ContentView: View {
    
    @State var isShowingMyView = false
    
    var body: some View {
        
        NavigationView{
            
            
            ZStack{
                Image("mainPageBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(.all)
                
                VStack {
                    
                    HStack(alignment: .bottom){
                        Text("养生通")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                        Button{
                            isShowingMyView = true
                        }label: {
                            Image(systemName: "person.circle")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $isShowingMyView) {
                            MyView()
                        }
                        
                    }
                    
                    NavigationLink(destination: SolarTermView(isShowingDetails: true)){
                        SolarTermView(isShowingDetails: false)
                            .cornerRadius(20)
                            .frame(height:90)
                            .padding(.bottom,10)
                    }
                    
                    
                    NavigationLink(destination:ChineseHourDetailView()){
                        ChineseHourView()
                            .cornerRadius(20)
                    }
                   
                        
                    
                    
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]){
                        
                        NavigationLink(destination: PhysicalRecordView()) {
                            
                            MainPageCard(title: "体质记录", icon: "heart.fill")
                        }
                        .padding(4)
                        
                        
                        NavigationLink(destination: TestList()){
                            MainPageCard(title: "体质测试", icon: "testtube.2")
                        }
                        .padding(4)
                        
                        
                        
                        NavigationLink(destination:
                                        BaikeView().tint(ThemeColor.tint)
                            .navigationTitle("医食百科")
                            .navigationBarTitleDisplayMode(.inline)
                                       
                        ){
                            MainPageCard(title: "医食百科",icon: "books.vertical.fill")
                        }
                        .padding(4)
                        
                        
                        
                        NavigationLink(destination: BreathListView()){
                            MainPageCard(title: "自然养生", icon: "leaf.fill")
                        }
                        .padding(4)
                    }
                    .padding(.horizontal, -4)
                    .padding(.bottom)
                    
                    NavigationLink(destination:CaptureView().tint(ThemeColor.tint)){
                        ZStack{
                            
                            
                            
                            HStack(){
                                Spacer()
                                Image(systemName: "camera")
                                    .bold()
                                Text("拍照识图")
                                    .bold()
                                
                                Spacer()
                            }
                            .padding()
                            
                            
                            
                        }
                        .foregroundColor(ThemeColor.boxColor)
                        .background(
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(ThemeColor.tint)
                                
                            }
                        )
                        
                        
                    }
                    
                }
                
                .padding()
                .navigationTitle("养生通")
                .navigationBarHidden(true)
                //         .background(
                //            Image("mainPageBG")
                //                .resizable()
                //                .aspectRatio(contentMode: .fill)
                //                .ignoresSafeArea(.all)
                //
                //         )
                
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button{
                            isShowingMyView = true
                        }label: {
                            Image(systemName: "person.circle")
                                .font(.largeTitle)
                        }
                        .sheet(isPresented: $isShowingMyView) {
                            MyView()
                        }
                        
                        
                    }
                }
                .tint(ThemeColor.tint)
            }
            
        
    }
        .navigationBarBackButtonHidden(true)
//        .preferredColorScheme(ColorScheme.dark)
    }
}



struct MainPageCard: View {
    let title: String
    let icon: String
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.clear)
                .aspectRatio(1.8,contentMode: .fill)
            
            VStack(spacing:10){
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .bold()
            }
            
            
        }
        .foregroundColor(.white)
        .background(
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.clear)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 2)
                    .padding(0)
                    .foregroundColor(.white)
            }
        )
        
    }
}

struct MainPageCard_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ThemeColor{
    
    static let background = Color(hex: "FFFBF0")
    static let tint = Color(hex: "5B9942")
    static let boxColor = Color(hex: "FDFEF9")
}
