import os
import random
from PIL import Image, ImageDraw, ImageFont
import numpy as np


def generate_timetable(idx):
    W, H = 1080, 1920

    if random.random() < 0.5:
        BG = (255, 255, 255)       
        TEXT_COLOR = (20, 20, 20)  
        GRID_COLOR = (120, 120, 120)
    else:
        BG = (25, 25, 25)          
        TEXT_COLOR = (230, 230, 230)
        GRID_COLOR = (60, 60, 60)

    img = Image.new("RGB", (W, H), color=BG)
    draw = ImageDraw.Draw(img)

    LEFT_MARGIN = 120
    TOP_MARGIN = 80

    day_width = (W - LEFT_MARGIN) // len(DAYS)
    time_height = (H - TOP_MARGIN) // len(TIMES)

    boxes = []


    for i, t in enumerate(TIMES):
        y = TOP_MARGIN + i * time_height

        draw.line([(LEFT_MARGIN, y), (W, y)], fill=GRID_COLOR, width=2)

        display_t = t if t <= 12 else t - 12
        time_text = f"{display_t}"

        bbox = draw.textbbox((0, 0), time_text, font=FONT_TIME)
        text_w = bbox[2] - bbox[0]

        text_x = LEFT_MARGIN - text_w - 20
        text_y = y + 4

        draw.text((text_x, text_y), time_text, fill=TEXT_COLOR, font=FONT_TIME)

        bbox = draw.textbbox((text_x, text_y), time_text, font=FONT_TIME)
        x1b, y1b, x2b, y2b = bbox

        x1 = max(0, min(W, x1b))
        y1 = max(0, min(H, y1b))
        x2 = max(0, min(W, x2b))
        y2 = max(0, min(H, y2b))

        bw = (x2 - x1) / W
        bh = (y2 - y1) / H
        xc = (x1 + x2) / 2 / W
        yc = (y1 + y2) / 2 / H

        if 0 < xc < 1 and 0 < yc < 1 and 0 < bw < 1 and 0 < bh < 1:
            boxes.append([1, xc, yc, bw, bh])

    for d, name in enumerate(DAYS):
        x_center = LEFT_MARGIN + d * day_width + day_width // 2 - 10
        draw.text((x_center, 25), name, fill=TEXT_COLOR, font=FONT_DAY)


    day_line_y1 = 10
    day_line_y2 = 110

    x1 = LEFT_MARGIN
    x2 = W

    xc = (x1 + x2) / 2 / W
    yc = (day_line_y1 + day_line_y2) / 2 / H
    bw = (x2 - x1) / W
    bh = (day_line_y2 - day_line_y1) / H

    boxes.append([1, xc, yc, bw, bh])

    for d in range(len(DAYS)):
        num_classes = random.randint(1, 3)
        used = set()

        for _ in range(num_classes):
            start_t = random.choice(TIMES)
            while start_t in used:
                start_t = random.choice(TIMES)
            used.add(start_t)

            duration = random.choice([1, 2, 3])
            if start_t == TIMES[-1] and duration > 1:
                duration = 1

            x1 = LEFT_MARGIN + d * day_width + 10
            x2 = LEFT_MARGIN + (d + 1) * day_width - 10

            y1 = TOP_MARGIN + (start_t - TIMES[0]) * time_height + 5
            y2 = y1 + duration * time_height - 10

            y1 = max(0, min(y1, H - 2))
            y2 = max(y1 + 1, min(y2, H - 1))

            xc = (x1 + x2) / 2 / W
            yc = (y1 + y2) / 2 / H
            bw = (x2 - x1) / W
            bh = (y2 - y1) / H

            if not (0 < xc < 1 and 0 < yc < 1 and 0 < bw < 1 and 0 < bh < 1):
                continue

            boxes.append([0, xc, yc, bw, bh])

            color = tuple(np.random.randint(80, 200, 3))
            draw.rectangle([x1, y1, x2, y2], fill=color)

            course = random.choice(COURSES)
            room = random.choice(ROOMS)
            text = f"{course}\n{room}"
            draw.multiline_text((x1 + 10, y1 + 10), text, fill=(255, 255, 255), font=FONT_CLASS)


    img_path = f"dataset/train/images/timetable_{idx:04}.jpg"
    label_path = f"dataset/train/labels/timetable_{idx:04}.txt"

    img.save(img_path)

    with open(label_path, "w") as f:
        for b in boxes:
            f.write(" ".join(map(str, b)) + "\n")

    return img_path, label_path



if __name__ == "__main__":
    os.makedirs("dataset/train/images", exist_ok=True)
    os.makedirs("dataset/train/labels", exist_ok=True)

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("SET_NUM", type=int, default=7000)
    args = parser.parse_args()
    SET_NUM = args.SET_NUM

    COURSES = [
        "인공지능개론", "자료구조", "알고리즘", "선형대수",
        "운영체제", "컴퓨터네트워크", "머신러닝", "딥러닝",
        "Statistics", "Open Source SW", "Programming(2)",
        "경영과학", "경제학", "Software Engineering"
    ]

    ROOMS = ["미래관-206", "프론티어관-501", "다산관-311", "아름관-405", "다산관-310"]

    DAYS = ["월", "화", "수", "목", "금"]

    TIMES = list(range(9, 18))  

    FONT_TIME = ImageFont.truetype("C:/Windows/Fonts/malgun.ttf", 40)
    FONT_DAY = ImageFont.truetype("C:/Windows/Fonts/malgun.ttf", 38)
    FONT_CLASS = ImageFont.truetype("C:/Windows/Fonts/malgun.ttf", 30)

    for i in range(SET_NUM):
        generate_timetable(i)

    print(f"완료! 배경색 랜덤 포함 Synthetic 시간표 {SET_NUM}장 생성됨.")
