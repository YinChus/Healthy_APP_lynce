import SwiftUI


struct BaikeView: View {
    @State var selectedTag = 0
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(AllFoodItems.enumerated()), id: \.element) { index, item in
                        Button {
                            withAnimation{
                                selectedTag = index
                            }
                            
                            print(selectedTag)
                        } label: {
                            ZStack {
                                Text(item.name)
                                    .padding()
                                    .foregroundColor(selectedTag==index ? .white:ThemeColor.tint)
                            }
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(selectedTag==index ? ThemeColor.tint : ThemeColor.boxColor)
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(lineWidth: 2)
                                        .padding(1)
                                        .foregroundColor(ThemeColor.tint)
                                }
                            )
                        }
                    }
                    
                    
                    ForEach(AdditionalFoodItem, id: \.self) { item in
                        Button {
                           
                        } label: {
                            ZStack {
                                Text(item)
                                    .padding()
                                    .foregroundColor(ThemeColor.tint)
                            }
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(ThemeColor.boxColor)
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(lineWidth: 2)
                                        .padding(1)
                                        .foregroundColor(ThemeColor.tint)
                                }
                            )
                        }
                    }
                    
                    
                    
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            TabView(selection: $selectedTag) {
                ForEach(Array(AllFoodItems.enumerated()), id: \.element) { index, item in
                    FoodKnowledgeView(foodItem: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
        }
        
        .background(ThemeColor.background)
    }
}


