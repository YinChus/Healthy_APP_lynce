import SwiftUI


struct ChineseHourView: View {
    @State private var currentDate: Date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let chineseHours = ["子时", "丑时", "寅时", "卯时", "辰时", "巳时", "午时", "未时", "申时", "酉时", "戌时", "亥时"]
    
    var body: some View {
        
        ZStack{
            
            
            HStack {
                
                ZStack {
                    ForEach(0..<12) { index in
                        RingSegment(currentHourInChinese: currentHourInChinese(currentDate).hour, hour: chineseHours[index], index: index)
                    }
                    .rotationEffect(.degrees(-90-15), anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    RingView(currentHourInChinese: currentHourInChinese(currentDate).hour, chineseHours: chineseHours)
                    
                    VStack(spacing:10){
                        
                        Text(currentHourInChinese(currentDate).time)
                            .font(.subheadline)
                        VStack{
                            Text(currentHourInChinese(currentDate).title + "经")
                            Text("当令")
                        }
                        .font(.title)
                        .bold()
                        Text(currentHourInChinese(currentDate).hour)
                            .font(.subheadline)
                    }
                    
                }
                Spacer(minLength: 0)
                Text(currentHourInChinese(currentDate).subtitle)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)
                    .frame(width: 120)
            }
            .foregroundColor(.white)
            .padding()
           
        }
        .background(currentHourInChinese(currentDate).color)
        
        .ignoresSafeArea(/*@START_MENU_TOKEN@*/.keyboard/*@END_MENU_TOKEN@*/, edges: /*@START_MENU_TOKEN@*/.bottom/*@END_MENU_TOKEN@*/)
        .onReceive(timer) { _ in
            self.currentDate = Date()
        }
    }
    
    
}


struct ChineseHourDetailView: View {
    @State private var currentDate: Date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let chineseHours = ["子时", "丑时", "寅时", "卯时", "辰时", "巳时", "午时", "未时", "申时", "酉时", "戌时", "亥时"]
    
    var body: some View {
        
        ZStack{
            Rectangle()
                .foregroundColor(currentHourInChinese(currentDate).color)
            
            VStack {
                
                ZStack {
                    ForEach(0..<12) { index in
                        RingSegment(currentHourInChinese: currentHourInChinese(currentDate).hour, hour: chineseHours[index], index: index)
                    }
                    .rotationEffect(.degrees(-90-15), anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    RingView(currentHourInChinese: currentHourInChinese(currentDate).hour, chineseHours: chineseHours)
                    
                    VStack(spacing:10){
                        
                        Text(currentHourInChinese(currentDate).time)
                            .font(.subheadline)
                        VStack{
                            Text(currentHourInChinese(currentDate).title + "经")
                            Text("当令")
                        }
                        .font(.title)
                        .bold()
                        Text(currentHourInChinese(currentDate).hour)
                            .font(.subheadline)
                    }
                    
                }
                
                
                Text(currentHourInChinese(currentDate).subtitle)
                    .font(.title3)
                    .bold()
                    .padding(.vertical)
                
                Text(currentHourInChinese(currentDate).details)
            }
            .foregroundColor(.white)
            .padding()
           
        }
//        .background(currentHourInChinese(currentDate).color)
        .ignoresSafeArea(.all)
        .onReceive(timer) { _ in
            self.currentDate = Date()
        }
    }
    
    
}

struct RingView: View {
    var currentHourInChinese: String
    var chineseHours: [String]
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                let angle = Angle(degrees: Double(index) * 30)
                let opacity = currentHourInChinese == chineseHours[index] ? 1.0 : 0.2
                Text(chineseHours[index])
                
                    .offset(x: 0, y: -80)
                    .rotationEffect(angle)
                    .opacity(opacity)
            }
        }
        .padding()
    }
}

struct RingSegment: View {
    var currentHourInChinese: String
    var hour: String
    var index: Int
    
    var body: some View {
        RingShape(index: index)
            .fill(currentHourInChinese == hour ? Color.white : Color.white.opacity(0.2))
            .frame(width: 200, height: 200)
    }
}

struct RingShape: Shape {
    var index: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startAngle = Angle(degrees: Double(index) * 30 + 1)
        let endAngle = Angle(degrees: Double(index + 1) * 30 - 1)
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - 6, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        
        return path
    }
}

struct ChineseHour{
    let hour: String
    let time : String
    let title: String
    let subtitle: String
    let details: String
    let color : Color
}

