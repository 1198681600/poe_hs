import sys
import cv2
import numpy as np
import json
import argparse
from pathlib import Path


def find_image(screen_path, target_path, threshold=0.8):
    # 读取屏幕截图和目标图像
    screen = cv2.imread(screen_path)
    target = cv2.imread(target_path)

    if screen is None or target is None:
        return {"status": "error", "message": "无法读取图像文件"}

    # 执行模板匹配
    result = cv2.matchTemplate(screen, target, cv2.TM_CCOEFF_NORMED)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)

    # 检查匹配度是否达到阈值
    if max_val >= threshold:
        # 计算匹配区域的中心点
        h, w = target.shape[:2]
        center_x = max_loc[0] + w // 2
        center_y = max_loc[1] + h // 2

        return {
            "status": "success",
            "center_x": center_x,
            "center_y": center_y,
            "confidence": float(max_val),
            "top_left_x": max_loc[0],
            "top_left_y": max_loc[1],
            "width": w,
            "height": h
        }
    else:
        return {"status": "not_found", "confidence": float(max_val)}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Find target image on screen')
    parser.add_argument('screen', help='Path to screen screenshot')
    parser.add_argument('target', help='Path to target image')
    parser.add_argument('--threshold', type=float, default=0.8, help='Matching threshold (0.0-1.0)')

    args = parser.parse_args()

    result = find_image(args.screen, args.target, args.threshold)
    print(json.dumps(result))
