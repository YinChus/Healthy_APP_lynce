import SwiftUI

// 定义 Question model
struct Question: Identifiable {
    var id: Int // Change the id type to Int
    var category: String
    var questionText: String
    var reversed:Bool = false
    var choices = ["没有", "很少", "有时", "经常", "总是"]
}

// 定义 QuizViewModel
class QuizViewModel: ObservableObject {
    @Published var questions: [Question]
    @Published var scores: [Int: Int] { // Change the key type to Int
        didSet {
            let scoresData = try? JSONEncoder().encode(scores)
            UserDefaults.standard.set(scoresData, forKey: "Scores")
        }
    }
    @Published var answered: [Int: Bool] { // Change the key type to Int
        didSet {
            let answeredData = try? JSONEncoder().encode(answered)
            UserDefaults.standard.set(answeredData, forKey: "Answered")
        }
    }
    @Published var showingResults: Bool {
        didSet {
            UserDefaults.standard.set(showingResults, forKey: "ShowingResults")
        }
    }
    @Published var selectedChoice: [Int: Int] { // Change the key type to Int
        didSet {
            let selectedChoiceData = try? JSONEncoder().encode(selectedChoice)
            UserDefaults.standard.set(selectedChoiceData, forKey: "SelectedChoice")
        }
    }
    
    init(questions: [Question]) {
        self.questions = questions
        self.scores = [:]
        self.answered = [:]
        self.selectedChoice = [:]
        self.showingResults = UserDefaults.standard.bool(forKey: "ShowingResults")
        
        if let scoresData = UserDefaults.standard.data(forKey: "Scores"),
           let savedScores = try? JSONDecoder().decode([Int: Int].self, from: scoresData) {
            self.scores = savedScores
        }
        
        if let answeredData = UserDefaults.standard.data(forKey: "Answered"),
           let savedAnswered = try? JSONDecoder().decode([Int: Bool].self, from: answeredData) {
            self.answered = savedAnswered
        }
        
        if let selectedChoiceData = UserDefaults.standard.data(forKey: "SelectedChoice"),
           let savedSelectedChoice = try? JSONDecoder().decode([Int: Int].self, from: selectedChoiceData) {
            self.selectedChoice = savedSelectedChoice
        }
        
        for question in questions where answered[question.id] == nil {
            self.answered[question.id] = false
        }
        
    }
    
    func submitAnswer(for questionID: Int, choiceIndex: Int) {
        guard let question = questions.first(where: { $0.id == questionID }) else { return }
        let score = question.reversed ? (question.choices.count - choiceIndex) : (choiceIndex + 1)
        
        scores[questionID] = score
        answered[questionID] = true
        selectedChoice[questionID] = choiceIndex
        
        print(selectedChoice)
    }
    
    var totalScore: Int {
        return scores.values.reduce(0, +)
    }
    
    func allQuestionsAnswered() -> Bool {
        return answered.values.allSatisfy { $0 == true }
    }
    
    func unansweredQuestions() -> [Int] {
        return answered.compactMap { (key, value) in
            value == false ? questions.firstIndex(where: { question in question.id == key }) : nil
        }.sorted() // Sort the unanswered question indices in ascending order
    }
    
    func categoryScores() -> [String: Int] {
        var categoryScores: [String: Int] = [:]
        
        for question in questions {
            if let score = scores[question.id] {
                categoryScores[question.category, default: 0] += score
            }
        }
        
        return categoryScores
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: "Scores")
        UserDefaults.standard.removeObject(forKey: "Answered")
        UserDefaults.standard.removeObject(forKey: "SelectedChoice")
        UserDefaults.standard.removeObject(forKey: "showingResults")
        
        scores = [:]
        answered = [:]
        selectedChoice = [:]
        
        for question in questions {
            self.answered[question.id] = false
        }
        
        showingResults = false
    }
    //计算转化分
    
    func transformedCategoryScores() -> [String: Double] {
        var transformedScores: [String: Double] = [:]
        
        let categoryQuestionCounts = Dictionary(grouping: questions, by: { $0.category }).mapValues { $0.count }
        
        for (category, score) in categoryScores() {
            if let categoryQuestionCount = categoryQuestionCounts[category] {
                let transformedScore = 100 * Double(score - categoryQuestionCount) / Double(categoryQuestionCount * 4) 
                transformedScores[category] = transformedScore
            }
        }
        
        return transformedScores
    }
    
}

// 定义 QuestionView
struct QuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    var question: Question
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(question.questionText)
                .padding(.leading,35)
                .foregroundColor(ThemeColor.tint)
            HStack {
                ForEach(0..<question.choices.count, id: \.self) { index in
                    Button {
                        viewModel.submitAnswer(for: question.id, choiceIndex: index)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 2)
                                .foregroundColor(ThemeColor.tint)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(viewModel.selectedChoice[question.id] == index ? ThemeColor.tint : ThemeColor.boxColor)
                                .opacity(viewModel.selectedChoice[question.id] == index ? 1 : 0.2)
                            Text(question.choices[index])
                                .padding(10)
                                .foregroundColor(viewModel.selectedChoice[question.id] == index ? .white : ThemeColor.tint)
                                .bold()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(height: 50)
        }
         
    }
    
}

