import os
from FastSAM.fastsam import FastSam

# Load FastSam model
model = FastSam.load_model('/FastSAM/FastSAM-s.pt')

# Directory of extracted frames
frames_dir = '/input'
output_dir = '/output'

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Process each frame
for frame_file in sorted(os.listdir(frames_dir)):
    frame_path = os.path.join(frames_dir, frame_file)
    image = FastSam.load_image(frame_path)
    
    # Apply FastSam to segment the dog
    segmented_image = model.segment(image, target='dog')  # Assuming there's a target option for 'dog'
    
    # Save the segmented image
    output_path = os.path.join(output_dir, frame_file)
    FastSam.save_image(segmented_image, output_path)
