import SwiftUI
import Foundation

import UserNotifications
import SwiftUI

func getNextAlarm(_ alarms: [AlarmItem]) -> Date? {
    let now = Date()
    let futureAlarms = alarms
        .map { $0.time }
        .filter { $0 > now }
        .sorted()

    return futureAlarms.first
}

struct TopRightBanner: View {
    var nextAlarm: Date?
    var onTap: () -> Void

    var body: some View {
        Button(action: { onTap() }) {
            VStack(alignment: .trailing, spacing: 2) {
                Text("⏰ Next Alarm")
                    .font(.caption)
                    .foregroundColor(.white)

                Text(nextAlarm != nil ? timeString(nextAlarm!) : "없음")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 16)
        .padding(.top, 16)
    }

    func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}


func scheduleTestAlarm3Seconds() {
    let content = UNMutableNotificationContent()
    content.title = "Test Alarm"
    content.body = "3초 테스트 알람입니다!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

    let request = UNNotificationRequest(
        identifier: "test_alarm_3sec",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("테스트 알람 실패: \(error)")
        } else {
            print("3초 후 테스트 알람 등록 완료!")
        }
    }
}


func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in
        print("알림 권한: \(granted)")
        if let error = error {
            print("권한 오류: \(error)")
        }
    }
}

func scheduleTestNotification() {
    let content = UNMutableNotificationContent()
    content.title = "알람 테스트"
    content.body = "10초 알람이 정상 작동했습니다!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

    let request = UNNotificationRequest(
        identifier: "test_alarm_10_seconds",
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("알람 등록 실패: \(error)")
        } else {
            print("10초 후 알람 등록 완료!")
        }
    }
}


/// "08:00" → Date
func stringToDate(_ timeString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.date(from: timeString) ?? Date()
}

/// Date → "08:00"
func dateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

struct SideMenu: View {
    @Binding var isOpen: Bool
    @Binding var selectedGame: String
    @Binding var todos: [String]
    @Binding var weeklyAlarms: [String: Date]

    @State private var showAlarmList = false
    @State private var showGameSelector = false
    @State private var showTodoList = false

    var onToggleDarkMode: () -> Void   // ← (1) dark mode 함수 전달받음
    @EnvironmentObject var schemeManager: ColorSchemeManager   // ← (2) theme 상태 받기
    
    var body: some View {
        ZStack(alignment: .leading) {
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { isOpen = false } }

                VStack(alignment: .leading, spacing: 22) {
                    
                    Text("Settings")
                        .font(.title2.bold())
                        .padding(.top, 40)

                    Divider().padding(.vertical, 10)

                    // 요일별 알람 보기
                    Button {
                        showAlarmList = true
                    } label: {
                        HStack {
                            Image(systemName: "alarm")
                            Text("요일별 알람 보기")
                        }
                        .font(.headline)
                    }
                    .sheet(isPresented: $showAlarmList) {
                        AlarmListView(weeklyAlarms: $weeklyAlarms)
                    }

                    // 게임 선택
                    Button {
                        showGameSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller")
                            Text("알람 게임 선택")
                        }
                        .font(.headline)
                    }
                    .sheet(isPresented: $showGameSelector) {
                        GameSelectView(selectedGame: $selectedGame)
                    }

                    // 할 일 목록
                    Button {
                        showTodoList = true
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                            Text("할 일 목록")
                        }
                        .font(.headline)
                    }
                    .sheet(isPresented: $showTodoList) {
                        TodoListView(todos: $todos)
                    }

                    Button {
                        onToggleDarkMode()
                    } label: {
                        HStack {
                            Image(systemName: schemeManager.scheme == .dark ? "sun.max.fill" : "moon.fill")
                            Text(schemeManager.scheme == .dark ? "Light Mode" : "Dark Mode")
                        }
                        .font(.headline)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: 260)
                .background(Color(.secondarySystemBackground))
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: isOpen)
    }
}

import SwiftUI
import Foundation
import UserNotifications
import SwiftUI
import Foundation
import UserNotifications
struct HomeView: View {

    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var goAnalysis = false
    @State private var showMenu = false
    @State private var alarmIsRinging = false