// 定义 ResultsView
struct ResultsView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var showResetAlert = false
    
    var body: some View {
        VStack {
            ScrollView{
                //            Text("总分: \(viewModel.totalScore)")
                let transformedScores = viewModel.transformedCategoryScores()
                let constitutionTypes = getConstitutionTypes(transformedScores)
                let constitudeDetails = createConstitudeDetails(constitutionTypes.first ?? "-")
                
            VStack(spacing:6){
                    Text("我的体质是")
                        
                    Text("\(constitutionTypes.first!)")
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                
                    if constitutionTypes.count>1{
                        Text("我的兼有体质是")
                        Text(constitutionTypes.dropFirst().joined(separator: ","))
                            .bold()
                        
                    }
                    
                }
                .padding(.horizontal)
                .foregroundColor(ThemeColor.tint)
                
                
                let sortedTransformedScores = transformedScores
                    .filter { $0.key != "平和质" } // Exclude "平和质"
                    .sorted(by: { $0.key < $1.key }) // Sort by category name
                
                RadarChartView(data: sortedTransformedScores.map { $0.value }, 
                               categories: sortedTransformedScores.map { $0.key }, font: .body) // Pass sorted data and categories
                .frame(height: 200)
                .padding(.vertical, 80)
                
                
                DisclosureGroup("查看体质分数"){
                    
                    VStack{
                        ForEach(viewModel.transformedCategoryScores().sorted(by: >), id: \.key) { key, value in
                            
                            HStack{
                                Text("\(key) - \(String(format:"%.2f",value))")
                                Spacer()
                            }
                        }        
                    } 
                    .padding()
                }
                .padding()
                .background(ThemeColor.boxColor)
                .cornerRadius(15)
                .padding(.horizontal)
                
                VStack{
                    
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")症状"){
                        Text(constitudeDetails.symptom)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")容易得哪些疾病"){
                        Text(constitudeDetails.illness)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")的原因分析"){
                        Text(constitudeDetails.reasons)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")的情志养生"){
                        Text(constitudeDetails.mentalCare)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")的运动养生"){
                        Text(constitudeDetails.fitnessCare)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")的起居养生"){
                        Text(constitudeDetails.livingCare)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")的饮食禁忌"){
                        Text(constitudeDetails.diet)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    DisclosureGroup("\(constitutionTypes.first ?? "")的四季养生"){
                        Text(constitudeDetails.seasons)
                            .padding(.vertical)
                    }
                    .padding()
                    .background(ThemeColor.boxColor)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            
           Button(action: {
                showResetAlert = true
            }) {
                
                    Text("重新答题")
                        
                        .bold()
                
            }
            .padding()
            .alert(isPresented: $showResetAlert) {
                Alert(title: Text("重置确认"), message: Text("你确定要重置并重新答题吗？"), primaryButton: .destructive(Text("重置")) {
                    viewModel.reset()
                }, secondaryButton: .cancel())
            }
        }
        .navigationBarTitle("结果", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .background(ThemeColor.background)
        .tint(ThemeColor.tint)
    }
    
    

}


 func getConstitutionTypes(_ scores: [String: Double]) -> [String] {
    var constitutionTypes: [String] = []
    for (category, score) in scores {
        if category != "平和质" {
            if score > 40 {
                constitutionTypes.append(category)
            }
        } else if score > 60 {
            constitutionTypes.append(category)
        }
    }
    if constitutionTypes.isEmpty {
        constitutionTypes.append("未知体质")
    }
    return constitutionTypes
}

func createConstitudeDetails(_ constitude: String) -> ConstitutionDetails {
    return constitutionData[constitude] ?? unkownConstitution
}

struct ConstitutionDetails{
    let name: String
    let introduction: String
    let symptom: String
    let illness: String
    let reasons: String
    let mentalCare: String
    let fitnessCare: String
    let livingCare: String
    let diet: String
    let seasons: String
}

let unkownConstitution = ConstitutionDetails(name: "-", introduction: "-", symptom: "-", illness: "-", reasons: "-", mentalCare: "-", fitnessCare: "-", livingCare: "-", diet: "-", seasons: "-")

let constitutionData: [String : ConstitutionDetails] = [
    "阴虚质" : ConstitutionDetails(
        name: "阴虚质", 
        introduction: "干燥，缺水，上火，怕热\n阴虚质是指人体精、血等阴液亏损，失去润泽脏腑、滋养经脉肌肤的功用，出现虚火上炎的偏颇。\n只是看上去很健康。", 
        symptom: """
【心烦失眠】阴虚者内火攻心，常感觉胸口烦闷，情绪不稳定，注意力不集中，晚上容易惊棒失眠。
【皮肤无华】阴虚者皮肤缺少滋润，干燥无华，面色不佳，还容易上火，常生口疮，舌头发红，常便秘。
【形体消瘦】阴虚者胃火旺，能吃能喝，但代谢快，怎么吃也不胖，形体精悍，肌肉松弛。
【头晕易累】体内津液少则养分疏松不畅，且皆为旺火消耗，从而导致体力衰弱、头晕易累等症。
""", 
        illness: """
【结核病】阴虚者气血虚弱，阴精耗损，免疫力降低，病毒很容易乘虚而入，从而引发结核病，如肺结核、肠结核、骨结核、淋巴结核等。
【习惯性失眠】阴虚内热者“五心烦热”，心烦不安，气候、情绪、饮食、环境稍有改变就容易导致失眠。
【便秘】阴虚者体内缺水，容易引起肠道功能下降，导致便秘。而且小便也是量少且黄，即使经常喝水也很难改善。
【色斑】阴虚者皮肤容易缺水，污物无法排出，从而生斑，尤其是阴虚火燥相结的色斑是很难袪除的。阴虚者皮肤容易缺水，污物无法排出，从而生斑，尤其是阴虚火燥相结的色斑是很难袪除的。
【口腔溃疡】阴虚内热者阼内火气很大，容易上火，从而引发口腔溃疡。而且阴虚内热者皮肤干燥，嘴唇容易开裂，更易产生口疮。
【经期缩短】阴虚内热的女性往往会月经提前，经期缩短，如不及时治疗，甚至会产生闭经。
【高血压、高血脂】阴虚者虽然消瘦，但阴虚到一定程度，体内缺水过多，就会导致血液黏稠，血脂升高。
【心烦失眠】体内津液少则养分疏松不畅，且皆为旺火消耗，从而导致体力衰弱、头晕易累等症。
【糖尿病】糖尿病初期，一般都是以阴虚为主，总是口渴，但喝多少水也不解渴，而且嘴唇干燥有如泛起白霜。
【肿瘤】阴虚体质者长期情绪压抑再加上瘀血倾向，易患肿瘤，因此如果身体出现不明包块、硬结、便血等症状时要特别注意，及时检査。
""", 
        reasons: """
【经常熬夜】熬夜导致体内津液消耗，导致阴虚。女性经、带、产、乳等都会大最耗血，也易致阴虚。
【情绪压抑】情绪长期得不到舒展，会郁结化火，从而促生内热，损耗阴精。
【先天禀赋】父母是阴虚体质，很容易遗传给下一代。
【食物辛燥】长期使用辛燥食物，如辣椒、姜、蒜等助生内火，易导致阳盛而阴衰。
【长期服药】高血压、心脏病患者长期服用利尿药物，促进津液排出，从而促生或加重阴虚。
""", 
        mentalCare: "阴虚体质的人性情较急躁，常常心烦易怒，这是阴虚火旺、火扰神明之故。所以应遵循《素问》中“恬淡虚无”“精神内守”之养神大法，即加强自我涵养，做到遇事不慌，冷静沉着。平时宜克制情绪，正确对待顺境和逆境；平日起居要有规律；在工作中，有条不紊，对非原则性问题少与人争执，减少动怒，少参加争胜负的文娱活动。可以用练书法、下棋来怡情悦性，用旅游来寄情山水、陶冶情操；闲暇时间多听曲调悠扬舒缓、轻柔抒情的音乐，对于调整情绪、睡眠十分有利，如《摇篮曲》《小夜曲》等。", 
        fitnessCare: "合适的运动主要有太极拳、太极剑、八段锦、气功、游泳、健身操等。", 
        livingCare: """
【不可以剧烈的锻炼】阴虚者最好不要大量出汗，这样容易损耗阴气。所谓“夏练三伏，冬练三九对阴虚体质者并不适合。但并不是不锻炼，尽量选择比较舒缓的运动。

【保持生活环境湿润不干燥】阴虚者虽然喜欢冬天，但北方的冬天干燥，对阴虚者又是一大挑战，因此最好在室内安置加温器，保持周围环境的湿润。

【不宜长做磨损关节的运动】阴虚者会较早缺乏润滑关节的阴液，以致关节涩滞，因此中年以后不宜再做磨损关节，尤其是膝关节的运动，如上下楼梯、登山、跑步等。

【有条不紊，切勿急躁】阴虚者应妥善安排工作和生活，尽量避免着急上火、焦虑不安，因为这样容易伤阴，而伤阴就更易急躁，这样就陷入了恶性循环。
""", 
        diet: "阴虚体质者的饮食调理原则是滋阴潜阳。宜多选择味甘性寒凉、具有滋补机体阴精功效的食品。三餐宜清淡，远肥腻厚味、燥烈之品。可多吃芝麻、糯米、蜂蜜、乳品、甘蔗、鱼类等清淡食物，对于葱、姜、蒜、韭、椒等辛辣之品则应少吃。", 
        seasons: """
【春】春季阳气升发，阴虚内热者往往虚火上升，而且北方春季干燥，更容易患口腔溃疡、失眠、目赤等症状。宜服用三才封髓丹。三才封髓丹含人参、天冬、熟地、黄柏、甘草。可泻火坚阴固精封髓。用于阴虚火旺、相火妄动、扰动精室之症。

【夏】夏季阳气极盛，是阴虚者最痛苦的一个季节，此时应少动，避免烈日暴晒，不可出汗太多，要保证充足睡眠。可多吃西瓜、酸梅汤等加以缓解，也可服用西洋参、生脉饮等药物，或者在医导下服用维生素C和B。

【秋】秋季是阴虚体质者的养生重点，需注意肺，肾的养生因为二者都是体内阴水之源。宜出游，多呼吸新鲜空气。多吃滋润食物，如沙参、麦冬、百合、梨、柿子、玉兰、甲鱼、荞麦、银耳、莲子等。

【冬】冬季阴盛，是阴虚体质者最喜欢的一个季节，但冬季干燥，要注意多喝水，并加强对皮肤的保养。少吃辛溫香燥之品，尤其是麻辣火锅，阴虚体质者本来火旺再吃这些无疑是火上烧油。
"""),
    
    "气虚质" : ConstitutionDetails(
        name: "气虚质",
        introduction: "",
        symptom: """
【非常容易出汗】经常动不动就出汗，汗液带走体内热量，容易感冒。
【气短、呼吸轻】肺脏功能较差，说话声音怯，气息轻浅，稍微运动就容易气短。
【面色萎黄、口唇色淡】脾虚则气血化源不足，导致面部缺乏血色，面色发黄、口唇色淡。
【脾胃不佳、容易腹胀】气虚者胃口不是很好，饭量小。有的人则胃强脾弱，虽然能吃，却容易腹胀，消化不良。
【身体瘦弱或虚胖】脾胃不佳，自然容易形体消瘦。如果是肾气虚，则可能因体液不化而虚胖。
【易累，有气无力】脾主肌肉四肢，脾虚就会导致肌肉软无力，形体松弛，不挺拔。
""",
        illness: """
【月经提前、量少】气虚导致脏腑失调，从而引起月经紊乱，有时是提前，有时则是量少，但持续很久。
【落枕】气滞不畅，集中在某处就容易形成疼痛，如落枕、腹痛、头痛等，通过按摩可以缓解。
【皮肤痛痒】气虚较为严重时，体内卫气较弱，很容易引发皮肤骚痒。
【反复感冒】气虚者抵抗力较差，很容易感冒，而且感冒之后还不容易好。
【发低烧】气虚者卫气太弱，容易发低烧，而且痊愈后依然是病怏怏的，非常虚弱。
【鼻咽癌】气虚者经常感冒，从而导致反复鼻塞，再加上气滞于此，久之容易致病。
【高血脂】气滞也会导致血流不畅，减缓了血流速度，导致血脂堆积，从而引发高血脂。
【易致肥胖】脾虚者吃得少则瘦弱，如果胃口好则虚胖，这是很多营养吸收不了，堆积在体内所致。
【内脏下垂】气虚不能升提，肌肉无力，易致胃下垂、眼脸不垂、子宫脱垂、脱肛等病症。
【排泄不适度】气能起到固摄把门的作用，气虚者此项功能较弱，容易导致尿多、汗多、大便次数多、月经崩漏、白带过多等症。
【慢性炎症】气虚者一旦染上炎症，很容易转成慢性病，如慢性盆腔炎（女性）和慢性支气管炎。
【长色斑】气虚者气血化源不足，面色就会发黄、缺乏血色、甚至长色斑。
""",
        reasons: """
【来自父母】母亲怀孕时进食较少，营荞不足，或父母有一方是气虚体质。
【熬夜伤神】经常熬夜容易伤神，劳伤心脾。重体力劳动者则会伤形，长期神形过劳都会耗气，加重气虚。
【七情不畅】长期七情不畅、抑郁或暴怒都容易导致肝气郁结，肝木克脾土，从而促生气虚。
【久卧伤气】脾久卧不动容易导致气滞不畅，从而伤害脾胃，导致气虚。
【长期节食或食用伤气的食物】长期节食会导致营养不足，形成气虚。长期食用一些伤元气的食物，也会导致气虚。
【其它】大病、久病容易伤元气；手淫、纵欲也会消耗元气长期服用清热解毒的中药，或抗生素、消炎药、激素等。则会促生或加重气虚。
""",
        mentalCare: """
长期不良的精神情志活动，超过了脏腑的调控能力，就会耗伤脏腑气血，从而影响个体的体质。气虚体质的发生也与不良精神情志活动相关。《灵枢·寿夭刚柔》曰：“忧恐忿怒伤气。气伤脏，乃病脏。”可见不良的精神刺激长期作用于人体，日久即可形成气虚体质。
        
        唱歌能够增加肺活量，培养兴趣爱好。多交朋友、当义工、当志愿者，接触琴棋书画，都是气虚体质的不错选择。应避免长时间的麻将鏖战、推杯换盏的酒席应酬、昏天黑地的网游网恋、坐在沙发上盯着电视、在充满装修污染的房间睡觉或卡拉OK、拿着电话飞短流长。这些都不利于气虚体质的护养，轻者加重气虚倾向，重者导致疾病的发生。
""",
        fitnessCare: "适合太极拳、八段锦、六字诀、五禽戏等导引法，及慢跑、散步、瑜伽、舞蹈等活动。",
        livingCare: """
【睡眠】气虚体质人群夏季易失眠，因此气虚质在睡前应避免一切剧烈兴奋活动。此外，在白天应保持一定的活动量，不可在白天蒙头大睡，到了夜晚却睡不着，形成恶性循环，生活彻底被打乱，身体走向偏颇。
【二便】脾气虚之人易大便溏薄，故宜温补，平时可服用参苓白术散，并注意保暖，避免吃寒凉攻伐的食品。若脾肾气虚，则无力推动，易致便秘，日常生活中可吃一些润肠通便的食品，如桃仁、花生等。
【服饰】注意保暖，慎重加减衣服，不要劳汗当风，避免寒冷、潮湿、阴冷等。

""",
        diet: """
        【【补脾益肺，兼顾心肾】气虚就是因为脾肺虚弱，所以气虚者应补脾益肺，同时兼顾心经、肾经。
        【食性平和，易用平补】气虚者脏腑功能较弱，因此食补时应采用营养丰富且易于消化的食物，且量不宜过大。
        【气血双补】补气也应同时补血，宜益气生血、益气活血、益气摄血，不然气壮而血虚，依然无济于事。
        【忌食寒凉、油腻及发物】寒凉食物对脾胃刺激很大，油腻厚味食物则增加脾胃负担，因此气虚者不宜食用。
        """,
        seasons: """
【春】早睡早起，养成良好的作息习惯；其次，进行适当的户外活动，少食生冷之物，以免影响阳气生发；最后，适量吃些韭菜或饮少量酒。

【夏】气虚体质者在整个夏季都会觉得消化不好，饮食无味，脾胃虚。有时可能吃的东西卫生条件差了一点，凉了一点，就会觉得非常不适，所以气虚体质的女性要严格要求饮食，烧烤、冷饮等应少吃或不吃。气虚体质者元气不足，脏腑功能活动低下或衰退，抵抗力差，在夏季很容易患感冒，而且病后难愈，还容易患内脏下垂等疾病，因此，气虚者夏季应将提高自身免疫力放在首位。

【秋】鳜鱼为秋季气虚体质者养生的佳品。中医认为，鳜鱼具有补五脏、益脾胃、疗虚损等功效，适合气血虚弱、营养不良者食用。鳜鱼药膳，如鳜鱼百合粥、茯苓莲子鳜鱼汤、滋补鳜鱼汤等，是此类患者的最佳选择。
天气转凉，空气干燥，容易伤肺，而肺主皮毛，我们的口、鼻、咽喉等都与肺相通。肺气不足，风邪就会侵入身体，导致咳嗽、感冒、口干等症。而肺一旦出现问题，与肺互为表里的大肠也会跟着不适，出现便秘等症。秋季饮食不当，抵抗力就会下降，无力抵抗冬季的严寒，疾病便会找上门。因此，气虚体质的人在秋季既要补脾胃，还要补肺气。

【冬】气虚体质者要多食温热食物，如胡萝卜、羊肉、海参、韭菜、苹果等，或熬些药膳粥来益气补虚、温中健胃。在寒冷的冬季，养藏非常重要，滋益阴精为冬季养生重点，冷饮、辛辣食物应尽量少吃。到了冬季，气虚体质者一定要注意防寒保暖，最好不要感冒、上火，并且控制好自己的情绪。
"""),
    
    "痰湿质" : ConstitutionDetails(
        name: "痰湿质",
        introduction: """
       四肢重！排泄浊！口舌黏！浑身腻！
       中医认为"百病皆由痰作祟"、"顽痰生怪症"。
       这里的痰是指水液代谢过程不畅通而产生的废物。
       随着气血的运行流窜全身，位置不定，引起许多疾病。
       痰湿质的形成于生活方式关系最为密切，多发于生活富足的人。
""",
        symptom: """
【肥胖】多表现为大腹便便，是因为脾胃动化功能相对不足，导致体内水液好布散耐成疲湿。
【贪睡】脾主思，脾虚易致贪睡。而且痰湿者血液黏稠度较高，血气运行不畅，脑部供血不足，因为贪睡无力。
【油腻】皮肤毛孔也是人体代谢通道之一痰湿者的皮肤代谢物往往比较油腻、黏稠，极易形成座疮。
【出汗多或无汗】痰湿者要么出汗太多，导致体味，要么就是少汗无汗。
【小便浑浊、起泡沫】痰湿者体液黏稠，因此常见小便浑浊之状。
【舌头胖大，舌苔厚】此时不宜再进行秋冬进呲补，否则痰湿更重。
【经少、经迟甚至闭经】如果痰湿肥胖和月经不调混在一起，将很难治疗。
【动作缓慢，反应迟钝】痰湿者脑部供血不足，往往反应比较迟钝。
【不爱喝水，喝水易腹胀】痰湿者口中黏腻，很少口渴，喝水也不易吸收，易致腹胀。
""",
        illness: """
【肥胖】"胖人多痰湿，瘦人多内热"，痰湿者极易发胖。
【高血压】一般是伴有胸闷、恶心、眩最、肿胀症状的高血压。
【高血脂】痰湿提高了血液黏稠度，容易引发高血脂。
【脂肪肝】饮酒、饮食肥腻、熬夜引起的脂肪肝，多数与痰湿体质有关。
【冠心病】痰湿引发高血脂，再进一步发展就可能引发冠心病。
【脑血管疾病】高血脂、高血压很容易引发脑血管疾病。
【糖尿病】益气健脾化痰燥湿的方药对糖尿病的治疗有一定的疗效。
【痤疮】痰湿体质油皮肤居多，很容易生痤疮。
【胃病】痰湿者往往由饮食不节引起，长此以往就容易患肠胃疾病。
【月经不调】痰湿阻滞血脉，容易形成月经延后、量少甚至闭经。
""",
        reasons: """
久坐，长时间含胸埸背，压迫肺部呼吸浅，再加上有空气污染这祥的习惯会导致氧气不足体内的食物很难代谢，致使痰湿堆积于体内。
长期口味偏咸，食盐太多。口味过重，长期吃盐太多也会增加水湿，既伤脾，也伤肾。
食物肥腻、寒凉，暴饮暴食，常吃减肥药，常发怒、情志不舒展，导致伤肝，转而伤脾。不吃早餐，熬夜吃夜宵，饮酒过多，伤肝转而伤脾，饮食不节易伤脾胃。发怒、熬夜则易伤肝，肝木克脾土，伤肝就容易伤脾。
""",
        mentalCare: "痰湿质的人性格偏温和、稳重，多善于忍耐，反应迟钝，做事迟缓。可以选择读书吟诵、养花赏花调节情志，如玉兰花、杜鹃花和丁香、茉莉等花卉中所含的芳樟醇、芳樟酯和苯甲酸等香味能使人嗅之神清气爽，产生难以名状的轻松愉悦之感。桂花花形虽小，但香气浓郁，浓香四溢，沁人心脾，助人消忧愁、除烦闷。水仙、荷花香气淡雅，清雅高洁，缓缓袭人，使人心神安宁，温情绵绵。菊花与薄荷，香气清淡，使人如释重负，精神放松，思维清晰。",
        fitnessCare: "快走、散步、慢跑、球类、武术、八段锦、五禽戏、太极拳，以及各种舞蹈都适合痰湿质的人进行锻炼。",
        livingCare: """
【少用空调】夏季痰湿者应多出汗，吹空调不利于痰湿的消散。尤其出汗之后立即吹空调更伤身体。
【多晒太阳，洗热水澡】阳光能散湿气，振奋阳气。泡浴直至全身发红，毛孔长开，这样最利于痰湿消散。
【衣服宽松】宽松的天然纤维衣服，利于湿气的散发。痰湿者长时间穿紧身塑形内衣，会致明显口臭。
""",
        diet: """
        【注意控制饮食，多吃清谈食物，忌食厚味寒凉，增强脾对水液的运化能力。
        """,
        seasons: """
【春】初春天气乍暖还寒，春季湿气袭人时，人多不觉察。在春雨连绵的季节里，湿邪可从人的口鼻、肌肤而入；如果不能排出体外，就会滞留在体内，形成湿邪内阻。饮食上可以吃玉米、高粱、薏米、扁豆等。

【夏】夏季阴雨连绵，潮湿炎热。湿最容易困脾，导致脾的功能受扰，出现口中清淡无味、胃口差、消化不良、大便溏稀等脾虚表现。反之，脾虚易聚湿生痰。因此，痰湿质的人在夏季应以健脾袪湿为主，健脾就可以祛湿，可以吃冬瓜、薏米、芡实、赤小豆等。

【秋】早秋多雨多雾，空气潮湿，人体易感受湿邪。因此，在湿气大或阴雨天时不要常开窗，室内最好保持干燥。秋季的清晨，田野间露水大，尽量不要在潮湿的地方劳作，且要多运动。秋季祛湿的同时注意温脾，可以吃胡萝卜、猪肚等。

【冬】冬季气候寒冷，潮湿往往与“寒”并行，要注意保暖，不要受凉，也不要吃太寒凉的食物。冬季饮食要以温补脾胃为主，可以吃鲫鱼、怀山药、大枣等。炒菜时，可适当放点陈皮、胡椒面、花椒粉、辣椒粉等理气化痰、温里散寒的调味品。
"""),
    
    "阳虚质" : ConstitutionDetails(
        name: "阳虚质",
        introduction: "火力不够,阳气不足。怕冷!怕冷!怕冷!要吃热，穿暖。\n明代医家张介宾说:“天之大宝，只此一丸红日;人之大宝，只此一息真阳。”阳虚质就是红日不那么温暖。",
        symptom: """
【消化不良】阳虚者肠胃动力不足，对食物的消化不彻底，经常腹泻。
【畏寒怕冷】阳虚者体内阳气不足，腹部、背部特别怕冷，冬季手冷过肘，足冷过膝。
【脉象沉细无力】阳虚者血液循环的动力不足，往往脉象软弱，沉细无力。
【舌头胖大】阳虚者对体内水分消耗不足，导致舌头胖大娇嫩，边缘有明显的齿痕。
【精神不振】阳虚者肾阳不足，精神萎靡，性格安静，尿颇尿多，性欲减退，常有脱发，黑眼圈等症状。
除了以上症状外，阳虚还可导致夜尿频多、下肢肿胀，女性月经减少、延迟，白带增多等。需要注意的是，以上症状在老年人中很常见，也很正常，不必大惊小怪，但如果出现在年轻人身上，则多半是阳虚。
""",
        illness: """
【发胖、脱发】脉象沉细食欲颇佳的阳虚者，易发胖，且头发容易脱落，形成早秃。
【睡眠不佳】素体阳虚者，睡眠容易惊醒，经常失眠，导致面容憔悴，有黒眼圈。
【骨质疏松】骨质疏松与肾阳关系密切，阳虚者到了更年期以后，易患骨质疏松。慢性结肠炎也与阳虚有着密切关系。
【风湿痹症】阳虚者受风寒湿邪侵袭，血脉不通，从而导致关节风湿疼痛，到中年以后尤其明显。
【水肿】身体阳虚，则阴液不能被蒸腾弥散，而是停滞于局部，如踝关节附近，形成水肿。
【痛经宫寒】阳虚女性常有痛经、月经延后、闭经等症，须及时治疗，否则容易导致宫寒，甚至不孕。
【性功能低下】阳虚者往往性功能低下，女性性冷淡，男性出现阳痿、早泄、滑精等症。
【痤疮】如果是上热下寒，虚阳上浮，就容易导致痤疮炎症反复发作，而且终生落疤，此时清热消炎，反而适得其反。
【受寒则痛】阳虚者受寒则容易出现或加重各种痛症，如胸痹、腹痛、头痛、关节痛等。
【与其他体质混合】阳虚则体内血流不畅，水分无法蒸騰，长此以往，则会促生血瘀、痰湿体质。
""",
        reasons: """
【穿着不保暖】也就是“要风度不要温度”，经常将肩、腰、腿暴露在外，也会导致或加重阳虚。
【纵欲劳累】纵欲、性生活过度、不节制等，均能导致或加重阳虚。
【长期服药】长期使用抗生素、利尿剂、激素类药物、消热解毒中药等I会导致或加重阳虚。
【食物寒凉】经常预防性地喝凉茶，喜欢吃冰冻、寒凉的食物等，也会导致或加重阳虚。
【环境寒凉】在冷库等寒凉环境中工作，或者空调使用过度，也容易形成阳虚。
【先天性禀赋】父母为阳虚体质，或者高龄婚育、孕期过食寒凉食物都可能导致胎儿形成寒凉体质。
""",
        mentalCare: "阳气不足的人常表现出情绪不佳，因此要善于调节自己的情绪，消除或减少不良情绪的影响。阳虚质的人性格多沉静，容易神疲倦怠，消沉，悲观，不喜运动，缺乏性欲。因此，阳虚体质之养生必须加强精神调养，去忧悲，防惊恐，和喜怒，努力消除不良情绪的影响。尤其是老年人要多交朋友，充实晚年生活，移情琴棋书画等，以排遣忧愁和寂寞。",
        fitnessCare: "阳虚体质的人，要增加户外活动，多见阳光，令身体与自然直接接触，阳气就被调动起来走肌表，行使卫外功能，尤其可以增加抗寒的能力。阳虚体质者多为干性皮肤，如果怕生斑，可以在晒太阳的时候做一些防护。比如夏天的时候选上午10点钟以前、下午3点钟以后出门，或者晒冬阳、晒秋阳、晒春阳，还可以涂抹防晒霜。锻炼可根据自己的体能，贵在常年坚持。可选用一些传统的健身功法，如太极拳、太极剑、保健功等。",
        livingCare: """
阳虚体质的人，要增加户外活动，多见阳光，令身体与自然直接接触，阳气就被调动起来走肌表，行使卫外功能，尤其可以增加抗寒的能力。阳虚体质者多为干性皮肤，如果怕生斑，可以在晒太阳的时候做一些防护。比如夏天的时候选上午10点钟以前、下午3点钟以后出门，或者晒冬阳、晒秋阳、晒春阳，还可以涂抹防晒霜。锻炼可根据自己的体能，贵在常年坚持。可选用一些传统的健身功法，如太极拳、太极剑、保健功等。
【注意对身体的保暖】尤其是秋冬季节要注意各关节、腰腹部、颈部、背部、脚部的保暖，頁天尽最少用空调，春宜捂而秋不宜冻。
【多晒太阳】阳虚者应多见阳光，晒太阳时应多做防护，夏天以上午10点之前，下午3点之后出门为宜，中老年人晒太阳，可以预防骨质疏松。
【避免熬夜】熬夜实际上是在调动阳气，使其得不到休整从而加重阳虚，平时晚上不应超过11点睡觉，冬季不超过10点。
【多运动，“动能生阳”】阳虚者应多做户外运动，并长期坚持，运动心力所能及，感兴趣而又方便为原则，同时最好不要大量出汗。
""",
        diet: """
        【少吃或不吃生冷、冰冻食物】食物寒性明显，容易损阳。食用时最好配以温热食物。
        【要减少食盐的摄入】阳虚者摄入食盐过多易致肥胖、肿胀、高血压、小便不利。
        【多吃温热之性的食物】食性温热可补肾阳，缓解阳虚之症。
        【选择适当的烹调方式】吃寒性食物时，应选择焖、蒸、煮、炖的方法，可减少寒凉之性。
        """,
        seasons: """
【春】“春夏养阳，秋冬养阴”，此时气候乍暖还寒，阳虚者尤其要注意保暖，调节情绪，适当锻炼。春季是补阳的最佳时节，应选择一些味甘性平的食物以发寒散邪，扶助阳气。少吃酸性食物，以免肝火偏亢而影响食欲。

【夏】夏季炎热，伹人体阳气外强中干，浮盛于肌肤而内脏空虚，因此反而比其他季节更易伤及阳气。夏季饮食要平淡，无需大补，可在三伏天适当进食羊肉、鸡肉等温补之口。此外，切忌贪食冷饮，也不要长时间待在空调房中。

【秋】秋季逐渐变冷，此时阳虚体质者不能坚持所谓的“春捂秋冻”，应该注意保暖，尤其是早晩较冷，要适当增加衣物。此时阳虚者要注意多吃温热、甘缓的高热最、高营养的食品，如狗肉、羊肉、鹌鹑、核桃仁等，少吃西瓜、苦瓜等寒凉及油腻食物。

【冬】冬季严寒会伤及肾阳、关节，此时阳虚体质者的症状会较为明显，出现夜尿频多、老寒腿、关节痛等症状。在冬至，三九天进补食用羊肉、拘肉、鹿肉或壮腰健肾丸、金匮肾气丸等。此外要注意保暖，但失眠患者要少用电热毯。
"""),
    
    
    //没改
    
    "湿热质" : ConstitutionDetails(
        name: "湿热质",
        introduction: """
        不干净，不清爽，黏糊糊，爱长痘。
        湿热质是一种内环境不清洁，又湿又热，湿热氤氲，排泄不畅的体质。内外皆显得“浊”，不干净。
""",
        symptom: """
【口臭、体味大】身体内外不清洁，就容易形成口臭、体臭，甚至比痰湿体质的体味更难闻。
【面色发黄、油腻】湿热体质者皮肤不佳，偏油性，面部经常给人以油腻的感觉。
【舌苔、牙齿发黄、牙龈红肿】舌苔发黄牙龈红肿都是体内火气太盛的表现。
【大便燥结或黏滞，小便发黄、味大】湿盛则大便黏滞，热盛则大便燥结往往男性阴囊潮湿瘙痒，女性带下色黄，外阴异味大、瘙痒。
【面部生痤疮，局部生痈疽】体内湿热之气聚积，就容易生痤疮如不及时处理，可能会恶化成毒疮。
【情绪急躁】湿热体质越明显，情绪越急躁易怒还容易紧张、压抑、焦虑。
""",
        illness: """
【容颜不佳】头发、皮肤油腻，有头屑，毛孔粗大，痤疮较多，色斑，眼睛浑浊、有血丝，眼屎较多，鼻头红赤，口臭，体臭。
【皮肤病】脂溢性皮炎，酒糟鼻，毛囊炎，痈疽，疮疖肿毒，体癣，足癣，股癣等。
【肝胆疾病】携带肝炎病毒，急性黄疸型肝炎，胆囊炎，胆结石等。
【泌尿生殖系统疾病】尿道炎，膀胱炎，前列腺炎，盆腔炎，宫颈炎，阴道炎，肾炎等。
【酸痛】湿热体质者易出现筋骨肌肉疲劳、腰酸背痛。
""",
        reasons: """
【肝胆脾胃功能失调】长期饮食不节，导致肝胆脾胃功能紊乱，或者患有肝炎，或者是肝炎病表携带者，都很容易形成湿热体质。
【抽烟、喝酒、熬夜】吸烟者往往面容憔悴，牙齿黑黄，喝酒、熬夜则伤肝胆，进而伤脾胃，从而促进湿热体质。
【情绪压抑】长期情绪压抑会伤肝胆，导致体内湿热无法疏泄，如果再借酒浇愁，就更易形成湿热内蕴体质。
【先天遗传】一些具有湿热体质的父母，往往会将其温体质遗传绐下一代。
【环境温热】长期生活在湿热杯境中的人比其他人更易形成湿热内蕴体质。
【滋补过度或滋补不当】滋补过度，或本来己经有内热倾向，又再进补，就很容易促生湿热体质。
""",
        mentalCare: """
湿热质的人性情较急躁，外向好动，常常心烦易怒，甚者发生猝死。因此湿热质的人应该学会控制自己的情绪，学会制怒。尽量少生气，正确对待喜与忧、苦与乐、顺与逆，保持稳定的心态。合理安排自己的工作、学习，培养广泛的兴趣爱好。学会释放不良情绪，通过自我排遣或向别人倾诉，改变心境。

湿热质的人可多欣赏优美音乐，也可以诵读优美的散文与诗歌。除此之外，闲暇之时，种植花草，随身携带香囊，如藿香、佩兰、白芷、迷迭香、菊花、郁金香等，可以使心情舒畅。
""",
        fitnessCare: "湿热体质者适合做强度大、运动量大的运动，如中长跑、游泳、爬山、各种球类、武术等，可以消耗体内多余的热量，排泄多余的水分，达到清热除湿的目的。此外，还可选择太极拳、五禽戏、八段锦、气功、导引等坚持锻炼。",
        livingCare: """
【避免温热环境】应当尽量避免在炎热潮湿的环境中长期生活或工作，可以适当使用空调。
【穿着干爽宽松】应穿着天然纤维质地的衣物，内衣应选择宽松舒适的，不要穿紧身内衣。
【不熬夜保证睡眠】熬夜者往往舌苔黄厚，为湿热之兆。每天应保证7-8小时高质量睡眠。
【多运动增加柔韧度】多做舒展筋骨关节的运动，增加身体柔韧度，这有利于肝胆疏泄，缓解紧张焦虑情绪。

""",
        diet: """
        少吃甜食或辛辣刺激性的食物。
        戒烟忌酒，烟酒都会加重湿热。
        少吃滋补药食，滋补过度会加重湿热。
        少吃油炸煎烤、烟熏、腌制类的食物。
        """,
        seasons: """
【春】春季应多做筋骨肌肉关节的拉伸舒展运动，增加身体的柔韧性，这样可以疏肝利胆，解紧张焦虑情绪。
【夏】湿热体质者在夏季会比较难受，体内湿热排泄不畅，此时应多喝水，也可喝祛署清热利湿的凉茶、绿豆汤等，也可常用空调。
【秋】秋季比较干燥，对湿热体质者也较为不利，此时应多吃水分多、甘甜的水果，多喝白粥，每天早晨喝一杯淡盐水或挂蜜水。
【冬】人们一般喜欢在冬季进补，但对湿热体质者则不适宜。湿热体质者应少吃油賦、热最高的食物。
"""),
    
    "特秉质" : ConstitutionDetails(
        name: "特秉质",
        introduction: """
        过敏，过敏，过敏。
        身体对某些物质有特异性反应，让你不能招架不停的喷嚏，哮喘，皮肤肿胀，风疹等。
        随着城市化的发展，过敏成为了城里人的时髦问题。
""",
        symptom: """
【荨麻疹】荨麻疹(urticaria)是身体由于皮肤粘膜小血管反应性扩张及渗透性增加而产生的一种局限性水肿反应，主要表现为皮肤或粘膜突然发生瘙痒性水肿性风团，色红或苍白，发作急，消退快，消后不留痕迹，俗称”风疹块“。
【哮喘】最新概念强调哮喘是一种气道慢性非特异性炎症性疾病，在哮喘发生发展的过程中，有大量不同种类炎症细胞、炎症介质和细胞因子共同参与；气道高反应性是哮喘的主要特征；典型表现为发作性喘息、咳嗽、咳痰和肺内可闻及呼气相哮鸣音。
【咽痒】主要表现为咽部可有各种不适感觉，如异物感、发痒、灼热、干燥、微痛、干咳、痰多不易咳净，讲话易疲劳，或于刷牙漱口，讲话多时易恶心作呕。
【鼻塞】鼻塞是耳鼻咽喉科常见的症状之一。最常见的原因包括鼻炎，鼻中隔偏曲，鼻息肉，鼻窦炎。理论上来说，鼻塞都可以通过不同的治疗方法进行解决。
【打喷嚏】打喷嚏的现象是指在将进入鼻腔的异物(如灰尘、细菌、花粉等)驱赶时出现的一种无意识的“反射”。异物进入以后，位于鼻粘膜上的三叉神经向作用于肺部的呼吸肌肉发出指令，猛烈地排出空气将异物驱除出境。喷嚏反射，俗称“打喷嚏”。打嚏喷是鼻黏膜受刺激所引起的防御性反射动作。
【流鼻涕】流鼻涕是鼻部常见症状之一，可经前鼻孔流出，也可后流入鼻咽部。流入后鼻孔，经鼻咽、口腔吐出者称后流鼻涕。正常鼻腔中只有少量黏液，呈湿润状态，以维持正常的生理功能。鼻腔有病变时可以引起鼻分泌物性质和量的改变。鼻腔分泌物外溢时，称为流鼻涕。
""",
        illness: """
【过敏性鼻炎】过敏性鼻炎又称变应性鼻炎，鼻腔粘膜的变应性疾病，并可引起多种并发症。另有一型由非特异性的刺激所诱发、无特异性变应原参加、不是免疫反应过程.但临床表现与上述两型变应性鼻炎相似，称血管运动性鼻炎或称神经反射性鼻炎，刺激可来自体外(物理、化学方面)。
【过敏性紫癜】由多种不同病因所致，常见的有细菌病毒，如溶血性链球菌、葡萄球菌、结核杆菌、伤寒杆菌、肺炎球菌、流感病毒、麻疹病毒等等，另外一些病例则因食物过敏，昆虫叮咬，奇生虫感染，或者药物过敏，如磺胺类药，抗生素类药物。
【过敏性哮喘】过敏性哮喘，是指患有哮喘病的人对某种物质具有过敏反应，当病人接触到这种物质后就可诱发哮喘。
【荨麻疹】荨麻疹是身体由于皮肤粘膜小血管反应扩张及渗透性增加而产生的一种局限性水肿反应，主要表现为皮肤或黏膜突然发生瘙痒性水肿或风团，色红或苍白，发作急，消退快，消退后不留痕迹，俗称“风疹块”。
【花粉症】中国的花粉症主要由高原植物引起，主要的致敏植物有黎科、葎草、禾本科、苋、木麻黄等。在美洲，主要致敏植物为豚草，它己蔓延到中国（第二次世界大战时由侵华日军作为饲养马匹的牧草引入中国），可能成为中国另一重要的致敏植物。
""",
        reasons: """
【过敏体质】有过敏性鼻炎、过敏性哮喘、过敏性紫癜、湿疹、荨麻疹等过敏性疾病的人大多都属于这一类。
【遗传病体质】此是指有家族遗传病史或者是先天性疾病的体质者，这一类人群往往是有遗传基因缺馅的，大多很难治愈。
【胎传体质】胎传体质就是母亲在妊妮期间所受的不良影响遗传绐胎儿所造成的一种体质。此体质特征可能会持续一生。也就是说，这种人存在先天特殊条件，什么时候会发作视杯境而定。如果外界杯境控制得好，有可能一輩子也不发作；但如果外界杯境恶化，则有可能引发潜在的发病因素而突然发作。
""",
        mentalCare: """
        特禀质因宿疾缠身，多有烦躁易怒情绪，如何消除烦躁，可考虑如下方法：
        【一】罗列使自己感激不尽的事，与人为善，不要怀恨，用童心拥抱生活，用成熟理解生活，懂得感恩，善待曾善待过自己的人。【二】发展你的兴趣爱好，保持强烈的好奇心和求知欲，保持健康的体魄和心理，防止沉溺在疾病的痛苦之中。
        【三】与他人建立联系，多和亲朋好友谈心。人的精力有限，想做的事却很多，减少不必要的人际约束。
        【四】喜欢并爱护自己。别老想给别人好印象而刻意改变自己，有意栽花花不开，无心插柳柳成荫。
        【五】和卓越竞争而不是和人竞争。
""",
        fitnessCare: "特禀质者应积极参加各种体育锻炼，增强体质。天气寒冷时锻炼要注意防寒工作，防止感冒。日常锻炼中，特禀质的人要适度适量，不可做过于强烈的运动，可根据个人爱好选择有针对性的运动项目。",
        livingCare: """
特禀质的日常起居也要比其他体质的人更加注意。容易过敏者，因为对于环境更加敏感，所以容易出现水土不服。因此，在陌生的环境中要注意日常保健，减少户外活动，避免接触各种致敏的动植物，适当服用预防性药物，减少发病机会。
宠物身上往往带有过敏原，所以特禀质的人最好不养宠物，以免对动物皮毛过敏。特禀质的人凡外出旅游时，可带点自己家乡的水、食品及日常生活用品，以免因水质、食物变化而诱发宿疾。
""",
        diet: """
        特禀体质者应该多吃益气固表的食物，最好常吃糙米、蔬菜和蜂蜜，它们不但能够提供优质的红细胞，又不用担心异体蛋白进入血液，所以能有效防止过敏症状的发生。
        特禀体质者也有一些人对食品添加剂过敏，例如色素、抗氧化剤、防腐剤等，如蜜饯等这类含有添加剂的食物过敏患者应该少吃，以免诱发哮喘。
        易过敏的特禀体质者应该避免或尽重少吃含致敏物质的食物，以免发生意外的过敏反应。
        """,
        seasons: """
【春】春天是花粉传播最广泛的季节，花粉混杂在空气中，从鼻吸入体内后导致过敏症，引起许多过敏性疾病。花粉过敏者外出时可考虑戴眼镜及口罩，尽量不要在草坪玩耍或劳动；注意及时关闭窗户，减少室内自然通风。春天风沙、扬尘天气较多，可吸入颗粒物的浓度增加，会使哮喘发作。外出时戴口罩是避免与过敏原接触的简单而有效的方法。定期开窗通风，使空气流通，居室布置力求简单，不要放花草、地毯等，空调滤网应定期清洁，被褥要勤洗勤晒，以减少螨虫、霉菌等微生物。春天也是变应性鼻炎的好发季节，故一旦出现流鼻涕、打喷嚏、鼻塞等症状，一定不要掉以轻心，应及时治疗。

【夏】特禀质的人夏季饮食应以清淡质软、易于消化为主，少吃高脂厚味及辛辣上火之物。注意不宜吃菠萝等可能导致过敏的水果。

【秋】一般夏秋季的花粉过敏患者比春季要多，症状也较重。特禀质的人秋季外出旅游时尽量少去花草树木茂盛的地方，出游时随身带好抗过敏药。过敏症状较轻的患者来说，在食用水果前先削皮或将水果放在微波炉里加热30秒，可使致敏成分被分解破坏，并且不会使水果熟透。

【冬】冬季养生宜多食热粥，可常食有养心除烦作用的小麦粥、益精养阴的芝麻粥、消食化痰的萝卜粥、养阴固精的胡桃粥、健脾养胃的茯苓粥、益气养阴的大枣粥等。
"""),
    
    "气郁质" : ConstitutionDetails(
        name: "气郁质",
        introduction: """
        敏感，忧郁，常叹息，甚至要求完美到苛刻。
        这些不仅仅是心灵层面的原因。
        由于长期情志不畅、气机郁滞而形成的以性格内向不稳定、忧郁脆弱、敏感多虑为主要表现的体质。
        习惯把情绪都憋在心里，表面上的平静。
""",
        symptom: """
形体消瘦或偏胖；面色苍暗或萎黄；舌头呈淡红色，舌苔发白，脉弦；一旦生病则胸肋胀痛或窜痛；月经前乳房及小腹胀痛，月经不调，痛经；咽中梗阻，如有异物：或颈项痤瘤；胃脘胀痛，泛吐酸水，呃逆嗳气；常常腹部肠鸣，大便干燥，泄利不爽；体内之气逆行，常头痛眩晕，睡眠不佳。
性格以内向为主，寡言少语，内心自卑；经常叹气，莫名其妙、不由自主地叹气；有的个性木讷，温和平稳；有的个性敏感，斤斤计较；性情或急躁易怒，易激动；或忧郁寡欢，胸闷不舒。
""",
        illness: """
【抑郁症】抑郁可引起气郁，抑郁症患者中，多数都是气郁优质者。
【失眠】气郁会导致失眠，而且这种失眠很不好治，吃药效果也不大。
【胀痛】如偏头痛、胸痛、肋间神经痛等，血瘀者一般表现为刺痛，但气郁者一般表现为胀痛。
【月经不调、痛经】气郁会导致脏器功能失调，月经量少与肾有关；月经量多色淡，与脾有关；周期紊乱。
【烦躁病】往往表现为喜怒无常，经常突然晕倒、瘫痪，实际上各种生命体征又十分正常。
【慢性咽炎】咽部有异物感，越是紧张焦虑的时候越要清嗓子、吐唾沫，以此缓解紧张情绪。
【慢性肝炎、胃炎、胆囊炎、结肠炎等】气郁尤其伤肝，长期气血运行不畅，即有可能引起消化系统疾病。
【甲亢】有一种气郁痰结型甲亢，就是因为长期情志不舒、肝气郁结所导致的。
""",
        reasons: """
-
""",
        mentalCare: """
        忧思郁怒、精神苦闷是导致气血郁结的原因所在。气郁体质者的情志调理应以乐观进取、积极向上为基本原则。
        【保持喜乐心情】喜乐能使生活充满欢笑、气血通畅、生机勃勃。古人曰：“志闲而少欲，心安而不惧……美其食，任其服，乐其俗，高下不相慕。”这句话告诫人们要安于自己日常平淡的生活，不要与别人攀比，要随遇而安，知足常乐，情志舒畅。
        【善于交流】向亲人或朋友倾诉，感受朋友之间的友情和家人之间的温暖，也能改变心境。多与性情开朗、心理健康的朋友交往，以此来保持自己良好的精神状态，使肝气舒畅条达，机体气血流畅。独自一人时应保持微笑，笑则气缓，紧张的气氛消失了，抑郁的情绪自然也被抑制住了。
        【积极面对】找出自己抑郁的原因，然后向它们提出挑战。使用理性思维方式挑战自己的观念，要宽容对待自己。树立自信心，建立积极的社会价值观；挑战消极观念，建立新的行为模式，对挫折与失败做好充分的心理准备。善于寻求帮助，不要默默承受。
        【避免服用某些药物】口服避孕药、巴比妥类、可的松、利血平可引起抑郁症，气郁体质者应尽量避免使用。
        """,
        fitnessCare: "生气郁体质者应多参加体育锻炼及户外旅游。运动能活动身体、运行气血，尤其是旅游，既能强健身体，又能在欣赏自然美景时舒展胸怀、调畅情志、改变心境。日常生活中，可常做甩手、叩齿等保健活动。也可选择瑜伽功中的打坐等放松式运动。",
        livingCare: """
【睡眠】气郁体质者容易困倦乏力或失眠，可加重抑郁。因此，调整好睡眠对气郁体质者极为重要。居室应保持安静，禁止喧哗，光线宜暗，避免强烈光线刺激。室内温度宜适中。注意劳逸结合，保证充足的睡眠时间。
【二便】气郁体质者因为气行不畅，大便多不爽或泄利。应该注意日常饮食，多食易消化的食物，杜绝暴饮暴食，应当每日按时排便，使机体形成排便反射。
""",
        diet: """
        多吃具有理气、解郁、消食、醒神等作用的食物，所食之物性宜温平。
        痰郁者平时常吃萝卜，以顺气化痰。萝卜中含有能诱导人体产生干扰素的多种微量元素，可增强机体免疫力，并能抑制癌细胞的生长，对防癌、抗癌有重要意义。
        """,
        seasons: """
【春】春天应注意情志养生，保持乐观开朗的情绪，以使肝气顺达、心胸开阔、情绪乐观。身体要放松，舒坦自然，充满生机。但如果调摄不当，升发太过，往往会激发急躁情绪，出现易于发怒的情况，而导致“怒则气上”的病理表现。所以，春季养生应尽量保护肝的疏泄功能，所谓“生而勿杀，予而勿夺，赏而勿罚”。饮食宜选用辛、甘、微温之品。多吃富含蛋白质、微量元素、B族维生素的食物，避免吃油腻生冷黏硬之物，以免伤胃损阳。

【夏】夏季的高温容易引发焦躁情绪，尤其是气郁之人，更容易伤肝动火。所以，夏季一定要梳理自己的情绪，不要过于激动，更不要发怒急躁。要保持恬静的心理状态，同时要多饮用疏肝理气的保健茶，以清热降火。保持心情舒畅，不急不躁，抑怒降火，以达到“心静自然凉”的效果，防止“内火”自生。古代养生家倡导的“调息静心，常如兆雪在心”就是这个意思。气郁之人应注意忌生冷油腻、肥甘腻补之品，过食则损胃伤脾，影响食物的消化吸收，有碍气机通畅。应该食用清心养肺的食物，以及具有解暑功能的食物。

【秋】气郁质者肝失疏泄，肝火偏旺，久则内耗阴津；秋天气候干燥容易伤人体津液，使机体燥象更为明显。所以，秋季应注意滋阴。同时应该更加重视精神调养，多进行户外运动，有助于通畅气机。多想开心事儿，以平和的心态对待一切事物，以顺应秋季收敛之性，平静地度过“多事之秋”。

【冬】气郁体质者在冬季需要注意调节情志。改变情绪低落的最佳方法就是运动，如慢跑、跳舞、滑冰、打球等。冬日阳气肃杀，夜间尤甚，古人主张冬季要“早卧迟起”。早睡以养阳气，迟起以固阴精。冬属阴，以固护阴精为本，宜少泄津液。故冬季宜“去寒就温”，预防寒冷侵袭。但亦不可太暖，尤忌厚衣重裘、向火醉酒、烘烤腹背、暴暖大汗。冬季容易诱使慢性病复发或加重，寒冷还会诱发心肌梗死、中风的发生，使血压升高和溃疡病、风湿病、青光眼等病症状加剧。因此，这类患者应注意防寒保暖，特别是预防大风降温天气对机体的不良刺激，备好急救药品。同时还应重视耐寒锻炼，提高御寒及抗病能力，预防呼吸道疾病的发生。
"""),
    "血瘀质" : ConstitutionDetails(
        name: "血瘀质",
        introduction: """
        莫名疼痛，无缘故淤青。
        血瘀质就是全身性的血脉不那么畅通，有点儿缓慢淤滞，但是又达不到疾病的程度。“痛则不通，通则不痛”因此血瘀质很容易产生各种以疼痛为主要表现的疾病以及肿瘤包块等。
""",
        symptom: """
口唇发暗，发紫；眼睛浑浊，经常有细小的红血丝；头发地干枯，容易脱发，且很难根治；常见头痛，如针刺一般，非常难受；皮肤干燥，经常有痛痒；面部常见难以化脓的暗紫色小丘疹或结节为主的痤疮，而且痤疮印很难消退；面色晦暗，容易生斑，很难见到白净、清爽的面容；舌头上有瘀点和瘀斑，跷起舌头，可见舌系两边的小静脉曲张；形体偏瘦，有些人食欲也不是很好；身上某些部位是不是会出现一些淤青，或出现肿物包块，尤其冬季较多；表情抑郁、呆板，面部肌肉不灵活；记忆力不佳，经常健忘；肝气不舒展，容易心烦易怒。
""",
        illness: """
【冠心病】血气不通将对心脏产生巨大的损害，冠心病人多见于血瘀体质。
【中风】瘀血发展到脑部，且情况严重时，大脑就会因为缺乏血气而突发中风。
【肥胖并发症】肥胖加血瘀体质，年纪轻轻就有可能患上高血压、中风、冠心病、糖尿病等疾病。
【消瘦】有些血瘀者血气不畅，营养在脉络中被堵塞，无法吸收，怎么吃也不会胖。
【月经不调、痛经】血瘀体质者体内有瘀血，全身气血流通不畅，不通则痛，因此会发生痛经。
【肿瘤】脏腑瘀血过久就容易发展为肿瘤。瘀血体质间夹阴虚体质者也易生肿瘤。
【抑郁症】抑郁容易导致肝气郁结，促生血瘀体质。瘀血体质反过来也会加重抑郁。
【偏头痛、胁肋间神经痛】头部、肝部都是易生瘀血的地方，一旦瘀血，就容易引发疼痛。
【肝硬化】血瘀体质与肝脏的病变有著密切联系，血瘀长期发展，可能会引发肝硬化。
【痤疮】血瘀体质者的痤疮很难透脓，能在面部停留很长时间，留下难以消散的色索沉著。
【黄褐斑】血瘀体质的女性易患痛经、乳腺增生、子宫肌瘤等症，发生这些疾病时，脸上同时会有黄褐斑。
""",
        reasons: """
【七情不调】七话不调，长期抑郁、钻牛角尖，容易伤及肝脏，肝脏长期不舒展，易生血瘀。
【长期服药】药物都要通过肝脏代谢，长期服药会加重肝脏负担，肝脏长期受累。
【受到比较严重的创伤】受创伤后，体内会留有难以彻底消散的瘀血，体质就此发生变化，从而促进生血瘀体质。
【久病不愈】长期慢性病缠身，久治不愈，就容易使血瘀在微循环系统得到发展逐渐促生血瘀体质。
【工作生活环境寒冷】血脉遇寒则凝，长期在寒冷坏境中工作生活易生阳虚体质这种阳虚一般都会间夹瘀血。
""",
        mentalCare: """
        瘀血的重要原因之一是七情不调，血瘀体质者容易心情抑郁急躁。
        【遇事心平气和】经常提醒自己遇事要心平气和、增加耐性。理性地克服情感上的冲动，做到“发之于情”“止之于理”，防止恼怒，让自己恬淡超然。
        【宽以待人】宽恕别人不仅能给自己带来平静和安宁，而且能赢得友谊，保持人际间的融洽。学会与人交往，主动沟通，有困难应主动寻求他人和社会的帮助。合理安排自己的学习、工作，提高学习和工作的热情。尽量不要让压力积压在心里，可以通过自我排遣或与人倾诉，及时释放不良情绪。
        【遇事想得开、放得下】树立科学的人生观、正确的名利观，培养积极乐观的心态来面对生活，热爱生活，知足常乐。过于精细、求全责备常常会产生精神压力，对金钱、名誉、地位以及疾病都要坦然、淡化，任何事都要用积极的态度去思考。
""",
        fitnessCare: "年轻人运动量可相对大一些，如跑步、登山、游泳、乒乓球等。女性可以尝试学习瑜伽，可以消除骨盆内的瘀血，对改善月经不调和卵巢功能低下效果明显。中老年人不宜做高强度的体育锻炼，以轻度运动、微微出汗为宜，如太极拳、太极剑、五禽戏、易筋经、保健功、导引、散步、徒手健身操等。",
        livingCare: """
【睡眠】血瘀体质者睡眠时间宜有规律。按时就寝，不要熬夜，保证足够的睡眠，平均以每天8小时左右为宜。坚持午睡，保持充足的体力。
【二便】便血瘀质的人容易出现大便不爽或便秘，所以日常应注意保证大小便畅通。平时宜多饮水，每天摄水量不低于2000毫升。由于体内的水分通过呼吸、皮肤蒸发和大小便排出，如不及时补充水分，可使血液中水分减少，导致血黏度增高，血行缓慢，促进或加重血瘀形成。
【服饰】血瘀体质者要注意衣着宽松，以使气机条畅、血液运行通畅。还应注意保暖，切不可因追求时尚而虐待自己的身体。
""",
        diet: """
        要避免食用生冷、寒凉之品，或酸涩的食物。
        不吃油炸食品及高脂肪、高胆固醇、高糖的食物。
        不吃甘薯、芋头、蚕豆等容易胀气的食物及各种酱菜、腌制品等过咸的食物。
        补充充足的水分有利于血液循环。一个标准体重的人，每天应该补充大约2000毫升的饮用水。多摄入水分的同时，又能较多地排出水分，这样不仅能够使血流顺畅，更能及时将体内的垃圾排出。早晨起床后和晚上洗澡前各喝1杯水，更利于血瘀体质者的健康。
        """,
        seasons: """
【春】春季养阳敛阴一定要调护肝气，保持心情舒畅。恬淡的情绪能够使人体气机畅通，气血运行和缓。另外，还要学会适度忍耐，避免急躁易怒的情绪。春天新陈代谢旺盛，应以健脾扶阳为食养原则。具有温热特性的食物可以助阳，春季可适当多吃，但不可进食大温大热的补品。饮食宜清淡可口，忌油腻生冷。应适当选择具有温热性质的谷类、水果、蔬菜食用。色青、味酸的食物与春季相应，可养肝胆之气，食之可助长春生之气，但血瘀体质者不宜过多食用酸涩食品，以免加重瘀血程度。多进行户外活动，舒展筋骨，陶冶心境，呼吸自然界的新鲜空气，吐故纳新，但不可过于疲劳。适当的锻炼可以加速新陈代谢，提高适应气候变化、抵抗疾病的能力。切忌久坐不动、久视不移、久睡不起，因为这不仅有碍于肝胆之气的条畅，而且亦容易加重瘀血程度。

【夏】《黄帝内经》认为，人在夏令时节，要做到“无厌于日”，即顺应夏季日出较早、日落较晚的特性，卧迟起早。午餐后应适当休息，以恢复体力。夜晚在空调房中就寝，应将空调温度调至28℃以上，冷气过强也是造成血瘀体质的原因之一。血瘀体质者在酷暑天气不要在烈日下久留，也不可过于贪凉，以免加重气血凝滞；可以尝试“冬病夏治”。夏季饮食一般应以温养为宜，应多食赤色和苦味食物，赤色可以助阳气、养心气，苦味可以清热。但食用任何食物都应适可而止，过量反而会损伤人体。在夏季，人体消化功能较弱，宜食用清淡、易消化食物，不可暴饮暴食。夏季要在清晨或傍晚较凉爽时进行适度的户外活动，多排汗液，不仅可以调节体液代谢，排除体内毒素，“使气得泄”，还可以调节机体阴阳平衡。多接受阳光，享受“日光浴”，可以维持机体阳气的旺盛。

【秋】秋季应养阴气、养肺气、防秋燥。日常起居应遵循“早卧早起，与鸡俱兴”的原则，既要早一点睡觉，又要早一点起床。日常活动不可过度劳累，以防损伤阳气；不可泄汗过多，以防损伤阴液。血瘀体质者，不可“秋冻”，血遇寒则凝，更易形成瘀血。因此，从进入深秋时起就要注意保暖，适时添加衣物。秋季宜食用辛味、色白的食物来养阴润燥，调养肺脏气机。因津液不足而致瘀血者更应注意秋季的调养。

【冬】冬季应该滋养人体阴精，保养阳气。肾应于冬，主藏人体之元阴、元阳，故要以保护肾气为根本。在寒冷的冬天，一定要晚上早睡，待太阳升起之后再起床。冬季谨避寒邪，注意保暖，外出应当多穿衣服；但不能捂得出汗。四肢末端分布着大量的毛细血管，受寒容易出现血管痉挛，加重瘀血。晚上临睡前，用热水浴足，不仅可以缓解疲劳、增加睡意，也是护养阳气的重要做法。冬季节制性生活是保肾藏精的一个重要方面。冬季天气寒冷，为心血管疾病高发的季节，寒凝血瘀者更要加强防护。
""")
    
    
    
    
    
]


// 定义 QuizView
struct QuizView: View {
    @ObservedObject var viewModel : QuizViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView {
                    VStack {
                        ForEach(Array(viewModel.questions.enumerated()), id: \.1.id) { index, question in
                            if index == 0 || question.category != viewModel.questions[index - 1].category {
                                HStack{
                                    Text(question.category)
                                        .font(.title)
                                        .bold()
                                        .padding(.top,60)
                                    Spacer()
                                }
                                
                            }
                            
                            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                                Text(" \(index + 1):")
                                QuestionView(viewModel: viewModel, question: question)
                            }
                            .padding(.vertical)
                            
                            Divider()
                        }
                        NavigationLink(destination: ResultsView(viewModel: viewModel), isActive: $viewModel.showingResults) {
                            EmptyView()
                        }
                        
                        Button(action: {
                            if viewModel.allQuestionsAnswered() {
                                viewModel.showingResults = true
                            } else {
                                let unansweredQuestionNumbers = viewModel.unansweredQuestions().map { $0 + 1 }
                                alertMessage = "以下问题需要回答：\(unansweredQuestionNumbers)"
                                showAlert = true
                            }
                        }) {
                            Text("提交问卷")
                                .padding()
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("提交失败"), message: Text(alertMessage), dismissButton: .default(Text("好")))
                        }
                    }
                    .padding()
                    .padding(.top,-60)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(ThemeColor.background)
            
        }
        .navigationBarTitleDisplayMode(.inline)
        
        .navigationViewStyle(.stack)
    }
}


