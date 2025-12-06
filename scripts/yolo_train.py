from ultralytics import YOLO
import torch
import numpy as np

if __name__ == "__main__":

    model = YOLO("yolo11n.pt") 

    model.train(
        data="dataset.yaml",
        epochs=5,
        imgsz=640,
        batch=8,
        workers=4,
        lr0=1e-3,
        optimizer='adamW',
        pretrained=True,
    )


