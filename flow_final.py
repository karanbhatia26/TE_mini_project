import cv2 as cv
import numpy as np
from final import prof, process_camera_feed

def resize_mask(mask, target_size):
    """Resize mask to target size while preserving binary nature"""
    print(f"Resizing mask from {mask.shape} to {target_size}")
    
    # Handle single-channel masks with extra dimension
    if len(mask.shape) == 3 and mask.shape[0] == 1:
        mask = np.squeeze(mask, axis=0)
    
    # Convert to uint8 if needed
    if mask.dtype != np.uint8:
        mask = (mask > 0).astype(np.uint8) * 255
    
    # Resize
    resized = cv.resize(mask, (target_size[1], target_size[0]), interpolation=cv.INTER_NEAREST)
    
    # Ensure binary
    _, resized = cv.threshold(resized, 127, 255, cv.THRESH_BINARY)
    
    print(f"Resized mask shape: {resized.shape}")
    return resized

def extract_pose_features(mask):
    print(f"Processing mask shape: {mask.shape}, dtype: {mask.dtype}")
    
    # Calculate moments
    moments = cv.moments(mask)
    
    # Get centroid
    if moments['m00'] != 0:
        cx = moments['m10'] / moments['m00']
        cy = moments['m01'] / moments['m00']
    else:
        cx, cy = 0, 0
    
    # Get contour features
    contours, _ = cv.findContours(mask, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
    if contours:
        main_contour = max(contours, key=cv.contourArea)
        area = cv.contourArea(main_contour)
        _, _, _, height = cv.boundingRect(main_contour)
    else:
        area, height = 0, 0
    
    return np.array([cx, cy, area, height])

def compare_exercise_sequences(prof_masks, student_masks):
    print("\nStarting exercise comparison...")
    print(f"Professor masks shape: {prof_masks[0].shape}")
    print(f"Student masks shape: {student_masks[0].shape}")
    
    # Define target size (you can adjust this)
    target_size = (480, 480)  # height, width
    
    # Preprocess and resize masks
    def preprocess_masks(masks, name):
        processed = []
        for i, mask in enumerate(masks):
            print(f"\nPreprocessing {name} mask {i}")
            processed_mask = resize_mask(mask, target_size)
            processed.append(processed_mask)
        return processed
    
    print("\nPreprocessing masks...")
    prof_masks_processed = preprocess_masks(prof_masks, "professor")
    student_masks_processed = preprocess_masks(student_masks, "student")
    
    # Extract features
    print("\nExtracting features...")
    prof_features = np.array([extract_pose_features(mask) for mask in prof_masks_processed])
    student_features = np.array([extract_pose_features(mask) for mask in student_masks_processed])
    
    # Calculate DTW
    print("\nCalculating DTW...")
    from scipy.spatial.distance import euclidean
    from fastdtw import fastdtw
    
    distance, path = fastdtw(prof_features, student_features, dist=euclidean)
    print(f"DTW distance: {distance}")
    
    # Extract aligned indices
    prof_indices, student_indices = zip(*path)
    
    # Calculate frame-by-frame similarity
    print("\nCalculating similarities...")
    similarities = []
    timing_diff = []
    
    for prof_idx, student_idx in zip(prof_indices, student_indices):
        intersection = np.logical_and(
            prof_masks_processed[prof_idx] > 0,
            student_masks_processed[student_idx] > 0
        ).sum()
        union = np.logical_or(
            prof_masks_processed[prof_idx] > 0,
            student_masks_processed[student_idx] > 0
        ).sum()
        
        similarity = intersection / union if union > 0 else 0
        similarities.append(similarity)
        timing_diff.append(student_idx - prof_idx)
    
    results = {
        'similarities': similarities,
        'timing_differences': timing_diff,
        'average_similarity': np.mean(similarities),
        'max_delay': max(timing_diff),
        'prof_indices': prof_indices,
        'student_indices': student_indices
    }
    
    print("\nResults:")
    print(f"Average similarity: {results['average_similarity']:.2f}")
    print(f"Maximum delay: {results['max_delay']} frames")
    
    return results

# Example usage
if __name__ == "__main__":
    print("Starting main execution...")
    
    input_video_path = 'C:/Users/Karan/TE_mini_project/FastSAM/images/input_video.mp4'
    temp_frame_folder = 'C:/Users/Karan/TE_mini_project/FastSAM/temp_framestemp_frames'
    
    print("\nGetting professor masks...")
    prof_masks = prof(input_video_path, temp_frame_folder)
    
    print("\nGetting student masks...")
    student_masks = process_camera_feed(len(prof_masks))
    
    results = compare_exercise_sequences(prof_masks, student_masks)
    
    # Provide feedback
    print("\nProviding feedback...")
    if results['average_similarity'] < 0.7:
        print("Try to match the trainer's form more closely")
    
    if results['max_delay'] > 10:
        print("You're falling behind, try to keep up with the pace")
    
    for i, similarity in enumerate(results['similarities']):
        if similarity < 0.6:
            print(f"Frame {i}: Adjust your form!")