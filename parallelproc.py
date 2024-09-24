from concurrent.futures import ProcessPoolExecutor
from fastsam import FastSAM, FastSAMPrompt
import os
import torch

# Load model
model = FastSAM('./weights/FastSAM-x.pt')
DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'

def load_image_paths_from_folder(folder_path):
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.tiff')  # Add more formats if needed
    images = []

    for filename in os.listdir(folder_path):
        if filename.lower().endswith(image_extensions):
            image_path = os.path.join(folder_path, filename)
            images.append(image_path)

    return images

def process_image(image_path, prompt_points):
    try:
        print(f"Processing image: {image_path}")

        everything_results = model(image_path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.2, iou=0.5)
        prompt_process = FastSAMPrompt(image_path, everything_results, device=DEVICE)
        ann = prompt_process.point_prompt(points=prompt_points, pointlabel=[1])

        output_filename = f'output_{os.path.basename(image_path)}'
        output_path = os.path.join('./output/', output_filename)

        print(f"Saving annotated image to: {output_path}")
        prompt_process.plot(annotations=ann, output_path=output_path)

    except Exception as e:
        print(f"Error processing {image_path}: {e}")

def Fast_SAM_parallel(Images, points):
    with ProcessPoolExecutor() as executor:
        executor.map(lambda img: process_image(img, points), Images)

def Preprocessing_with_FastSAM(input_video, input_path, output_path, frame_rate, points, video_name):

    command_01 = f'ffmpeg -i "{input_path}/{input_video}.mp4" -vf fps={frame_rate} "{input_path}/output_images_%04d.jpg"'
    os.system(command_01)

    Images = load_image_paths_from_folder(input_path)
    
    Fast_SAM_parallel(Images, points)

    command_02 = f'ffmpeg -framerate {frame_rate} -i "{output_path}/output_%d.jpg" -c:v libx264 -pix_fmt yuv420p "{output_path}/{video_name}.mp4"'
    os.system(command_02)

input_video = 'input_video'
input_path = r'C:\Users\Samarth Nilkanth\TE_mini_project\FastSAM\images'
output_path = r'C:\Users\Samarth Nilkanth\TE_mini_project\FastSAM\output'

Preprocessing_with_FastSAM(input_video=input_video, input_path=input_path, output_path=output_path, frame_rate=4, points=[[230, 220]], video_name='Stitched_video')
