import SwiftUI

struct AnalysisView: View {
    let inputImage: UIImage

    @Binding var weeklyAlarms: [String : Date]

    // 🔥 HomeView에서 전달받는 콜백
    var onAnalysisDone: () -> Void

    @State private var detections: [Detection] = []
    @State private var schedule: [String: Int?] = [:]
    @State private var alarmTimes: [String: Int] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text("시간표 분석 결과")
                    .font(.title)
                    .bold()

                // ------------------------------
                // 원본 이미지 + 감지 박스
                // ------------------------------
                ZStack {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFit()

                    GeometryReader { geo in
                        ForEach(detections) { det in
                            let rect = det.toCGRect(
                                imageWidth: geo.size.width,
                                imageHeight: geo.size.height
                            )

                            Rectangle()
                                .stroke(det.classIndex == 0 ? .green : .blue, lineWidth: 2)
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                                .opacity(0)     
                                // .hidden()    // 또는 이걸로 완전 숨김
                        }
                    }

                }
                .frame(height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)

                // ------------------------------
                // 요일별 첫 수업 & 알람 설정
                // ------------------------------
                VStack(alignment: .leading, spacing: 16) {
                    Text("📅 요일별 첫 수업 및 알람 설정")
                        .font(.headline)

                    ForEach(["월","화","수","목","금"], id: \.self) { day in
                        VStack(alignment: .leading, spacing: 6) {

                            let classTime = schedule[day] ?? nil

                            HStack {
                                Text("\(day)요일")
                                    .font(.system(size: 17, weight: .semibold))

                                Spacer()
                                Text(classTime == nil ? "첫 수업: 없음" : "첫 수업: \(classTime!)시")
                                    .foregroundColor(.gray)
                            }

                            if let ctime = classTime {
                                HStack {
                                    Text("알람 시간")
                                    Spacer()

                                    Picker("", selection: Binding(
                                        get: { alarmTimes[day, default: max(ctime - 1, 0)] },
                                        set: { alarmTimes[day] = $0 }
                                    )) {
                                        ForEach(0..<24) { h in
                                            Text("\(h)시").tag(h)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            } else {
                                Text("해당 요일은 수업이 없습니다.")
                                    .foregroundColor(.gray)
                                    .italic()
                            }

                            Divider()
                        }
                    }

                    // ----------------------------------
                    // 📌 알람 저장 버튼
                    // ----------------------------------
                    Button(action: {
                        saveAlarms()
                        onAnalysisDone()   // 🔥 HomeView에 "분석 완료" 전달
                    }) {
                        Text("📌 알람 저장하기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 3)

            }
            .padding()
            .onAppear {
                runAnalysis()
            }
        }
    }

    // --------------------------
    // YOLO 분석
    // --------------------------
    func runAnalysis() {
        let engine = YOLOEngine.shared
        detections = engine.runYOLO(image: inputImage)

        schedule = engine.computeSchedule(
            from: detections,
            imageWidth: inputImage.size.width,
            imageHeight: inputImage.size.height
        )

        for day in ["월","화","수","목","금"] {

            guard let classTime = schedule[day] ?? nil else {
                // ❌ 수업 없음 → 알람 제거
                weeklyAlarms.removeValue(forKey: day)
                alarmTimes.removeValue(forKey: day)
                continue
            }

            // 수업 있음 → 정상 처리
            let alarmHour = max(classTime - 1, 0)
            alarmTimes[day] = alarmHour

            if let date = Calendar.current.date(
                bySettingHour: alarmHour,
                minute: 0,
                second: 0,
                of: Date()
            ) {
                weeklyAlarms[day] = date
            }
        }

    }


    // --------------------------
    // 알람 저장
    // --------------------------
    func saveAlarms() {
        for (day, date) in weeklyAlarms {
            // weeklyAlarms에 있는 요일만 저장 = 수업 있는 날만 저장됨
            let alarm = AlarmItem(
                time: date,
                title: "\(day) AI Alarm",
                repeatDays: [day],
                isEnabled: true,
                isAI: true
            )
            AlarmStore.shared.add(alarm)
        }

        onAnalysisDone()
    }

}