// 创建问题的实例数组
let sampleQuestions = [
    Question(id: 0, category: "阳虚质", questionText: "您手脚发凉吗？"),
    Question(id: 1, category: "阳虚质", questionText: "您胃脘部、背部或腰膝部怕冷吗？"),
    Question(id: 2, category: "阳虚质", questionText: "您感到怕冷、衣服比别人穿得多吗？ "),
    Question(id: 3, category: "阳虚质", questionText: "您比一般人不了寒冷（冬天的寒冷，夏天的冷空调、电扇等。"),
    Question(id: 4, category: "阳虚质", questionText: "您手脚发凉吗？ "),
    Question(id: 5, category: "阳虚质", questionText: "您比别人容易患感冒吗？"),
    Question(id: 6, category: "阳虚质", questionText: "您吃（喝）凉的东西会感到不舒服或者怕吃（喝）凉东西吗？"),
    Question(id: 7, category: "阳虚质", questionText: "你受凉或吃（喝）凉的东西后，容易腹泻（拉肚子）吗？"),
    
    Question(id: 10, category: "阴虚质", questionText: "您感到手脚心发热吗？ "),
    Question(id: 11, category: "阴虚质", questionText: "您感觉身体、脸上发热吗？ "),
    Question(id: 12, category: "阴虚质", questionText: "您皮肤或口唇干吗？"),
    Question(id: 13, category: "阴虚质", questionText: "您口唇的颜色比一般人红吗？"),
    Question(id: 14, category: "阴虚质", questionText: "您容易便秘或大便干燥吗？"),
    Question(id: 15, category: "阴虚质", questionText: "您面部两潮红或偏红吗？"),
    Question(id: 16, category: "阴虚质", questionText: "您感到眼睛干涩吗？ "),
    Question(id: 17, category: "阴虚质", questionText: "您感到口干舌燥、总想喝水吗？ "),
    
    Question(id: 20, category: "气虚质", questionText: "您容易疲乏吗？"),
    Question(id: 21, category: "气虚质", questionText: "您容易气短（呼吸短促，接不上气吗？"),
    Question(id: 22, category: "气虚质", questionText: "您容易心慌吗 ？"),
    Question(id: 23, category: "气虚质", questionText: "您容易头晕或站起时晕眩吗？"),
    Question(id: 24, category: "气虚质", questionText: "您比别人容易患感冒吗？"),
    Question(id: 25, category: "气虚质", questionText: "您喜欢安静、懒得说话吗？"),
    Question(id: 26, category: "气虚质", questionText: "你容易疲乏吗？"),
    Question(id: 27, category: "气虚质", questionText: "您说话声音无力吗？"),
    Question(id: 28, category: "气虚质", questionText: "您活动量稍大就容易出虚汗吗？"),
    
    
    Question(id: 30, category: "痰湿质", questionText: "您感到胸闷或腹部胀满吗？"),
    Question(id: 31, category: "痰湿质", questionText: "您感到身体沉重不轻松或不爽快吗？"),
    Question(id: 32, category: "痰湿质", questionText: "您腹部肥满松软吗？"),
    Question(id: 33, category: "痰湿质", questionText: "您有额部油脂分泌多的现象吗？"),
    Question(id: 34, category: "痰湿质", questionText: "您上眼睑比别人肿（仍轻微隆起的现象）吗？"),
    Question(id: 35, category: "痰湿质", questionText: "您嘴里有黏黏的感觉吗？"),
    Question(id: 36, category: "痰湿质", questionText: "您平时痰多，特别是咽喉部总感到有痰堵着吗？"),
    Question(id: 37, category: "痰湿质", questionText: "您舌苔厚腻或有舌苔厚厚的感觉吗？"),
    
    
    Question(id: 40, category: "湿热质", questionText: "您面部或鼻部有油腻感或者油亮发光吗？"),
    Question(id: 41, category: "湿热质", questionText: "你容易生痤疮或疮疖吗？"),
    Question(id: 42, category: "湿热质", questionText: "您感到口苦或嘴里有异味吗？"),
    Question(id: 43, category: "湿热质", questionText: "您大使黏滞不爽、有解不尽的感觉吗？"),
    Question(id: 44, category: "湿热质", questionText: "您小便时尿道有发热感、尿色浓（深）吗？"),
    Question(id: 45, category: "湿热质", questionText: "您面部或鼻部有油腻感或者油亮发光吗？"),
    Question(id: 46, category: "湿热质", questionText: "女生：您带下色黄（白带颜色发黄）吗？\n\n男生：您的阴囊部位潮湿吗"),
    
    Question(id: 50, category: "血瘀质", questionText: "您的皮肤在不知不觉中会出现青紫瘀斑（皮下出血）吗？"),
    Question(id: 51, category: "血瘀质", questionText: "您两颧部有细微红丝吗？"),
    Question(id: 52, category: "血瘀质", questionText: "您身体上有哪里疼痛吗？"),
    Question(id: 53, category: "血瘀质", questionText: "您面色晦黯或容易出现褐斑吗？"),
    Question(id: 54, category: "血瘀质", questionText: "您容易有黑眼圈吗？"),
    Question(id: 55, category: "血瘀质", questionText: "您容易忘事（健忘）吗？"),
    Question(id: 56, category: "血瘀质", questionText: "您口唇颜色偏黯吗？"),
    
    
    Question(id: 60, category: "特禀质", questionText: "您没有感冒时也会打喷嚏吗？"),
    Question(id: 61, category: "特禀质", questionText: "您没有感冒时也会鼻塞、流鼻涕吗？"),
    Question(id: 62, category: "特禀质", questionText: "您有因季节变化、温度变化或异味等原因而咳喘的现象吗？"),
    Question(id: 63, category: "特禀质", questionText: "您容易过敏（对药物、食物、气味、花粉或在季节交替、气候变化时）吗？"),
    Question(id: 64, category: "特禀质", questionText: "您的皮肤容易起荨麻疹（风团、风疹块、风疙瘩）吗？"),
    Question(id: 65, category: "特禀质", questionText: "您的因过敏出现过紫癜（紫红色瘀点、瘀斑）吗 ？"),
    Question(id: 66, category: "特禀质", questionText: "您的皮肤一抓就红，并出现抓痕吗？"),
    
    
    
    Question(id: 70, category: "气郁质", questionText: "您感到闷闷不乐、情绪低沉吗？"),
    Question(id: 71, category: "气郁质", questionText: "您容易精神紧张、焦虑不安吗？"),
    Question(id: 72, category: "气郁质", questionText: "您多愁善感、感情脆弱吗？"),
    Question(id: 73, category: "气郁质", questionText: "您容易感到害怕或受到惊吓吗？"),
    Question(id: 74, category: "气郁质", questionText: "您胁肋部或乳房腹痛吗？"),
    Question(id: 75, category: "气郁质", questionText: "您无缘无故叹气吗？"),
    Question(id: 76, category: "气郁质", questionText: "您咽喉部有异物感，且吐之不出、咽之不下吗？"),
    
    
    Question(id: 80, category: "平和质", questionText: "您精力充沛吗？"),
    Question(id: 81, category: "平和质", questionText: "您容易疲乏吗？",reversed: true),
    Question(id: 82, category: "平和质", questionText: "您说话声音无力吗？",reversed: true),
    Question(id: 83, category: "平和质", questionText: "您感到闷闷不乐、情绪低沉吗？",reversed: true),
    Question(id: 84, category: "平和质", questionText: "您比一般 人耐受不了寒冷（冬天的寒冷，夏天的冷空调、电扇）吗？",reversed: true),
    Question(id: 85, category: "平和质", questionText: "您能适应外界自然和社会环境的变化吗？"),
    Question(id: 86, category: "平和质", questionText: "您容易失眠吗？",reversed: true),
    Question(id: 87, category: "平和质", questionText: "您容易忘事（健忘）吗？",reversed: true)
]



