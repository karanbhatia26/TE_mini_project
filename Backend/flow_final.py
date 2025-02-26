import cv2 as cv
import numpy as np
from fastdtw import fastdtw
from scipy.spatial.distance import euclidean

def resize_mask(mask, target_size):
    """Resize mask to target size while preserving boolean type"""
    # Ensure mask is 2D before resizing
    if len(mask.shape) > 2:
        mask = mask[:,:,0]  # Take first channel if multi-channel
    
    resized = cv.resize(mask.astype(np.uint8), target_size, interpolation=cv.INTER_NEAREST)
    return resized.astype(bool)

def extract_pose_features(mask):
    """Extract pose features from mask"""
    # Check mask type and shape
    if not isinstance(mask, np.ndarray):
        print(f"Error: mask is not a numpy array, it's a {type(mask)}")
        return np.zeros(5)
        
    # Ensure mask is a single-channel binary image
    if len(mask.shape) > 2:
        print(f"Converting multi-channel mask with shape {mask.shape} to single channel")
        mask = mask[:,:,0]  # Take first channel
    
    # Convert to uint8 (ensure binary)
    mask_uint8 = mask.astype(np.uint8) * 255
    
    # Find contours
    try:
        contours, _ = cv.findContours(mask_uint8, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
    except Exception as e:
        print(f"Error finding contours: {e}")
        print(f"Mask shape: {mask.shape}, dtype: {mask.dtype}, unique values: {np.unique(mask)}")
        return np.zeros(5)
    
    if not contours:
        return np.zeros(5)  # Return zero features if no contours found
        
    # Get the largest contour
    largest_contour = max(contours, key=cv.contourArea)
    
    # Calculate features
    moments = cv.moments(largest_contour)
    if moments['m00'] == 0:
        return np.zeros(5)
        
    # Centroid
    cx = moments['m10'] / moments['m00']
    cy = moments['m01'] / moments['m00']
    
    # Area and perimeter
    area = cv.contourArea(largest_contour)
    perimeter = cv.arcLength(largest_contour, True)
    
    # Aspect ratio of bounding rect
    x, y, w, h = cv.boundingRect(largest_contour)
    aspect_ratio = float(w)/h if h != 0 else 0
    
    return np.array([cx, cy, area, perimeter, aspect_ratio])

def calculate_flow(mask1, mask2):
    """Calculate optical flow between two consecutive masks"""
    # Ensure masks are 2D
    if len(mask1.shape) > 2:
        mask1 = mask1[:,:,0]
    if len(mask2.shape) > 2:
        mask2 = mask2[:,:,0]
    
    # Ensure same size
    if mask1.shape != mask2.shape:
        mask2 = cv.resize(mask2.astype(np.uint8), (mask1.shape[1], mask1.shape[0]), interpolation=cv.INTER_NEAREST)
    
    # Convert to proper format for optical flow
    prev_frame = mask1.astype(np.uint8) * 255
    next_frame = mask2.astype(np.uint8) * 255
    
    # Calculate optical flow
    try:
        flow = cv.calcOpticalFlowFarneback(
            prev_frame, next_frame,
            None, 0.5, 3, 15, 3, 5, 1.2, 0
        )
        magnitude, angle = cv.cartToPolar(flow[..., 0], flow[..., 1])
        return magnitude, angle
    except Exception as e:
        print(f"Error calculating optical flow: {e}")
        print(f"prev_frame shape: {prev_frame.shape}, dtype: {prev_frame.dtype}")
        print(f"next_frame shape: {next_frame.shape}, dtype: {next_frame.dtype}")
        # Return empty arrays of appropriate shape
        h, w = prev_frame.shape
        return np.zeros((h, w)), np.zeros((h, w))

def intersectionOverUnion(mask1, mask2):
    """Calculate IoU between two masks"""
    # Ensure masks are 2D boolean
    if len(mask1.shape) > 2:
        mask1 = mask1[:,:,0] > 0
    if len(mask2.shape) > 2:
        mask2 = mask2[:,:,0] > 0
        
    intersection = np.logical_and(mask1, mask2).sum()
    union = np.logical_or(mask1, mask2).sum()
    return intersection / union if union > 0 else 0

def calculate_calories(flow_metrics, duration_seconds, weight_kg=70):
    """Calculate calories burned based on movement intensity and duration."""
    # Default weight of 70kg if not provided
    
    # Base metabolic rate (calories per minute)
    bmr = 1.2  # Resting metabolic rate
    
    # Adjust based on movement intensity (mean flow magnitude)
    avg_magnitude = sum(flow['mean_magnitude'] for flow in flow_metrics) / len(flow_metrics) if flow_metrics else 0
    
    # Scale factor to convert optical flow to exercise intensity
    intensity_factor = min(5.0, 1.0 + avg_magnitude * 8)  
    
    # Calculate calories
    calories_per_minute = bmr * intensity_factor
    minutes = duration_seconds / 60
    
    return calories_per_minute * minutes

def compare_exercise_sequences(prof_masks, student_masks):
    """Compare exercise sequences using both mask similarity and optical flow"""
    print(f"Comparing sequences: {len(prof_masks)} professor masks, {len(student_masks)} student masks")
    
    if not prof_masks or not student_masks:
        print("Warning: Empty mask sequences")
        return {'average_spatial_similarity': 0.0, 'max_delay': 0}
        
    # Ensure masks are properly sized and formatted
    target_size = (480, 480)
    
    # Process professor masks
    processed_prof_masks = []
    for mask in prof_masks:
        try:
            processed = resize_mask(mask, target_size)
            processed_prof_masks.append(processed)
        except Exception as e:
            print(f"Error processing professor mask: {e}")
            # Add empty mask if processing fails
            processed_prof_masks.append(np.zeros(target_size, dtype=bool))
    
    # Process student masks
    processed_student_masks = []
    for mask in student_masks:
        try:
            processed = resize_mask(mask, target_size)
            processed_student_masks.append(processed)
        except Exception as e:
            print(f"Error processing student mask: {e}")
            processed_student_masks.append(np.zeros(target_size, dtype=bool))
    
    # Use processed masks
    prof_masks = processed_prof_masks
    student_masks = processed_student_masks
    
    # Extract features from each frame
    prof_features = [extract_pose_features(mask) for mask in prof_masks]
    student_features = [extract_pose_features(mask) for mask in student_masks]
    
    # Calculate flow between consecutive frames
    prof_flows = []
    student_flows = []
    
    # Calculate professor flows
    for i in range(1, len(prof_masks)):
        try:
            magnitude, angle = calculate_flow(prof_masks[i-1], prof_masks[i])
            prof_flows.append({
                'mean_magnitude': np.mean(magnitude),
                'mean_angle': np.mean(angle),
            })
        except Exception as e:
            print(f"Error calculating professor flow: {e}")
            prof_flows.append({'mean_magnitude': 0.0, 'mean_angle': 0.0})
    
    # Calculate student flows
    for i in range(1, len(student_masks)):
        try:
            magnitude, angle = calculate_flow(student_masks[i-1], student_masks[i])
            student_flows.append({
                'mean_magnitude': np.mean(magnitude),
                'mean_angle': np.mean(angle),
            })
        except Exception as e:
            print(f"Error calculating student flow: {e}")
            student_flows.append({'mean_magnitude': 0.0, 'mean_angle': 0.0})
    
    # Compare using DTW to handle different speeds
    distance, path = fastdtw(prof_features, student_features, dist=euclidean)
    
    # Calculate spatial similarity along the path
    spatial_similarities = []
    for prof_idx, student_idx in path:
        if prof_idx < len(prof_masks) and student_idx < len(student_masks):
            sim = intersectionOverUnion(prof_masks[prof_idx], student_masks[student_idx])
            print(f"Similarity at (prof_idx={prof_idx}, student_idx={student_idx}): {sim}")
            spatial_similarities.append(sim)
    
    # Calculate flow similarity
    flow_similarities = []
    for prof_idx, student_idx in path:
        if prof_idx > 0 and student_idx > 0 and prof_idx <= len(prof_flows) and student_idx <= len(student_flows):
            prof_flow = prof_flows[prof_idx-1]
            student_flow = student_flows[student_idx-1]
            max_mag = max(prof_flow['mean_magnitude'], student_flow['mean_magnitude'], 0.001)  # Avoid division by zero
            flow_sim = 1.0 - abs(prof_flow['mean_magnitude'] - student_flow['mean_magnitude']) / max_mag
            flow_similarities.append(flow_sim)
    
    # Calculate timing (delay)
    delays = [abs(prof_idx - student_idx) for prof_idx, student_idx in path]
    max_delay = max(delays) if delays else 0
    
    # Calculate average similarities
    avg_spatial_sim = sum(spatial_similarities) / len(spatial_similarities) if spatial_similarities else 0.0
    avg_flow_sim = sum(flow_similarities) / len(flow_similarities) if flow_similarities else 0.0
    
    # Calculate calories (assuming 3 seconds per frame as in your processing interval)
    seconds_per_frame = 3
    prof_duration = len(prof_masks) * seconds_per_frame
    student_duration = len(student_masks) * seconds_per_frame
    
    ideal_calories = calculate_calories(prof_flows, prof_duration)
    actual_calories = calculate_calories(student_flows, student_duration)
    
    # Log detailed metrics
    print(f"Average spatial similarity: {avg_spatial_sim}")
    print(f"Average flow similarity: {avg_flow_sim}")
    print(f"Max delay: {max_delay}")
    print(f"Ideal calories: {ideal_calories}")
    print(f"Actual calories: {actual_calories}")
    
    # Return results with calories included
    return {
        'average_spatial_similarity': float(avg_spatial_sim),
        'max_delay': int(max_delay),
        'average_flow_similarity': float(avg_flow_sim),
        'ideal_calories': float(ideal_calories),
        'actual_calories': float(actual_calories)
    }