from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2 as cv
import numpy as np
import os
import tempfile
from werkzeug.utils import secure_filename
from final import prof, process_single_frame, detect_human_coordinates
from flow_final import compare_exercise_sequences
import time
import logging
import traceback

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Add model initialization at startup rather than on first request
prof_masks_cache = None

# Initialize masks before handling requests
@app.before_request
def initialize_models():
    global prof_masks_cache
    logger.info("Pre-loading professor exercise masks...")
    initialize_prof_masks('C:/Users/Karan/TE_mini_project/FastSAM/images/input_video.mp4')

def initialize_prof_masks(video_path):
    global prof_masks_cache
    if prof_masks_cache is None:
        temp_dir = tempfile.mkdtemp()
        try:
            prof_masks_cache = prof(video_path, temp_dir)
            print(f"Professor masks initialized. Total frames: {len(prof_masks_cache)}")
        finally:
            if os.path.exists(temp_dir):
                for f in os.listdir(temp_dir):
                    os.remove(os.path.join(temp_dir, f))
                os.rmdir(temp_dir)

def process_student_video(video_file):
    temp_path = tempfile.mktemp(suffix='.webm')
    video_file.save(temp_path)
    
    cap = cv.VideoCapture(temp_path)
    if not cap.isOpened():
        logger.error(f"Failed to open video file: {temp_path}")
        raise ValueError("Could not open video file. Unsupported format or corrupted file.")
        
    student_masks = []
    
    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                break
                
            human_coords = detect_human_coordinates(frame)
            if human_coords:
                mask = process_single_frame(frame, [human_coords[0]])
                student_masks.append(mask)
            else:
                mask = np.zeros((frame.shape[0], frame.shape[1]), dtype=bool)
                student_masks.append(mask)
    finally:
        cap.release()
        os.remove(temp_path)
    
    return student_masks

@app.route('/process-exercise', methods=['POST'])
def process_exercise():
    try:
        logger.debug("Received exercise processing request")
        
        if 'video' not in request.files:
            logger.error("No video file in request")
            return jsonify({'error': 'No video file provided'}), 400
        
        video_file = request.files['video']
        logger.debug(f"Received video: {video_file.filename}, {video_file.content_type}")
        
        # Process the video
        student_masks = process_student_video(video_file)
        logger.debug(f"Generated {len(student_masks)} student masks")
        
        # Initialize professor masks if needed
        if prof_masks_cache is None:
            logger.debug("Initializing professor masks")
            initialize_prof_masks('C:/Users/Karan/TE_mini_project/FastSAM/images/input_video.mp4')
        
        if not student_masks or not prof_masks_cache:
            logger.error("Failed to generate masks")
            return jsonify({'error': 'Failed to process video'}), 500
            
        # Compare sequences
        results = compare_exercise_sequences(prof_masks_cache, student_masks)
        
        response_data = {
            'average_similarity': float(results.get('average_spatial_similarity', 0.0)),
            'max_delay': int(results.get('max_delay', 0)),
            'ideal_calories': float(results.get('ideal_calories', 0.0)),
            'actual_calories': float(results.get('actual_calories', 0.0)),
            'flow_similarity': float(results.get('average_flow_similarity', 0.0))
        }
        
        logger.debug(f"Sending response: {response_data}")
        return jsonify(response_data)
        
    except Exception as e:
        logger.error(f"Server error: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)