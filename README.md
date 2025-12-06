# Personalize Alarm

<div align="center">

![Everytime Schedule Detection](main.png)

**에브리타임 시간표를 자동으로 인식하여 알람을 설정하는 iOS 앱**

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![YOLOv11](https://img.shields.io/badge/YOLOv11-Object%20Detection-green.svg)](https://github.com/ultralytics/ultralytics)
[![Swift](https://img.shields.io/badge/Swift-iOS-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)


</div>

---

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [설치 및 실행](#-설치-및-실행)
- [사용 방법](#-사용-방법)
- [프로젝트 구조](#-프로젝트-구조)
- [데모 영상](#-데모-영상)
- [한계점 및 향후 계획](#-한계점-및-향후-계획)
- [기여](#-기여)
- [라이선스](#-라이선스)

---

## 🎯 프로젝트 소개

**Personalize Alarm**은 대학생들이 필수적으로 사용하는 **에브리타임(Everytime)** 앱의 시간표 스크린샷을 자동으로 분석하여, 수업 시작 시간에 맞춰 알람을 설정해주는 iOS 애플리케이션입니다.

### 🔍 핵심 아이디어

- **문제**: 매 학기 시간표가 바뀔 때마다 수동으로 알람을 설정하는 번거로움
- **해결**: YOLOv11 객체 인식 모델을 활용한 시간표 자동 분석 및 알람 설정
- **가치**: 시간표 이미지 업로드만으로 자동화된 알람 시스템 구축

### 🛠 기술적 특징

1. **합성 데이터 생성**: PIL 라이브러리를 활용한 시간표 이미지 자동 생성
2. **YOLOv11n 모델**: 모바일 환경에 최적화된 경량 객체 인식 모델
3. **다크모드 지원**: 화이트/다크 모드 모두 인식 가능
4. **CoreML 변환**: iOS에서 실시간 추론 가능한 모델 포맷

---

## ✨ 주요 기능

- ✅ **시간표 이미지 자동 인식**: 에브리타임 시간표 스크린샷에서 수업 시간 추출
- ✅ **합성 데이터 생성**: 다양한 시간표 패턴의 학습 데이터 자동 생성
- ✅ **YOLOv11 학습**: 커스텀 시간표 데이터셋으로 모델 학습
- ✅ **다크모드 대응**: 화이트/다크 테마 모두 인식
- ✅ **iOS 앱 연동**: CoreML 모델로 변환하여 iOS 앱에 통합

---

## 🔧 기술 스택

### AI/ML
- **Python 3.8+**
- **YOLOv11n** (Ultralytics)
- **PyTorch**
- **OpenCV**
- **PIL (Pillow)**
- **NumPy**

### iOS
- **Swift**
- **CoreML**
- **UIKit/SwiftUI**

### 데이터
- **YOLO 포맷** 라벨링
- **합성 데이터 생성** (PIL 기반)

---

## 🚀 설치 및 실행

### 사전 요구사항

```bash
Python 3.8 이상
pip 패키지 관리자
```

### 1. 저장소 클론

```bash
git clone https://github.com/yourusername/Personalize_Alarm.git
cd Personalize_Alarm
```

### 2. 필수 패키지 설치

```bash
pip install ultralytics opencv-python pillow numpy torch
```

### 3. 폰트 설정 (Windows)

프로젝트는 한글 폰트(`malgun.ttf`)를 사용합니다. Windows 환경에서는 기본 경로가 설정되어 있으나, Mac/Linux는 폰트 경로를 수정해야 합니다.

```python
# schedule_img_aug.py 183-185번째 줄
FONT_TIME = ImageFont.truetype("/path/to/your/font.ttf", 40)
```

---

## 📖 사용 방법

### Step 1: 학습 데이터 생성

합성 시간표 이미지를 생성합니다. 인자로 생성할 이미지 개수를 지정합니다.

```bash
python schedule_img_aug.py 10000
```

**출력 결과:**
- `dataset/train/images/` - 생성된 시간표 이미지
- `dataset/train/labels/` - YOLO 포맷 라벨 파일

**파라미터:**
- `10000`: 생성할 이미지 개수 (권장: 5000~10000장)

> ⚠️ **주의**: 이미지 개수가 많을수록 성능이 향상되지만, 저장 공간을 고려하세요.

### Step 2: YOLOv11 모델 학습

생성된 데이터로 YOLOv11n 모델을 학습합니다.

```bash
python yolo_train.py
```

**학습 파라미터:**
- `epochs`: 5 (기본값)
- `imgsz`: 640
- `batch`: 8
- `optimizer`: AdamW
- `lr0`: 1e-3

**학습 결과:**
- `runs/detect/trainX/weights/best.pt` - 최적 가중치
- `runs/detect/trainX/results.png` - 학습 그래프
- `runs/detect/trainX/confusion_matrix.png` - 혼동 행렬

### Step 3: 모델 추론 테스트

학습된 모델로 시간표 이미지를 추론합니다.

```bash
python true_inference.py --weights ./checkpoints/best.pt --img_path white_test.jpg
```

**출력 결과:**
```
요일별 첫 수업 시작
월요일 : 9시
화요일 : 10시
수요일 : 수업 없음
목요일 : 11시
금요일 : 9시

시각화 완료 → result_visualized.jpg 로 저장됨
```

![Inference Result](ddd.jpg)

### Step 4: CoreML 모델 추출 (iOS 배포)

iOS 앱에서 사용하기 위해 PyTorch 모델을 CoreML 포맷으로 변환합니다.

```bash
# Mac 환경
python extract_model_for_Swift.py

# Windows 환경 - Google Colab 사용
# Colab에 코드 업로드 후 실행
```

**출력 결과:**
- `best1.mlpackage` - iOS에서 사용 가능한 CoreML 모델

---

## 📁 프로젝트 구조

```
Personalize_Alarm/
├── README.md                      # 프로젝트 문서
├── dataset.yaml                   # YOLO 데이터셋 설정
├── schedule_img_aug.py            # 합성 시간표 이미지 생성
├── labeling.py                    # 데이터 라벨링 유틸
├── yolo_train.py                  # YOLOv11 모델 학습
├── true_inference.py              # 모델 추론 및 시간표 분석
├── yolo_inference.py              # 기본 추론 스크립트
├── extract_model_for_Swift.py    # CoreML 모델 변환
│
├── dataset/                       # 학습/검증 데이터셋
│   ├── train/
│   │   ├── images/                # 학습 이미지
│   │   └── labels/                # YOLO 라벨 (.txt)
│   └── val/
│       ├── images/                # 검증 이미지
│       └── labels/                # YOLO 라벨 (.txt)
│
├── checkpoints/                   # 학습된 모델 가중치
│   ├── best1.pt
│   ├── best2.pt
│   └── best3.pt
│
└── runs/                          # 학습 결과 로그
    └── detect/
        ├── train/
        ├── train2/
        └── ...
```

---

## 🎬 데모 영상

> 🎥 데모 영상을 추가 예정입니다.

---

## 🔬 핵심 기술 상세

### 1. 합성 데이터 생성 (schedule_img_aug.py)

- **PIL 라이브러리**를 활용한 프로그래매틱 이미지 생성
- **다크/화이트 모드** 랜덤 적용 (50:50 비율)
- **YOLO 포맷** 자동 라벨링
- **다양한 강의 패턴** 랜덤 생성

**클래스 정의:**
- `Class 0`: 강의 블록 (수업 시간대)
- `Class 1`: 시간 라벨 (9시, 10시, ...)

### 2. 객체 인식 모델 (yolo_train.py)

- **YOLOv11n**: 모바일 최적화 경량 모델
- **Transfer Learning**: 사전 학습된 가중치 활용
- **AdamW Optimizer**: 안정적인 학습

### 3. 시간표 분석 알고리즘 (true_inference.py)

```python
def extract_time_schedule(detections, W, H):
    # 1. 요일 가로줄 감지 (cls=1)
    # 2. 강의 블록 감지 (cls=0)
    # 3. X 좌표 → 요일 매핑
    # 4. Y 좌표 → 시간 계산 
    # 5. 요일별 첫 수업 추출 (첫 수업과 요일 맨 윗줄간의 간격)
```

**동작 과정:**
1. YOLOv11 모델이 시간표 이미지에서 객체 감지
2. 감지된 박스를 클래스별로 분류 (강의/시간)
3. 요일 가로줄 박스를 기준으로 시간 영역 계산
4. 각 강의 블록의 X 좌표로 요일 판별
5. Y 좌표로 시간대 계산
6. 요일별 가장 빠른 수업 시간 추출

---

## ⚠️ 한계점 및 향후 계획

### 현재 한계점

- ❌ 특정 시간표 포맷(에브리타임)에만 최적화
- ❌ 실제 사용자 데이터 부족 (합성 데이터만 사용)
- ❌ iOS 앱 UI/UX 개선 필요

### 향후 계획

- ✅ **다양한 시간표 포맷** 지원 (학교별 커스터마이징)
- ✅ **실사용자 데이터** 수집 및 재학습
- ✅ **앱 기능 확장**: 알람 커스터마이징, 푸시 알림
- ✅ **Android 버전** 개발
- ✅ **OCR 통합**: 강의명, 강의실 정보 추출
- ✅ **수업별 맞춤 알람**: 수업 전 10분, 30분 등 설정 가능

---

## 🤝 기여

프로젝트에 기여하고 싶으신 분들은 다음 절차를 따라주세요:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 라이선스

이 프로젝트는 AGPL v3 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 👨‍💻 개발자

- **GitHub**: [@Jaehyeon-kr](https://github.com/Jahyeon-kr)
- **Email**: qmdlghfl2@gmail.com

---

## 🙏 감사의 말

- [Ultralytics YOLOv11](https://github.com/ultralytics/ultralytics) - 객체 인식 프레임워크
- [Everytime](https://everytime.kr/) - 시간표 포맷 참고

---

<div align="center">

**⭐ 이 프로젝트가 도움이 되셨다면 Star를 눌러주세요!**

Made with ❤️ by Personalize Alarm Team

</div>
