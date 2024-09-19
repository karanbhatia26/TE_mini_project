from FastSAM.fastsam import FastSAM, FastSAMPrompt
# import supervision as sv
import os
import torch
import cv2 as cv
model = FastSAM('./FastSAM/weights/FastSAM.pt')

folder = './images/'
# Images = ['dogs.jpg','cat.jpg','person.jpg']
DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'

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


def Fast_SAM(Images):
    for idx, img_name in enumerate(Images):
        path = os.path.join(folder, img_name)
        # img = cv.imread(path)
        # cv.imshow('Image', img)
        # cv.waitKey(0)
        # cv.destroyAllWindows()
        print(f"Processing image: {path}")

        everything_results = model(path, device=DEVICE, retina_masks=True, imgsz=1024, conf=0.2, iou=0.5)
        prompt_process = FastSAMPrompt(path, everything_results, device=DEVICE)
        ann = prompt_process.point_prompt(points=[[620, 360]], pointlabel=[1])


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


Images = load_image_paths_from_folder(folder)
Fast_SAM(Images)
