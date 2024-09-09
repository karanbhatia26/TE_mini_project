import cv2
import torch
import torchvision.transforms as T
from PIL import Image
# Assuming SegViT model class is available as SegViT
# from your import path

# Load SegViT model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# Initialize your SegViT model (assuming there's a constructor or method)
# Replace 'SegViT' with the actual class name for your model
segvit_model = SegViT(pretrained=True).to(device)
segvit_model.eval()

# Transform for input images
transform = T.Compose([
    T.Resize((512, 512)),
    T.ToTensor(),
])

# Open video file or capture device
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

    # Convert frame to PIL image and apply transformation
    pil_frame = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    input_tensor = transform(pil_frame).unsqueeze(0).to(device)

    # Perform segmentation
    with torch.no_grad():
        output = segvit_model(input_tensor)
    
    # Convert model output to binary mask or segmented frame
    # Assume 'output' contains segmentation masks and process accordingly
    # Replace 'output_processing_function' with the actual function to convert
    # the model output to a mask image
    segmented_frame = output_processing_function(output)

    # Convert segmented frame back to BGR format for saving
    segmented_frame = cv2.cvtColor(segmented_frame, cv2.COLOR_RGB2BGR)

    # Write the segmented frame to the output video
    out.write(segmented_frame)

    # Display the resulting frame (optional)
    cv2.imshow('Segmented Frame', segmented_frame)

    # Break the loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release video objects
cap.release()
out.release()
cv2.destroyAllWindows()
