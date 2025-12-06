from PIL import Image
from ultralytics import YOLO
import argparse

if __name__=="__main__":
    
    img = Image.open("alarm_data1.jpg")
    print(img.size)

    model = YOLO("runs/detect/train14/weights/best.pt")

    model.predict(
        source="alarm_data1.jpg",
        save=True,
        save_txt=True,
        imgsz=1179,
        conf=0.9  
    )