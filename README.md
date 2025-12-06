
# Personalize_Alarm
##
![img]("white_test.jpg")

##

## Main Language 
- Tech : python
- Serivce : Swift

## Contents

- Introduction
- Demo Video 
- Yolo Tech
- Main Contribution
- Limitation
- FutureWork

###

## Introduction 
- Tech Process Sub  

에브리타임 **스케쥴 형식의 학습 이미지**를 직접 원하는 만큼 증강하여 제작하는 코드부터 **Yolo11n**을 train, inference하는 Process를 담은 코드를 제공합니다. 

- Service Process Sub 

**Every_ALARM**은 대학생들의 필수 어플 **에브리 타임의 시간표**를 바탕으로 자동으로 알람을 설정해주는 기능을 제공하는 **IOS Application** 입니다.

###

## Demo Video 





###
## Yolo Tech  

**Step 1. Make Train Data**
- python schedule_img_aug.py 10000

위의 실행을 통해 PIL Library를 활용하여 사용자의 다크 모드, 화이트 모드에 대응할 수 있는 학습용 에브리타임 시간표 이미지를 증강하여 생성합니다. 

데이터는 많을 수록 성능이 좋아질 수 있으나, 컴퓨터나 노트북의 저장공간을 생각합시다.

이때 이미지의 저장경로는 ./datasets에 저장됩니다.
###
**Step 2. Train Yolo.**
- python yolo_train.py 

저는 모바일에 가볍게 올릴 수 있도록 모델 사이즈를 고려했습니다. yolo11의 사이즈는 s/n/l/g 등이 있습니다.
###
**Step 3. Inference Yolo.**
- python true_inference.py --weights ./checkpoints/best.pt --img_path white_test.jpg 

위와 같이 argment를 parsing하여 전달하면 원하는 weight와 원하는 img를 inference 해볼 수 있습니다. 이를 통해 yolo train이 원활하게 이루어졌는지 확인할 수 있습니다. 

![result_img](ddd.jpg)
###
**Step 4. Extract_Model**
- python extract_model_for_Swift.py 

여기서부터는 서비스 제작의 과정과 연결됩니다. 

**Swift**로 모델을 서빙하기 위해서는 Swift에서 요구하는 형식에 맞게 **package**를 제작해야 합니다. 

위 코드는 **Mac**에서 살행 가능하며 **윈도우**는 실행하기 위해선 **Colab** 을 활용해 추출해낼 수 있습니다.

###
## IOS service: Evey_Alarm

### System Front Diagram






### 