struct RadarChartView: View {
    let data: [Double]
    let categories: [String]
    let font : Font
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 绘制雷达图的背景多边形
                RadarChartBackgroundView(categories: categories)
                  
                // 绘制雷达图数据点
                RadarChartDataView(data: data, categories: categories, maxValue: 100)
                  
                // 绘制类别名称
                drawCategoryNames()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func drawCategoryNames() -> some View {
        GeometryReader { geometry in
            let segmentAngle = 2 * .pi / Double(categories.count)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            
            ForEach(0..<categories.count) { index in
                
                let angle = CGFloat(index) * segmentAngle - .pi / 2
                let x = cos(angle) * (radius + 20) + geometry.size.width / 2
                let y = sin(angle) * (radius + 20) + geometry.size.height / 2
                if !categories.isEmpty{
                    Text(categories[index])
                    .foregroundColor(ThemeColor.tint)
                        .position(x: x, y: y)
                        .font(font)
                }
                
            }
        }
    }
}

struct RadarChartBackgroundView: View {
    let categories: [String]
    let divisions: Int = 5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 绘制雷达图的背景多边形和类别名称
                ForEach(0..<divisions) { division in
                    Path { path in
                        let segmentAngle = 2 * .pi / Double(categories.count)
                        let radius = min(geometry.size.width, geometry.size.height) / 2 * CGFloat(division) / CGFloat(divisions)
                        
                        for index in 0..<categories.count {
                            let angle = CGFloat(index) * segmentAngle - .pi / 2
                            let x = cos(angle) * radius + geometry.size.width / 2
                            let y = sin(angle) * radius + geometry.size.height / 2
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                                
                        }
                        
                        path.closeSubpath()
                    }
                    .stroke(ThemeColor.tint, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

struct RadarChartDataView: View {
    let data: [Double]
    let categories: [String]
    let maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 绘制雷达图数据点
                Path { path in
                    let segmentAngle = 2 * .pi / Double(categories.count)
                    
                    for index in 0..<categories.count {
                        let value = data[index]
                        let ratio = value / maxValue
                        let radius = min(geometry.size.width, geometry.size.height) / 2 * CGFloat(ratio)
                        
                        let angle = CGFloat(index) * segmentAngle - .pi / 2
                        let x = cos(angle) * radius + geometry.size.width / 2
                        let y = sin(angle) * radius + geometry.size.height / 2
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    
                    path.closeSubpath()
                }
                .fill(Color.blue.opacity(0.7))
            }
        }
    }
}
