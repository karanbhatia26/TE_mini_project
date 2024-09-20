from fastsam import FastSAM, FastSAMPrompt
# import supervision as sv
import os
import torch
import cv2 as cv
model = FastSAM('./weights/FastSAM-x.pt')

folder = './images'
DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
print(DEVICE)

import os

def load_image_paths_from_folder(folder_path):
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.tiff')  # Add more formats if needed
    images = []

    # Iterate through all files in the directory
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(image_extensions):  # Check if the file is an image
            image_path = os.path.join(folder_path, filename)
            images.append(image_path)  # Append the image file path to the list

    return images


def Fast_SAM(Images,prompt_points):
    for idx, img_name in enumerate(Images):
        path = os.path.join(img_name)
        print(f"Processing image: {path}")

        everything_results = model(path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.2, iou=0.5)
        prompt_process = FastSAMPrompt(path, everything_results, device=DEVICE)
        # ann = prompt_process.point_prompt(points=[[230, 220]], pointlabel=[1])
        ann = prompt_process.point_prompt(points=prompt_points, pointlabel=[1])


        print(f"Number of masks generated: {len(ann)}")

        output_filename = f'output_{idx}.jpg'
        output_path = os.path.join('./output/', output_filename)
        print(f"Saving annotated image to: {output_path}")

        try:
            prompt_process.plot(annotations=ann, output_path=output_path)
        except Exception as e:
            print(f"Error occurred while saving annotated image: {e}")
# everything_results = model(image_path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.4, iou=0.9,)
# prompt_process = FastSAMPrompt(image_path, everything_results, device=DEVICE)
# ann = prompt_process.text_prompt(text='Penguin')
# prompt_process.plot(annotations=ann, output='./output/')



def Preprocessing_with_FastSAM(input_video,input_path,output_path,frame_rate,points,video_name):
    
    command_01 = f'ffmpeg -i "{input_path}/{input_video}.mp4" -vf fps={frame_rate} "{input_path}/output_images_%04d.jpg"'
    os.system(command_01)

    Images = load_image_paths_from_folder(input_path)
    Fast_SAM(Images, points)

    command_02 = f'ffmpeg -framerate {frame_rate} -i "{output_path}/output_%d.jpg" -c:v libx264 -pix_fmt yuv420p "{output_path}/{video_name}.mp4"'
    os.system(command_02)
    
input_video = 'input_video'
input_path = r'C:\Users\Samarth Nilkanth\TE_mini_project\FastSAM\images'
output_path = r'C:\Users\Samarth Nilkanth\TE_mini_project\FastSAM\output'


Preprocessing_with_FastSAM(input_video=input_video,input_path=input_path,output_path=output_path,frame_rate=2,points=[[230, 220]],video_name='Stiched_video')

