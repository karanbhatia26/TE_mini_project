import cv2 as cv
import numpy as np
from final import prof, process_camera_feed
def compare_exercise_sequences(prof_masks, student_masks):
    def extract_pose_features(mask):
        # Convert boolean mask to uint8
        mask_uint8 = mask.astype(np.uint8)
        
        # Calculate moments
        moments = cv.moments(mask_uint8)
        
        # Get centroid
        if moments['m00'] != 0:
            cx = moments['m10'] / moments['m00']
            cy = moments['m01'] / moments['m00']
        else:
            cx, cy = 0, 0
            
        # Get contour features
        contours, _ = cv.findContours(mask_uint8, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
        if contours:
            main_contour = max(contours, key=cv.contourArea)
            area = cv.contourArea(main_contour)
            # Get bounding box height (useful for exercises like pullups)
            _, _, _, height = cv.boundingRect(main_contour)
        else:
            area, height = 0, 0
            
        return np.array([cx, cy, area, height])

    # Extract features from both sequences
    prof_features = np.array([extract_pose_features(mask) for mask in prof_masks])
    student_features = np.array([extract_pose_features(mask) for mask in student_masks])
    
    # Calculate DTW
    from scipy.spatial.distance import euclidean
    from fastdtw import fastdtw
    
    distance, path = fastdtw(prof_features, student_features, dist=euclidean)
    
    # Extract aligned indices
    prof_indices, student_indices = zip(*path)
    
    # Calculate frame-by-frame similarity
    similarities = []
    timing_diff = []
    
    for prof_idx, student_idx in zip(prof_indices, student_indices):
        # Calculate IoU between aligned frames
        intersection = np.logical_and(prof_masks[prof_idx], student_masks[student_idx]).sum()
        union = np.logical_or(prof_masks[prof_idx], student_masks[student_idx]).sum()
        
        similarity = intersection / union if union > 0 else 0
        similarities.append(similarity)
        
        # Track timing differences
        timing_diff.append(student_idx - prof_idx)
    
    return {
        'similarities': similarities,
        'timing_differences': timing_diff,
        'average_similarity': np.mean(similarities),
        'max_delay': max(timing_diff),
        'prof_indices': prof_indices,
        'student_indices': student_indices
    }

# # Example usage with your existing code:
# def analyze_exercise():
#     # Get professional video masks
#     input_video_path = "path_to_prof_video.mp4"
#     temp_frame_folder = "temp_frames"
#     prof_masks = prof(input_video_path, temp_frame_folder)
    
#     # Get student camera feed masks
#     student_masks = process_camera_feed()
    
#     # Compare sequences
#     results = compare_exercise_sequences(prof_masks, student_masks)
    
#     # Print analysis
#     print(f"Average Similarity: {results['average_similarity']:.2f}")
#     print(f"Maximum Delay: {results['max_delay']} frames")
    
#     # You can use these indices to show aligned frames to the user
#     print("Aligned frame pairs:", list(zip(results['prof_indices'], results['student_indices'])))
    
# results = compare_exercise_sequences(prof_masks, student_masks)

# # Performance Feedback
# if results['average_similarity'] < 0.7:  # Less than 70% match
#     print("Try to match the trainer's form more closely")
    
# if results['max_delay'] > 10:  # More than 10 frames behind
#     print("You're falling behind, try to keep up with the pace")

# # Real-time Guidance
# for i in range(len(results['similarities'])):
#     current_similarity = results['similarities'][i]
#     if current_similarity < 0.6:
#         print("Adjust your form!")

def compare_exercise_sequences_with_flow(prof_masks, student_masks):
    """
    Enhanced comparison using both DTW and optical flow
    """
    import cv2

    def calculate_flow(mask1, mask2):
        # Convert boolean masks to uint8
        prev_frame = (mask1 * 255).astype(np.uint8)
        next_frame = (mask2 * 255).astype(np.uint8)
        
        # Calculate optical flow
        flow = cv2.calcOpticalFlowFarneback(
            prev_frame, 
            next_frame,
            None,
            0.5,  # Pyramid scale
            3,    # Pyramid levels
            15,   # Window size
            3,    # Iterations
            5,    # Poly neighbor size
            1.2,  # Poly sigma
            0     # Flags
        )
        
        # Calculate flow magnitude and direction
        magnitude, angle = cv2.cartToPolar(flow[..., 0], flow[..., 1])
        
        return magnitude, angle

    # Get DTW alignment first
    dtw_results = compare_exercise_sequences(prof_masks, student_masks)
    
    # Add flow analysis
    flow_diff = []
    movement_speed = []
    
    # Analyze aligned frames
    for prof_idx, student_idx in zip(dtw_results['prof_indices'], dtw_results['student_indices']):
        # Calculate flow for both sequences
        prof_mag, prof_ang = calculate_flow(
            prof_masks[prof_idx], 
            prof_masks[min(prof_idx + 1, len(prof_masks) - 1)]
        )
        
        student_mag, student_ang = calculate_flow(
            student_masks[student_idx],
            student_masks[min(student_idx + 1, len(student_masks) - 1)]
        )
        
        # Compare movement patterns
        flow_difference = np.mean(np.abs(prof_mag - student_mag))
        flow_diff.append(flow_difference)
        
        # Track movement speed
        movement_speed.append(np.mean(student_mag) / np.mean(prof_mag) if np.mean(prof_mag) > 0 else 1.0)

    return {
        **dtw_results,  # Include previous metrics
        'flow_differences': flow_diff,  # How different the movements are
        'movement_speeds': movement_speed,  # Relative speed (1.0 = same speed)
        'avg_flow_diff': np.mean(flow_diff),
        'avg_speed_ratio': np.mean(movement_speed)
    }

# Example usage for exercise feedback
def provide_exercise_feedback(results):
    feedback = []
    
    # Form accuracy feedback
    if results['average_similarity'] < 0.7:
        feedback.append("Your form needs improvement")
        
    # Timing feedback
    if results['max_delay'] > 10:
        feedback.append("Try to keep up with the trainer's pace")
        
    # Movement speed feedback
    if results['avg_speed_ratio'] < 0.8:
        feedback.append("Your movements are too slow")
    elif results['avg_speed_ratio'] > 1.2:
        feedback.append("Your movements are too fast")
        
    # Flow difference feedback
    if results['avg_flow_diff'] > 0.5:
        feedback.append("Your movement patterns don't match the trainer's")
        
    return feedback

# Real-time usage
input_video_path = 'C:/Users/Samarth Nilkanth/TE_mini_project/FastSAM/images/input_video.mp4'
temp_frame_folder = 'C:/Users/Samarth Nilkanth/TE_mini_project/FastSAM/temp_frames'
prof_masks = prof(input_video_path, temp_frame_folder)
student_masks = process_camera_feed(max_frames )

results = compare_exercise_sequences_with_flow(prof_masks, student_masks)
feedback = provide_exercise_feedback(results)

for msg in feedback:
    print(msg)