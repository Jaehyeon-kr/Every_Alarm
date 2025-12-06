import SwiftUI

struct CarDodgeGameView: View {

    var onClear: (() -> Void)? = nil
    
    @State private var carX: CGFloat = 0
    @State private var obstacles: [Obstacle] = []
    @State private var avoidCount = 0
    @State private var goal = 7
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            GeometryReader { geo in
                ZStack {

                    // 배경
                    Image("car_background")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                        .clipped()

                    // 자동차
                    Image("car")
                        .resizable()
                        .frame(width: 80, height: 120)
                        .position(
                            x: geo.size.width/2 + carX,
                            y: geo.size.height - 140
                        )

                    // 장애물 여러 개 렌더링
                    ForEach(0..<obstacles.count, id: \.self) { i in
                        Image("obstacle")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .position(
                                x: geo.size.width/2 + obstacles[i].x,
                                y: obstacles[i].y
                            )
                    }

                    // 회피 카운트 UI
                    VStack {
                        HStack {
                            Text("회피: \(avoidCount) / \(goal)")
                                .foregroundColor(.white)
                                .font(.title2.bold())
                                .padding(.top, 20)
                                .padding(.leading, 20)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }

            // 좌우 이동 버튼
            VStack {
                Spacer()
                HStack(spacing: 60) {
                    Button(action: { moveCar(-60) }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    Button(action: { moveCar(60) }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)
            }

        }
        .onAppear { startGame() }
        .onDisappear { timer?.invalidate() }
    }

    // 자동차 이동
    func moveCar(_ dx: CGFloat) {
        let newX = carX + dx
        if abs(newX) <= 140 {
            carX = newX
        }
    }

    // 3개 장애물 0.5초 간격으로 스폰
    func spawnObstacles() {
        obstacles = []

        for i in 0..<3 {
            let delay = Double(i) * 0.5   // 0.5초 간격

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let randomX = CGFloat.random(in: -140...140)
                obstacles.append(Obstacle(x: randomX, y: -200))
            }
        }
    }

    // 메인 게임 루프
    func startGame() {
        timer?.invalidate()

        spawnObstacles()

        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { t in

            let screenH = UIScreen.main.bounds.height

            // 장애물 아래로 이동
            for i in 0..<obstacles.count {
                obstacles[i].y += 7
            }

            // 자동차 Y 위치
            let carY = screenH - 140

            // 충돌 체크 (정확하게 이미지 기준)
            for obs in obstacles {
                let dx = abs(obs.x - carX)
                let dy = abs(obs.y - carY)

                if dx < 45 && dy < 90 {     // 실제 충돌 범위
                    avoidCount = 0
                    spawnObstacles()
                    return
                }
            }

            // 화면 아래로 충분히 내려간 장애물만 제거
            let beforeCount = obstacles.count
            obstacles = obstacles.filter { $0.y < screenH + 150 } // 더 아래까지 내려가야 제거됨

            // 다 내려가서 제거되었을 때
            if obstacles.isEmpty && beforeCount > 0 {
                avoidCount += 1

                if avoidCount >= goal {
                    t.invalidate()
                    onClear?()
                    return
                }

                spawnObstacles()
            }
        }
    }
}

struct Obstacle {
    var x: CGFloat
    var y: CGFloat
}