struct FoodKnowledgeView: View {
    let foodItem: FoodKnowledgeItem
    var body: some View {
        ScrollView{
            VStack(alignment: .leading,spacing: 10){
                
                
                
                Image(foodItem.imageName)
                    .resizable()  // 使图片可以调整大小
                    .aspectRatio(contentMode: .fill)  // 保持原始图片的纵横比并填满内容
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(20)
                
                HStack(alignment: .bottom){
                    Text(foodItem.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(ThemeColor.tint)
                    HStack{
                        ForEach(foodItem.property2, id:\.self){property in 
                            Text(property)
                                .padding(6)
                                .background(.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                    
                }
                
                
                Text(foodItem.property1)
                    .padding(.vertical)
                
                
                
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(ThemeColor.tint)
                
                Text(foodItem.intro)
                    .padding()
                VStack{
                    
                    KnowledgeSectionView(sectionTitle: "适宜人群", sectionDetails: foodItem.suitablePeople)
                    KnowledgeSectionView(sectionTitle: "不适宜人群", sectionDetails: foodItem.unsuitablePeople)
                    KnowledgeSectionView(sectionTitle: "营养价值", sectionDetails: foodItem.nutrition)
                    
                    
                    
                    VStack{
                        KnowledgeSectionTitle(title: "食疗作用")
                        
                        ForEach(foodItem.therapy, id:\.self) { item in
                            VStack(alignment: .leading, spacing:10){
                                HStack{
                                    Text(item.title)
                                        .bold()
                                        .padding(6)
                                        .foregroundColor(.white)
                                        .background(ThemeColor.tint)
                                        .cornerRadius(10)
                                    Spacer()
                                }
                                Text(item.intro)
                            }
                            .padding(.bottom, 10)
                            
                        }
                    }
                    
                    
                    KnowledgeSectionView(sectionTitle: "特别提示", sectionDetails: foodItem.tips)
                    
                    VStack{
                        KnowledgeSectionTitle(title: "搭配宜忌")
                        
                        ForEach(foodItem.combo, id:\.self) { item in
                            HStack{
                                Text(item.combo)
                                Spacer(minLength: 6)
                                Text(item.intro)
                            }
                            .padding()
                            .background(item.isPositive ? ThemeColor.tint.opacity(0.2) : .red.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    
                    
                }
            }
            .padding()
            
        }
        //        .background(.blue)
    }
    
}


struct KnowledgeSectionTitle: View {
    let title:String
    var body: some View {
        HStack{
            Rectangle()
                .frame(width: 20, height: 2)
            
            Text(title)
                .font(.title)
                .bold()
            Rectangle()
                .frame(height: 2)
            
        }
        .padding(.top, 30)
        .foregroundColor(ThemeColor.tint)
    }
}



struct KnowledgeSectionView: View {
    let sectionTitle: String
    let sectionDetails: String
    var body: some View {
        VStack(alignment: .leading){
            
            KnowledgeSectionTitle(title: sectionTitle)
            
            Text(sectionDetails)
                .padding()
        }
    }
}







struct FoodKnowledgeItem:Hashable{
    let name: String
    let imageName: String
    let property1: String
    let property2: [String]
    let intro: String
    let suitablePeople: String
    let unsuitablePeople: String
    let nutrition: String
    let therapy: [DualItem]
    let tips: String
    let combo: [ComboItems]
}


struct DualItem:Hashable{
    let title: String
    let intro: String
}

struct ComboItems:Hashable{
    let combo:String
    let intro:String
    let isPositive:Bool
}




let AllFoodItems = [
    FoodKnowledgeItem(
        name: "桃", imageName: "Peach", property1: "性温，味甘，味酸\n归胃经，大肠经", property2: ["适合血瘀质","宜高血压"], 
        intro: "桃子是蔷薇科植物桃或山桃的果实，起源于中国。桃树开花早，生长繁茂且易种植。其中，水蜜桃的果肉最为人称道，其皮薄肉厚，味道香甜如蜜。古时，桃被视为“五果”之首，与李、杏、栗、枣并列。桃还有助于缓解老年便秘和女性痛经。", 
        suitablePeople: "老年体虚者,及肠燥便秘、阳虚肾亏、水肿、缺铁性贫血患者。", 
        unsuitablePeople: "内热偏盛者、孕妇、婴儿", 
        nutrition: "桃子含有丰富的蛋白质，超过了梨和柿子。在所有生果中，桃的铁含量排名第二，仅次于樱桃。除此之外，桃还包含胡萝卜素、多种维生素和矿物质如钙、磷、钾、钠。其内部的葡萄糖、果糖和有机酸都易于人体吸收。因此，桃可以视为一种有益健康的水果。", 
        therapy:
            [
                DualItem(title: "滋补与调理", intro: "主治体虚、肠燥便秘、瘀血痛经、闭经等"),
                DualItem(title: "补铁护血", intro: "桃的铁含量在果物中居前，有助于防治缺铁性贫血。"),
                DualItem(title: "活血化瘀", intro: "桃仁增加脑血流量，改善微循环，并有抗凝血作用。"),
                DualItem(title: "护肝利胆", intro: "对肝硬化、肝纤维化有益，且促进胆汁分泌。"),
                DualItem(title: "止咳平喘", intro: "桃仁对呼吸器官有镇静作用。"),
                DualItem(title: "防癌抗癌", intro: "桃仁成分对癌细胞有破坏作用。"),
                DualItem(title: "利尿退黄", intro: "桃花有利尿效果，而桃仁能助消肿。"),
                DualItem(title: "健胃益肠", intro: "桃助消化，促进胃肠蠕动；中医五仁汤中含桃仁，助通便。"),
                DualItem(title: "美容养颜", intro: "桃子对皮肤有益，古方用其进行护肤。"),
                DualItem(title: "降低血压", intro: "桃仁辅助治疗高血压。"),
                DualItem(title: "滋补与调理", intro: "主治体虚、肠燥便秘、瘀血痛经、闭经等")
            ],
        tips: "桃子性温, 多吃会令人内热过盛,过量会导致胃胀胸闷。", 
        combo: [
            ComboItems(combo: "桃+螃蟹", intro: "会引起腹痛、腹泻", isPositive: false),
            ComboItems(combo: "桃+萝卜", intro: "作用相反", isPositive: false),
            ComboItems(combo: "桃+白酒", intro: "会导致上火", isPositive: false),
            ComboItems(combo: "桃+甲鱼", intro: "降低营养价值", isPositive: false),
            ComboItems(combo: "桃+胡萝卜", intro: "破坏维生素C", isPositive: false),
            ComboItems(combo: "桃+牛奶", intro: "营养丰富", isPositive: true)
        ]),
    
    FoodKnowledgeItem(name: "荔枝", imageName: "Lychee", property1: "性温，味甘，味酸\n归脾经，肝经，胃经", property2: ["忌高血糖","忌高血压"], intro: "荔枝能补脾益肝,理气止痛,益智悦颜;为百果之王，甚至被称为“人间仙果”“佛果”。荔枝为果中绝品,这主要由于荔枝本身形色皆美,质娇味珍,是白玉凝脂般的佳果。总之,在水果中,要属荔枝最娇贵，味最珍美。", suitablePeople: "体质虚寒者", unsuitablePeople: "实热或阴虚肝火旺之人，少吃荔枝。痛风糖尿病患者尤其不宜多吃。", nutrition: "荔枝的保健作用有独到之处。荔枝肉中含有丰富的糖类,其中荔枝干葡萄糖的含量高达66%，还有果糖和蔗糖 ;还含有较丰富的维生素C、维生素B、维生素A以及柠檬酸、叶酸、苹果酸和多量游离氨基酸等。故尤宜身体虚弱，病后津液不足的人， 作为补品食用。",
                      therapy: [
                        DualItem(title: "补益增智", intro: "荔枝果肉中含葡萄糖66%、蔗糖5%,总糖量在70%以上,列居水果的首位,具有补充能量,增加营养的作用。研究证明,荔枝对大脑组织有补养作用,能明显改善失眠、健忘、神疲等症。"),
                        DualItem(title: "强身护肝", intro: "荔枝肉含丰富的维生素C和蛋白质,有助于增强人体的免疫功能,提高抗病能力。自古以来,一直被视为珍贵的补品。研究表明荔枝对乙型肝炎病毒表面抗原有抑制作用。"),
                        DualItem(title: "消肿解毒", intro: "荔枝除广为人知的滋补作用外,还可用于外科疾病,如肿瘤、瘰疬、疔疮恶肿、外伤出血等病。"),
                        DualItem(title: "健脾和胃", intro: "对肝硬化、肝纤维化有益，且促进胆汁分泌。"),
                        DualItem(title: "止咳平喘", intro: "荔枝甘温健脾, 为顽固性呃逆及五更泻者的食疗佳品。")
                    ], tips: "荔枝性偏温热，不可连续多食,以免出现以低血糖为主的“荔枝病”。患者轻则恶心四肢无力,重则几分钟后昏迷、痉挛。遇此情况要及时送医院抢救补充葡萄糖。",
                      combo: [
                        ComboItems(combo: "荔枝+核桃", intro: "导致胃肠功能紊乱", isPositive: false),
                        ComboItems(combo: "荔枝+红枣", intro: "健脾止泻", isPositive: true),
                        ComboItems(combo: "荔枝+扁豆", intro: "健脾胃，益肝肾", isPositive: true)
                    ]),
    FoodKnowledgeItem(name: "西瓜", imageName: "Watermelon", property1: "性寒，味甘，归心经\n胃经，膀胱经", property2: ["宜高血压"], intro: "别名:水瓜、寒瓜、夏瓜\n西瓜甘甜多汁，爽口解渴，是夏季“瓜中之王”,有“天生白虎汤”的美称。西瓜全身都是宝，既是一种甜美的瓜果又是一味神奇的中药材。西瓜果肉可分为乳白、淡黄、深黄、浅红、大红等色。", suitablePeople: "夏季中暑者、口干烦燥、高血压、肾炎患者。", unsuitablePeople: "孕妇、感冒初期、糖尿病患者、体虚胃寒。", nutrition: "西瓜是一种营养丰富的水果，其汁液含有人体所需的多种营养成分。除了提供瓜氨酸、精氨酸、丙氨酸、氨基丁酸、谷氨酸等多种氨基酸，还含有磷酸、苹果酸、乙二醇等。西瓜的果肉含有丰富的水分，同时也富含人体必需的多种营养，如葡萄糖、果糖、蔗糖、维生素、胡萝卜素、蛋白质以及各种氨基酸、果酸、钙、磷、铁等矿物质。因此，西瓜具有多种功效，包括消暑清热、缓解烦渴、促进利尿消肿等。它被认为是治疗中暑、高血压、肾炎、尿路感染、口疮、醉酒等疾病的良好选择。",
                      therapy:[
                        DualItem(title: "清热解暑", intro: "西瓜富含水分、氨基酸和糖，适合在夏季饮用，能迅速为体内补充水分，稀释黏液，促进新陈代谢和废物排出，预防中暑。它还能通过促进利尿排出体内多余热量，起到清热解暑的效果。"),
                        DualItem(title: "补充营养", intro: "西瓜汁中含有多种有益健康和美容的化学成分，能清除体内代谢产物，促进肾脏和尿道的清洁，同时激活细胞，有助于美容和延缓衰老。西瓜皮也富含营养，有消炎、降压、促进新陈代谢等功效。"),
                        DualItem(title: "利尿降压", intro: "西瓜具有降压和利尿作用，其成分有助于消除肾脏炎症，减少浮肿。瓜氨酸、精氨酸、盐类和酶可以促进尿素的形成，从而达到利尿的效果。适合高血压、肾炎和浮肿等患者食用。"),
                        DualItem(title: "利咽消肿", intro: "西瓜制成的西瓜霜能够消炎和退肿，对咽喉肿痛、口舌溃疡等问题有一定的疗效。"),
                        
                    ]
                      , tips: "夏天吃完西瓜，可以把硬皮切掉，瓜青切条用盐腌，可当作佐餐小菜。",
                      combo: [
                        ComboItems(combo: "西瓜+羊肉", intro: "会导致脾胃功能失调", isPositive: false),
                        ComboItems(combo: "西瓜+蒜", intro: "清热利水，消肿解毒", isPositive: true),
                        ComboItems(combo: "西瓜+绿茶+薄荷", intro: "清新口气、生津止渴", isPositive: true),
                        ComboItems(combo: "西瓜+冰糖", intro: "清热解暑、利尿", isPositive: true),
                    ]),
    FoodKnowledgeItem(name: "苹果", imageName: "Apple", property1: "性平，味甘，味酸\n归脾经，肺经", property2: ["宜高血糖","宜高血压"], intro: "别名:频婆、天然子、子苹果性、质、色、味、香俱佳，品种繁多,颜色不一，味道酸甜可口，在国外，苹果有“三果”之誉.即“减肥果”、“青春果”、“智慧果”。", suitablePeople: "苹果适合慢性胃炎患者、消化不良者、维生素缺乏者、高血压、高脂血症、肥胖症、癌症患者食用", unsuitablePeople: "溃疡性结肠炎、白细胞减少症、胃寒症状者", nutrition: "苹果的营养价值为人称道.它含有果糖、葡萄糖蔗糖名列前茅;含有多种维生素.胡萝卜素和矿物质;还含有丰富的果酸,如苹果酸、奎宁酸.柠檬酸、酒石酸(含有机酸共约占0.5%)等。苹果中所含的果胶和钾.居果品中的首位。",
                      therapy:
                        [
                          DualItem(title: "消化系统", intro: "苹果富含膳食纤维，可以治疗腹泻和便秘，保持血糖稳定，对胃酸过剩、胃虚弱、消化不良等症状有良好的调节作用。"),
                          DualItem(title: "心血管健康", intro: "苹果中的钾有助于降低血压，果胶和纤维可降低血脂，预防心脏疾病，同时也有预防动脉硬化、冠心病的效果。"),
                          DualItem(title: "免疫系统", intro: "苹果含有维生素C，有助于增强免疫功能，预防咳嗽、伤风和流感等。"),
                          DualItem(title: "智力和记忆", intro: "苹果含有多种营养成分，如维生素B、锌和胡萝卜素，对大脑发育、记忆力和学习能力有促进作用。"),
                          DualItem(title: "防癌抗癌", intro: "苹果中的多肽和果胶被认为具有抗癌作用，选择素能刺激淋巴细胞分裂，起到抗癌的重要作用。"),
                          DualItem(title: "减肥", intro: "苹果有助于减肥，因其容易产生饱腹感且低热量，适合作为减肥食物。"),
                          DualItem(title: "其他作用", intro: "苹果还有补碘、补益肺气、解酒解毒等作用，可以帮助多种健康问题。")
                      ]
                      , tips: """
- 去除车内异味：
夏天车内异味可以用2个苹果来抵挡，因为苹果的浓郁果香能有效中和异味。

- 孕妇的益处：
每天食用1~2个苹果可以减轻孕期不适反应，对孕妇有帮助。

- 进食时间：
不宜在饭后立即吃苹果，最好在饭后2小时或饭前1小时食用，以避免影响消化。

- 削皮食用：
苹果要削皮后食用，最好立即吃，或者在削皮后用醋水洗净以保持原色。
""", combo:[
    ComboItems(combo: "苹果+胡萝卜", intro: "破坏维生素C", isPositive: false),
    ComboItems(combo: "苹果+鹅肉", intro: "低营养成分", isPositive: false),
    ComboItems(combo: "苹果+糯米", intro: "易导致恶心、呕吐，腹痛", isPositive: false),
    ComboItems(combo: "苹果+海鲜", intro: "引起腹痛、恶心呕吐", isPositive: false),
    ComboItems(combo: "苹果+银耳", intro: "肺止咳、排毒美容", isPositive: true),
    ComboItems(combo: "苹果+猪肉", intro: "除猪肉异味", isPositive: true),
    ComboItems(combo: "苹果+枸杞", intro: "养更丰富", isPositive: true),
])
    
]


let AdditionalFoodItem = ["杨梅","葡萄","香蕉","番茄","白萝卜","茄子","冬瓜"]