//func currentHourInChinese(_ date: Date) -> ChineseHour {
//    let hour = Calendar.current.component(.hour, from: date)
//
//    switch hour {
//    case 23, 0:
//        return ChineseHour(hour: "子时", time: "23-1点", title: "胆", subtitle: "子时睡得足，黑眼圈准无", details: "在子时前入睡，第二天醒来后头脑会变得更加清醒，气色也显红润。",color: Color(hex: "3C3233"))
//    case 1, 2:
//        return ChineseHour(hour: "丑时",  time: "1-3点",title: "肝", subtitle: "丑时睡得晚，脸上定长斑", details: "肝主生发，使阳气逐渐生成，有造血、解毒的功能，人体进入睡眠状态才能高效运行。这个时候如果熬夜、打游戏、喝酒，长期下去肝脏就会出问题。",color: Color(hex: "1C1B52"))
//    case 3, 4:
//        return  ChineseHour(hour: "寅时", time: "3-5点", title: "肺", subtitle: "寅时睡得熟，色红精气足", details: "从3点到5点，人体的气血开始重新分配，气血的分配由肺经来完成的。身体各部位都开始由静转动，各部分对血、气的需求量都开始增加。气血流注于肺经。重新分配的过程要在深度睡眠当中来完成，如果这个时候醒来，就说明气血量不足。",color: Color(hex: "B6D1E4"))
//    case 5, 6:
//        return ChineseHour(hour: "卯时",  time: "5-7点",title: "大肠", subtitle: "卯时大肠蠕，排毒残渣出", details: "早晨起床后喝杯温开水，然后排大便，这样人体的很多毒素就被排出来了，对健康非常有益。",color: Color(hex: "B9413B"))
//    case 7, 8:
//        return ChineseHour(hour: "辰时",  time: "7-9点", title: "胃", subtitle: "辰时吃早餐，营养身体安", details: "这时候吃早饭，就是要补充营养。这个时候是天地阳气最旺的时候，所以说吃早饭是最容易消化的时候。早饭吃多点是不会发胖的，因为有脾经和胃经在运化。",color: Color(hex: "C1CB8C"))
//    case 9, 10:
//        return ChineseHour(hour: "巳时",  time: "9-11点",title: "脾", subtitle: "巳时脾经旺，造血身体壮", details: "这个时候大脑活力最旺盛，也是一天中的黄金时段，工作、学习效率最高，早饭吃好，脾经吸收足够的营养，为大脑提供充足的能量。此时宜活动一下身子，促进血液循环，帮助肠胃消化，忌久坐不动。",color: Color(hex: "EAB689"))
//    case 11, 12:
//        return ChineseHour(hour: "午时", time: "11-13点",  title: "心", subtitle: "午时一小憩，安神养精气", details: "有条件一定要午睡。子时属阴，午时属阳。患有心血管疾病的人要注意养护心脏阳气。睡个子午觉，阴阳合和，人才能气血顺畅，百病不生。",color: Color(hex: "FCBA10"))
//    case 13, 14:
//        return ChineseHour(hour: "未时", time: "13-15点", title: "小肠", subtitle: "未时分清浊，\n饮水能降火", details: "这个时候，我们就需要一杯水来稀释浓度不断增加的血液，这样能很好地保护血管。",color: Color(hex: "EAA93F"))
//    case 15, 16:
//        return ChineseHour(hour: "申时", time: "15-17点", title: "膀胱", subtitle: "申时津液足，\n养阴身体舒", details: "申时，工作学习的第二个黄金时期。多饮水、适当运动、拍打膀胱经、高效率的学习和工作。",color: Color(hex: "63D0E7"))
//    case 17, 18:
//        return ChineseHour(hour: "酉时",  time: "17-19点",title: "肾", subtitle: "酉时肾藏精，纳华元气清", details: "每天在酉时喝一杯水。这一杯水是用于促进代谢，它可以清洗我们的肾和膀胱，让我们远离肾结石。每天临睡前用热水泡泡脚，再揉揉涌泉穴，可以补肾健脑，增强智力，延年益寿。",color: Color(hex: "FD9828"))
//    case 19, 20:
//        return ChineseHour(hour: "戌时",  time: "19-21点",title: "心包", subtitle: "戍时护心脏，减压心舒畅", details: "心包是心脏外膜组织，主要是保护心肌正常工作的。心脏的病，首先就会表现在心包上。心包有一个非常重要的穴位——膻中穴，它在两乳之间。高兴或是郁闷的时候，最常做的一个动作是拍胸脯！",color: Color(hex: "7C8083"))
//    case 21, 22:
//        return ChineseHour(hour: "亥时",  time: "21-23点",title: "三焦", subtitle: "亥时百脉通，养身养娇容", details: "亥时三焦经的经气最旺盛，所谓“三焦”，分为上焦、中焦、下焦，上焦是心和肺，中焦是脾和胃，下焦是肝和肾。我们在亥时睡觉，百脉就能得到最好的休息，百脉得到调养，人们的皮肤就会变好，这就是睡美容觉。",color: Color(hex: "43474D"))
//    default:
//        return ChineseHour(hour: "未知时辰",  time: "-",title: "-", subtitle: "-", details: "-", color: .gray.opacity(0.2))
//    }
//}


