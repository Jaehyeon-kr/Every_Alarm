from ultralytics import YOLO

model = YOLO("checkpoints/best1.pt")
model.export(format="coreml", imgsz=640)
