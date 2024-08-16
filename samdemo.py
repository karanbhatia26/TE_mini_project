import torch
import cv2
import numpy as np
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator

# Load SAM model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
sam = sam_model_registry["vit_h"](checkpoint="sam_vit_h_4b8939.pth").to(device)
mask_generator = SamAutomaticMaskGenerator(sam)

# Open video file
video_path = "input_video.mp4"  # Replace with your video path
cap = cv2.VideoCapture(video_path)

# Check if video opened successfully
if not cap.isOpened():
    print("Error: Could not open video.")
    exit()

# Prepare for video writing
output_path = "output_segmented_video.mp4"  # Output video file path
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
fps = int(cap.get(cv2.CAP_PROP_FPS))
frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
out = cv2.VideoWriter(output_path, fourcc, fps, (frame_width, frame_height))

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # Convert frame to RGB for SAM
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
    # Generate masks with SAM
    masks = mask_generator.generate(rgb_frame)
    
    # Assume largest mask is the human body (can be refined for better results)
    if masks:
        largest_mask = max(masks, key=lambda x: x['area'])
        
        # Create binary mask for the human body
        mask = largest_mask['segmentation'].astype(np.uint8)
        
        # Apply mask to frame
        body_segmented = cv2.bitwise_and(frame, frame, mask=mask)
        
        # Write the frame to the output video
        out.write(body_segmented)
    
    # Display the resulting frame (optional)
    cv2.imshow('Segmented Frame', body_segmented)
    
    # Break the loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release video objects
cap.release()
out.release()
cv2.destroyAllWindows()