func currentHourInChinese(_ date: Date) -> ChineseHour {
    let hour = Calendar.current.component(.hour, from: date)
    
    switch hour {
    case 23, 0:
        return ChineseHour(hour: "子时", time: "23-1点", title: "胆", subtitle: "子时睡得足，黑眼圈准无", details: "在子时前入睡，第二天醒来后头脑会变得更加清醒，气色也显红润。",color: Color(hex: "6C8650"))
    case 1, 2:
        return ChineseHour(hour: "丑时",  time: "1-3点",title: "肝", subtitle: "丑时睡得晚，脸上定长斑", details: "肝主生发，使阳气逐渐生成，有造血、解毒的功能，人体进入睡眠状态才能高效运行。这个时候如果熬夜、打游戏、喝酒，长期下去肝脏就会出问题。",color: Color(hex: "6A8D52"))
    case 3, 4:
        return  ChineseHour(hour: "寅时", time: "3-5点", title: "肺", subtitle: "寅时睡得熟，色红精气足", details: "从3点到5点，人体的气血开始重新分配，气血的分配由肺经来完成的。身体各部位都开始由静转动，各部分对血、气的需求量都开始增加。气血流注于肺经。重新分配的过程要在深度睡眠当中来完成，如果这个时候醒来，就说明气血量不足。",color: Color(hex: "C0D09D"))
    case 5, 6:
        return ChineseHour(hour: "卯时",  time: "5-7点",title: "大肠", subtitle: "卯时大肠蠕，排毒残渣出", details: "早晨起床后喝杯温开水，然后排大便，这样人体的很多毒素就被排出来了，对健康非常有益。",color: Color(hex: "C0D695"))
    case 7, 8:
        return ChineseHour(hour: "辰时",  time: "7-9点", title: "胃", subtitle: "辰时吃早餐，营养身体安", details: "这时候吃早饭，就是要补充营养。这个时候是天地阳气最旺的时候，所以说吃早饭是最容易消化的时候。早饭吃多点是不会发胖的，因为有脾经和胃经在运化。",color: Color(hex: "A9BE7B"))
    case 9, 10:
        return ChineseHour(hour: "巳时",  time: "9-11点",title: "脾", subtitle: "巳时脾经旺，造血身体壮", details: "这个时候大脑活力最旺盛，也是一天中的黄金时段，工作、学习效率最高，早饭吃好，脾经吸收足够的营养，为大脑提供充足的能量。此时宜活动一下身子，促进血液循环，帮助肠胃消化，忌久坐不动。",color: Color(hex: "A8BF8F"))
    case 11, 12:
        return ChineseHour(hour: "午时", time: "11-13点",  title: "心", subtitle: "午时一小憩，安神养精气", details: "有条件一定要午睡。子时属阴，午时属阳。患有心血管疾病的人要注意养护心脏阳气。睡个子午觉，阴阳合和，人才能气血顺畅，百病不生。",color: Color(hex: "A8B78C"))
    case 13, 14:
        return ChineseHour(hour: "未时", time: "13-15点", title: "小肠", subtitle: "未时分清浊，饮水能降火", details: "这个时候，我们就需要一杯水来稀释浓度不断增加的血液，这样能很好地保护血管。",color: Color(hex: "90A07D"))
    case 15, 16:
        return ChineseHour(hour: "申时", time: "15-17点", title: "膀胱", subtitle: "申时津液足，养阴身体舒", details: "申时，工作学习的第二个黄金时期。多饮水、适当运动、拍打膀胱经、高效率的学习和工作。",color: Color(hex: "9BB496"))
    case 17, 18:
        return ChineseHour(hour: "酉时",  time: "17-19点",title: "肾", subtitle: "酉时肾藏精，纳华元气清", details: "每天在酉时喝一杯水。这一杯水是用于促进代谢，它可以清洗我们的肾和膀胱，让我们远离肾结石。每天临睡前用热水泡泡脚，再揉揉涌泉穴，可以补肾健脑，增强智力，延年益寿。",color: Color(hex: "81A380"))
    case 19, 20:
        return ChineseHour(hour: "戌时",  time: "19-21点",title: "心包", subtitle: "戍时护心脏，减压心舒畅", details: "心包是心脏外膜组织，主要是保护心肌正常工作的。心脏的病，首先就会表现在心包上。心包有一个非常重要的穴位——膻中穴，它在两乳之间。高兴或是郁闷的时候，最常做的一个动作是拍胸脯！",color: Color(hex: "68945C"))
    case 21, 22:
        return ChineseHour(hour: "亥时",  time: "21-23点",title: "三焦", subtitle: "亥时百脉通，养身养娇容", details: "亥时三焦经的经气最旺盛，所谓“三焦”，分为上焦、中焦、下焦，上焦是心和肺，中焦是脾和胃，下焦是肝和肾。我们在亥时睡觉，百脉就能得到最好的休息，百脉得到调养，人们的皮肤就会变好，这就是睡美容觉。",color: Color(hex: "779649"))
    default:
        return ChineseHour(hour: "未知时辰",  time: "-",title: "-", subtitle: "-", details: "-", color: .gray.opacity(0.2))
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
        
    }
}