    @AppStorage("selectedGame") var selectedGame: String = "TapGame"
    @State private var todos: [String] = []
    @State private var editingAlarm: AlarmItem? = nil
    @State private var editingTime: Date = Date()

    @EnvironmentObject var schemeManager: ColorSchemeManager
    @State private var isAnalyzed: Bool = false
    @StateObject private var alarmStore = AlarmStore.shared
    @State private var showAlarmEditor = false
    @State private var newAlarmTime: Date = Date()

    @State private var weeklyAlarms: [String : Date] = [
        "월": stringToDate("08:00"),
        "화": stringToDate("08:00"),
        "수": stringToDate("08:00"),
        "목": stringToDate("08:00"),
        "금": stringToDate("08:00")
    ]

    // ---------------------
    // 게임 선택 뷰
    // ---------------------
    @ViewBuilder
    func selectedGameView(onClear: @escaping () -> Void) -> some View {
        switch selectedGame {
        case "CarDodgeGame": CarDodgeGameView(onClear: onClear)
        case "ColorMatch":   ColorMatchGameView(onClear: onClear)
        case "MathGame":     MathGameView(onClear: onClear)
        default:             TapGameView(onClear: onClear)
        }
    }
    func toggleDarkMode() {
        withAnimation(.easeInOut) {
            if schemeManager.scheme == .dark {
                schemeManager.scheme = .light
            } else {
                schemeManager.scheme = .dark
            }
        }
    }
    // ---------------------
    // 본문
    // ---------------------
    var body: some View {
        NavigationStack {
            ZStack {

                Color(.systemBackground).ignoresSafeArea()

                SideMenu(
                    isOpen: $showMenu,
                    selectedGame: $selectedGame,
                    todos: $todos,
                    weeklyAlarms: $weeklyAlarms,
                    onToggleDarkMode: toggleDarkMode   // ← 추가!!
                )

                .zIndex(50)
                
                VStack {
                    HStack {
                        Spacer()

                        TopRightBanner(
                            nextAlarm: getNextAlarm(alarmStore.alarms),
                            onTap: {
                                print("Next Alarm tapped")
                            }
                        )
                    }
                    Spacer()
                }
                .zIndex(999)
                
                ScrollView {
                    VStack(spacing: 24) {

                        // 제목
                        VStack(spacing: 6) {
                            Text("Put your TimeTable.")
                                .font(.largeTitle.bold())
                            Text("Auto Scheduling Alarm")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                        
                        Group {
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(radius: 4)
                            } else {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 300)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "photo")
                                                .font(.system(size: 40))
                                                .foregroundColor(.secondary)
                                            Text("Choose your timetable photo")
                                                .foregroundColor(.secondary)
                                        }
                                    )
                                    .padding(.horizontal)
                            }
                        }

                        VStack(spacing: 16) {

                            if isAnalyzed {

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("AI Setting Alarm")
                                        .font(.headline)

                                    ForEach(["월","화","수","목","금"], id: \.self) { day in
                                        if let time = weeklyAlarms[day] {
                                            Text("\(day) · \(dateToString(time))")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)

                                Button {
                                    // 1) 이전 분석 신호 초기화
                                    isAnalyzed = false
                                    goAnalysis = false

                                    // 2) 타임테이블 결과 초기화
                                    weeklyAlarms = [
                                        "월": stringToDate("08:00"),
                                        "화": stringToDate("08:00"),
                                        "수": stringToDate("08:00"),
                                        "목": stringToDate("08:00"),
                                        "금": stringToDate("08:00")
                                    ]

                                    // 3) 이전 이미지 초기화 → 이것 때문에 이전 결과가 남았던 거임
                                    selectedImage = nil

                                    // 4) 새 이미지 고르기
                                    showPicker = true
                                } label: {
                                    Label("Change Timetable", systemImage: "arrow.clockwise.circle")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }

                                .sheet(isPresented: $showPicker, onDismiss: {
                                    if selectedImage != nil {
                                        goAnalysis = true      // ★ 사진 고른 후 자동 분석 재시작
                                        isAnalyzed = false     // ★ 이전 분석 결과 초기화
                                    }
                                }) {
                                    ImagePicker(selectedImage: $selectedImage)
                                }

                            } else {

                                Button {
                                    showPicker = true
                                } label: {
                                    Label("Select Photo", systemImage: "photo.on.rectangle")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)

                                Button {
                                    if selectedImage != nil {
                                        goAnalysis = true
                                    }
                                } label: {
                                    Label("AI Auto Scheduling", systemImage: "bolt.circle")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedImage == nil ? Color.gray : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .disabled(selectedImage == nil)
                                .padding(.horizontal)
                            }
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved Alarms List")
                                .font(.headline)
                            ForEach(alarmStore.alarms) { alarm in
                                HStack {

                                    // (1) Row 클릭 시 수정 버튼
                                    Button {
                                        editingAlarm = alarm
                                        editingTime = alarm.time
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(dateToString(alarm.time))
                                                .font(.headline)
                                            Text(alarm.title)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)

                                    // (2) 토글 (삭제 버튼 바로 왼쪽)
                                    Toggle("", isOn: Binding(
                                        get: { alarm.isEnabled },
                                        set: { _ in alarmStore.toggle(alarm) }
                                    ))
                                    .labelsHidden()
                                    .frame(width: 50)

                                    // (3) 삭제 버튼 (맨 오른쪽)
                                    Button {
                                        alarmStore.delete(alarm)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.leading, 4)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }



                        }
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                        
                        // 스크롤 안, "Your Alarms" 아래에 추가
                        Button {
                         
                            showAlarmEditor = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Alarm")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }

                        .padding(.horizontal)
                        .padding(.top, 10)

                    }
                    
                    // 테스트용 3초 알람
                    Button {
                        scheduleTestAlarm3Seconds()
                    } label: {
                        HStack {
                            Image(systemName: "clock.badge.checkmark")
                            Text("Test Alarm (3 sec)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)

                }
                .zIndex(1)

                // ---------------------
                // 상단 메뉴 버튼
                // ---------------------
                VStack {
                    HStack {
                        Button {
                            withAnimation { showMenu.toggle() }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 26))
                                .padding(12)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(100)

                // ---------------------
                // 다크모드 버튼
                // ---------------------
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        Button(action: toggleDarkMode) {
//                            Image(systemName: schemeManager.scheme == .dark ? "sun.max.fill" : "moon.fill")
//                                .foregroundColor(.white)
//                                .padding(10)
//                                .background(Color.black.opacity(0.5))
//                                .clipShape(Circle())
//                        }
//                        .padding(.trailing, 18)
//                        .padding(.bottom, 32)
//                    }
//                }
                

            } // ZStack 끝

            // 시트 및 네비게이션
            .sheet(isPresented: $showPicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .navigationDestination(isPresented: $goAnalysis) {
                if let img = selectedImage {
                    AnalysisView(
                        inputImage: img,
                        weeklyAlarms: $weeklyAlarms,
                        onAnalysisDone: { isAnalyzed = true }
                    )
                    .id(UUID())   // ← 이거 없으면 절대 갱신 안됨!!
                }
            }


        } // NavigationStack 끝
        
        .onAppear {
            AlarmNotificationDelegate.shared.register()
            AlarmAudioManager.shared.startSilentMode()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AlarmDidFire"))) { _ in
            alarmIsRinging = true
        }
        .sheet(isPresented: $showAlarmEditor) {
            AlarmEditView(
                selectedTime: $newAlarmTime,   // ← Binding으로 넘기기
                onSave: { newTime in
                    alarmStore.addAlarm(time: newTime, title: "Custom Alarm")
                    showAlarmEditor = false
                }
            )
        }
        .sheet(isPresented: $alarmIsRinging) {
            selectedGameView {
                alarmIsRinging = false
                AlarmAudioManager.shared.stopAlarmSound()
            }
        }
        .sheet(item: $editingAlarm) { alarm in
            AlarmEditView(
                selectedTime: Binding(
                    get: { editingTime },
                    set: { editingTime = $0 }
                ),
                onSave: { newTime in
                    var updated = alarm
                    updated.time = newTime
                    alarmStore.update(updated)
                    editingAlarm = nil  // 시트 닫기
                }
            )
        }

    }
}
