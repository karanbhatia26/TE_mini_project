import os
import torch
import cv2 as cv
import time
import numpy as np
from ultralytics import YOLO  # YOLOv8 for human detection
from fastsam import FastSAM, FastSAMPrompt
import numpy as np

# Device Configuration
DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
print(f"Using device: {DEVICE}")

# Load Models
yolo_model = YOLO('yolov8n.pt')  # YOLOv8 for human detection
fastsam_model = FastSAM('./weights/FastSAM-x.pt')  # FastSAM for segmentation

def detect_human_coordinates(frame):
    """Detect human midpoints using YOLOv8 and return as list of points."""
    results = yolo_model(frame, verbose=False)  # YOLO inference
    human_coords = []

    for result in results:
        boxes = result.boxes.xyxy.cpu().numpy()  # Bounding box coordinates
        classes = result.boxes.cls.cpu().numpy()  # Class IDs

        for box, cls in zip(boxes, classes):
            if int(cls) == 0:  # Class 0 corresponds to 'person'
                x1, y1, x2, y2 = box
                mid_x = int((x1 + x2) / 2)
                mid_y = int((y1 + y2) / 2)
                human_coords.append([mid_x, mid_y])  # Append midpoint

    return human_coords

def process_single_frame(frame, prompt_points):
    """Process a single frame using FastSAM with prompt points."""
    # try:
    temp_image_path = 'temp_frame.jpg'
    cv.imwrite(temp_image_path, frame)
    # Perform FastSAM segmentation
    everything_results = fastsam_model(temp_image_path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.2, iou=0.5)
    prompt_process = FastSAMPrompt(temp_image_path, everything_results, device=DEVICE)
    # Use prompt points for segmentation
    ann = prompt_process.point_prompt(points=prompt_points, pointlabel=[1])
    return ann
        # # Convert the output to displayable format
        # output_frame = prompt_process.plot_to_result(annotations=ann)
        # output_frame = np.array(output_frame)
        # output_frame = cv.cvtColor(output_frame, cv.COLOR_RGB2BGR)

    #     return output_frame
    # except Exception as e:
    #     print(f"Error processing frame: {e}")
    #     return None

def un_stitch_video(input_video_path, temp_frame_folder, fps=3):
    """Un-stitch the video into frames at a given fps using FFmpeg."""
    os.makedirs(temp_frame_folder, exist_ok=True)
    os.system(f"ffmpeg -i {input_video_path} -vf fps={fps} {temp_frame_folder}/frame_%04d.jpg")

# def stitch_video(output_video_path, temp_frame_folder, frame_rate=3):
#     """Stitch individual frames back into a video using FFmpeg."""
#     os.system(f"ffmpeg -framerate {frame_rate} -i {temp_frame_folder}/frame_%04d.jpg -c:v libx264 -pix_fmt yuv420p {output_video_path}")

def prof(input_video_path, temp_frame_folder, fps=3):
    """Process the video, detect humans, and segment them."""
    un_stitch_video(input_video_path, temp_frame_folder, fps=fps)
    ann_final = []
    # Get the list of frames in the folder
    frame_files = [f for f in os.listdir(temp_frame_folder) if f.endswith('.jpg')]
    frame_files.sort()  # Ensure frames are sorted in the correct order

    for idx, frame_file in enumerate(frame_files):
        frame_path = os.path.join(temp_frame_folder, frame_file)
        frame = cv.imread(frame_path)

        # Detect human coordinates using YOLO
        human_coords = detect_human_coordinates(frame)

        if len(human_coords) > 0:
            print(f"Detected Human Coordinates: {human_coords}")
            # Process the frame with the first human's coordinates (you can modify this to handle more humans if needed)
            frame_ann = process_single_frame(frame, prompt_points=[human_coords[0]])  
            ann_final.append(frame_ann)
        else:
            print("No human detected.")
            # frame_ann = frame  # Keep original frame if no human detected
            frame_ann = np.zeros((frame.shape[0], frame.shape[1]), dtype=bool)
            ann_final.append(frame_ann)
        return ann_final
    
        # # Save the processed frame back to disk
        # output_frame_path = os.path.join(temp_frame_folder, f"processed_frame_{idx:04d}.jpg")
        # cv.imwrite(output_frame_path, processed_frame)

    # Stitch the processed frames into a final video
    # stitch_video(output_video_path, temp_frame_folder, frame_rate=fps)

# if __name__ == '__main__':
#     input_video_path = r"FastSAM/images/input_video.mp4"
#     output_video_path = r"FastSAM/output_video.mp4"
#     temp_frame_folder = r"FastSAM/temp_frames"

#     process_video(input_video_path, output_video_path, temp_frame_folder, fps=3)
#     print(f"Processed video saved to {output_video_path}")


def process_camera_feed():
    """Capture live camera feed, detect humans, and process segmentation."""
    cap = cv.VideoCapture(0)  # Open camera
    if not cap.isOpened():
        print("Error: Could not open camera.")
        return
    ann_final = []
    
    while True:
        # Capture frame-by-frame
        ret, frame = cap.read()
        if not ret:
            print("Error: Could not read frame from camera.")
            break
        # Detect human midpoints using YOLOv8
        human_coords = detect_human_coordinates(frame)
        if len(human_coords) > 0:
            print(f"Detected Human Coordinates: {human_coords}")
            ann_final.append(process_single_frame(frame, prompt_points=[human_coords[0]]))  # Use first human's coords
        else:
            print("No human detected.")
            frame_ann = np.zeros((frame.shape[0], frame.shape[1]), dtype=bool)
            ann_final.append(frame_ann)
        print("")
    return ann_final
