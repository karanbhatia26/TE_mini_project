import os
import torch
import cv2 as cv
from fastsam import FastSAM, FastSAMPrompt
import time
import numpy as np

DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
print(f"Using device: {DEVICE}")

# Load the FastSAM model once to avoid re-loading it for every frame
model = FastSAM('./weights/FastSAM-x.pt')

def process_single_frame(frame, prompt_points):
    """Process a single frame using FastSAM."""
    # Save the frame to a temporary file
    temp_image_path = 'temp_frame.jpg'
    cv.imwrite(temp_image_path, frame)
    
    # Process the frame
    everything_results = model(temp_image_path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.2, iou=0.5)
    prompt_process = FastSAMPrompt(temp_image_path, everything_results, device=DEVICE)
    ann = prompt_process.point_prompt(points=prompt_points, pointlabel=[1])
    
    # Get the annotated frame using plot_to_result
    output_frame = prompt_process.plot_to_result(annotations=ann)
    
    # Convert to an OpenCV-compatible image if necessary (assuming the output is a PIL image or similar)
    output_frame = np.array(output_frame)
    output_frame = cv.cvtColor(output_frame, cv.COLOR_RGB2BGR)
    
    return output_frame

def process_camera_feed():
    # Initialize the camera (0 is typically the default camera)
    cap = cv.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    # Frame rate control
    start_time = time.time()
    
    prompt_points = [[230, 220]]  # Example prompt points, will be replaced by midpoint

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Error: Could not read frame from camera.")
                break

            # Show the original frame
            cv.imshow('Original Video Feed', frame)

            # Get the frame's dimensions
            height, width, _ = frame.shape

            # Calculate the midpoint of the frame
            mid_x = width // 2
            mid_y = height // 2

            # Swap the midpoint with the original point
            prompt_points = [[mid_x, mid_y]]

            # Process the frame every second (1 second interval)
            if time.time() - start_time >= 1:
                start_time = time.time()

                # Process the frame using FastSAM with the new prompt points (midpoint)
                processed_frame = process_single_frame(frame, prompt_points)

                # Show the processed frame
                cv.imshow('Processed Video Feed', processed_frame)

            # Break the loop on 'q' key press
            if cv.waitKey(1) & 0xFF == ord('q'):
                print("Exit signal received (q pressed).")
                break

    except Exception as e:
        print(f"Error occurred during video processing: {e}")

    finally:
        # Ensure that the resources are released properly
        print("Releasing camera and closing windows.")
        cap.release()
        cv.destroyAllWindows()

if __name__ == '__main__':
    # Run camera feed processing
    process_camera_feed()
