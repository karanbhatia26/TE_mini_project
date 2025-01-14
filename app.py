from flask import Flask, request, jsonify
import cv2 as cv
import numpy as np
import os
from werkzeug.utils import secure_filename
from  final import prof, process_camera_feed
from  flow_final import compare_exercise_sequences

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'mp4', 'avi', 'mov'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/process-exercise', methods=['POST'])
def process_exercise():
    if 'video' not in request.files:
        return jsonify({'error': 'No video file provided'}), 400
    
    file = request.files['video']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        try:
            temp_folder = os.path.join(app.config['UPLOAD_FOLDER'], 'temp_frames')
            os.makedirs(temp_folder, exist_ok=True)
            
            prof_masks = prof(filepath, temp_folder)
            student_masks = process_camera_feed(len(prof_masks))
            
            results = compare_exercise_sequences(prof_masks, student_masks)
            
            os.remove(filepath)
            for temp_file in os.listdir(temp_folder):
                os.remove(os.path.join(temp_folder, temp_file))
            os.rmdir(temp_folder)
            
            return jsonify(results)
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return jsonify({'error': 'Invalid file type'}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)