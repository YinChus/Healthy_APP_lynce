

import SwiftUI
import AVFoundation

struct BreathView: View {
    @State private var ballScale: CGFloat = 1.0
    @State private var animationRunning = false
    @State private var breathTip = "吸气"
    @State private var selectedDuration = 1
    @State private var timer: Timer?
    let durations: [Int] = [1, 5, 8]  // 可选的呼吸时间档次
    @StateObject private var audioPlayer = AudioPlayer()
    
    
    var body: some View {
        VStack {
            Spacer()
            
            if animationRunning{
                
                
                
                ZStack{
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .scaleEffect(ballScale)
                        .opacity(0.8)
                    
                    Text(breathTip)
                        .opacity(animationRunning ? 1 : 0)
                        .foregroundColor(ThemeColor.tint)
                        .bold()
                    
                }
            }else{
                VStack(spacing: 30){
                    Text("简介：呼吸是最易学而有效的减压方式，现代医学证明通过有意识的采用腹部控制呼吸的频率与深度，可以促进大脑和身体的氧气供给，从而缓解躯体紧张，帮助大脑放松。")
                    Text("适用：所有人群，尤其适合久坐/运动缺三/轻度紧张/焦虑的人群。")
                    
                    Text("""
1.   鼻子吸气5秒/鼻子呼气5秒
2.   正腹式呼吸，吸气时腹部鼓起，呼气时腹部凹下
""")
                    .padding()
                    .background(.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                
            }
            Spacer()
            VStack {
               
                
                Picker("选择练习时间", selection: $selectedDuration) {
                                    ForEach(durations, id: \.self) { duration in
                                        Text("\(duration) 分钟")
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .opacity(animationRunning ? 0 : 1)
                                .padding()
                                
                
                Button(action: {
                    
                    
                    if animationRunning {
                        stopBreathingAnimation()
                        audioPlayer.toggle()
                        
                    } else {
                        startBreathingAnimation()
                        audioPlayer.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(selectedDuration)*60) {
                          
                            stopBreathingAnimation()
                            audioPlayer.toggle()
                        }
                    }
                    
                    
                }) {
                    Text(animationRunning ? "Stop" : "Start")
                        .padding()
                        .background(.white)
                        .foregroundColor(ThemeColor.tint)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(
            ZStack{
                Rectangle()
                    .foregroundColor(ThemeColor.tint)
                Image("breathBackground")
                                  .resizable()
                                  .scaledToFill()
                                  .opacity(0.5)
                                  
                
            }
                .ignoresSafeArea()
           
        )
    }
    
    private func startBreathingAnimation() {
        animationRunning = true
        animateBreathing()
    }
    
    private func stopBreathingAnimation() {
        animationRunning = false
        withAnimation(.linear(duration: 0.2)) {
            ballScale = 1.0
        }
        breathTip = "吸气"
    }
    
    private func animateBreathing() {
        withAnimation(Animation.easeOut(duration: 5).repeatForever(autoreverses: true)) {
            ballScale = 5
            
            self.timer?.invalidate()
                        self.timer = nil
        }
        
        
            
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                        // Toggle between "吸气" and "呼气"
                        if self.breathTip == "吸气" {
                            self.breathTip = "呼气"
                        } else {
                            self.breathTip = "吸气"
                        }
                    }
    }
}



class AudioPlayer: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    init() {
        if let path = Bundle.main.path(forResource: "breathBGM", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0 // Reset to the beginning of the track
    }
    
    func toggle() {
        if audioPlayer?.isPlaying == true {
            stop()
        } else {
            play()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BreathView()
    }
}

