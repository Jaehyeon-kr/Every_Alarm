import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk
import os

SAVE_DIR = "manual_labels"
os.makedirs(SAVE_DIR, exist_ok=True)

class LabelTool:
    def __init__(self, root):
        self.root = root
        self.root.title("YOLO Label Tool")

        self.image_path = None
        self.img = None
        self.tk_img = None

        self.canvas = tk.Canvas(root, cursor="cross")
        self.canvas.pack(fill="both", expand=True)

        self.bboxes = []       # (cls, x1, y1, x2, y2)
        self.start_x = None
        self.start_y = None

        # 메뉴
        menu = tk.Menu(root)
        root.config(menu=menu)

        file_menu = tk.Menu(menu)
        menu.add_cascade(label="파일", menu=file_menu)
        file_menu.add_command(label="이미지 열기", command=self.load_image)
        file_menu.add_command(label="YOLO 저장", command=self.save_yolo)
        file_menu.add_separator()
        file_menu.add_command(label="종료", command=root.quit)

        # 마우스 이벤트
        self.canvas.bind("<Button-1>", self.start_draw)
        self.canvas.bind("<B1-Motion>", self.draw_rect)
        self.canvas.bind("<ButtonRelease-1>", self.finish_draw)

        # 현재 임시 박스 ID
        self.rect_id = None

    def load_image(self):
        self.image_path = filedialog.askopenfilename(
            filetypes=[("Image Files", "*.jpg *.png *.jpeg")]
        )
        if not self.image_path:
            return
        
        self.img = Image.open(self.image_path)
        self.tk_img = ImageTk.PhotoImage(self.img)

        self.canvas.delete("all")
        self.canvas.create_image(0, 0, anchor="nw", image=self.tk_img)

        self.bboxes = []
        print(f"이미지 로드됨: {self.image_path}")

    def start_draw(self, event):
        self.start_x = event.x
        self.start_y = event.y

        # 임시 박스 제거
        if self.rect_id:
            self.canvas.delete(self.rect_id)
        self.rect_id = None

    def draw_rect(self, event):
        if self.rect_id:
            self.canvas.delete(self.rect_id)

        self.rect_id = self.canvas.create_rectangle(
            self.start_x, self.start_y, event.x, event.y,
            outline="red", width=2
        )

    def finish_draw(self, event):
        x1, y1 = self.start_x, self.start_y
        x2, y2 = event.x, event.y

        x1, x2 = sorted([x1, x2])
        y1, y2 = sorted([y1, y2])

        # 클래스 입력받기
        cls = tk.simpledialog.askstring("클래스 입력", "클래스 입력 (0=강의, 1=시간):")
        if cls not in ["0", "1"]:
            print("❌ 잘못된 클래스. 박스 무시됨.")
            self.canvas.delete(self.rect_id)
            return

        # 저장
        self.bboxes.append((int(cls), x1, y1, x2, y2))
        print(f"박스 저장됨: {cls}, {x1,y1,x2,y2}")

    def save_yolo(self):
        if not self.image_path:
            print("❌ 이미지 없음")
            return
        if not self.bboxes:
            print("❌ 박스 없음")
            return

        w, h = self.img.size

        txt_name = os.path.basename(self.image_path).replace(".jpg", ".txt").replace(".png", ".txt")
        save_path = os.path.join(SAVE_DIR, txt_name)

        with open(save_path, "w") as f:
            for cls, x1, y1, x2, y2 in self.bboxes:
                xc = (x1 + x2) / 2 / w
                yc = (y1 + y2) / 2 / h
                bw = (x2 - x1) / w
                bh = (y2 - y1) / h
                f.write(f"{cls} {xc:.6f} {yc:.6f} {bw:.6f} {bh:.6f}\n")

        print(f"✅ YOLO 저장 완료: {save_path}")


if __name__ == "__main__":
    root = tk.Tk()
    app = LabelTool(root)
    root.mainloop()
