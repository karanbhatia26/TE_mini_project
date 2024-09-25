import os
import torch
import cv2 as cv
from fastsam import FastSAM, FastSAMPrompt
from multiprocessing import Pool, cpu_count

DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
print(f"Using device: {DEVICE}")

def load_image_paths_from_folder(folder_path):
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.tiff')
    images = []
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(image_extensions):
            image_path = os.path.join(folder_path, filename)
            images.append(image_path)
    return images

def process_single_image(args):
    img_path, prompt_points, output_path, idx = args
    model = FastSAM('./weights/FastSAM-x.pt')
    
    print(f"Processing image: {img_path}")
    
    everything_results = model(img_path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.2, iou=0.5)
    prompt_process = FastSAMPrompt(img_path, everything_results, device=DEVICE)
    ann = prompt_process.point_prompt(points=prompt_points, pointlabel=[1])
    
    print(f"Number of masks generated: {len(ann)}")
    
    output_filename = f'output_{idx}.jpg'
    output_file_path = os.path.join(output_path, output_filename)
    print(f"Saving annotated image to: {output_file_path}")
    
    try:
        prompt_process.plot(annotations=ann, output_path=output_file_path)
    except Exception as e:
        print(f"Error occurred while saving annotated image: {e}")

def Fast_SAM_Parallel(Images, prompt_points, output_path):
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    
    # Prepare arguments for each image
    args_list = [(img_path, prompt_points, output_path, idx) for idx, img_path in enumerate(Images)]
    
    # Use multiprocessing to process images in parallel
    with Pool(processes=min(cpu_count(), 4)) as pool:  # Adjust the number of processes as needed
        pool.map(process_single_image, args_list)

def Preprocessing_with_FastSAM(input_video, input_path, output_path, frame_rate, points, video_name):
    command_01 = f'ffmpeg -i "{input_path}/{input_video}.mp4" -vf fps={frame_rate} "{input_path}/output_images_%04d.jpg"'
    os.system(command_01)
    
    Images = load_image_paths_from_folder(input_path)
    Fast_SAM_Parallel(Images, points, output_path)
    
    command_02 = f'ffmpeg -framerate {frame_rate} -i "{output_path}/output_%d.jpg" -c:v libx264 -pix_fmt yuv420p "{output_path}/{video_name}.mp4"'
    os.system(command_02)

if __name__ == '__main__':
# Example usage
    input_video = 'input_video'
    input_path = r'C:\Users\Samarth Nilkanth\TE_mini_project\FastSAM\images'
    output_path = r'C:\Users\Samarth Nilkanth\TE_mini_project\FastSAM\output'

    Preprocessing_with_FastSAM(
        input_video=input_video,
        input_path=input_path,
        output_path=output_path,
        frame_rate=4,
        points=[[230, 220]],
        video_name='Stitched_video'
    )