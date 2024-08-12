import cv2 as cv
import mediapipe as mp
frame = cv.imread('training/albedo/alley_1/frame_0001.png')
cv.imshow('Original', frame)
mp_pose = mp.solutions.pose
def extract_pose_landmarks(image):
    with mp_pose.Pose(
        static_image_mode=True, 
        ) as pose:
        image_rgb = cv.cvtColor(image, cv.COLOR_BGR2RGB)
        results = pose.process(image_rgb)
        if results.pose_landmarks:
            return results.pose_landmarks
        else:
            return None

def extract_roi(image, pose_landmarks, padding=0.1):
    if pose_landmarks:
        
        x_min = min([lmk.x for lmk in pose_landmarks.landmark])
        x_max = max([lmk.x for lmk in pose_landmarks.landmark])
        y_min = min([lmk.y for lmk in pose_landmarks.landmark])
        y_max = max([lmk.y for lmk in pose_landmarks.landmark])


        h, w = image.shape[:2]
        x_min = int((x_min - padding) * w)
        x_max = int((x_max + padding) * w)
        y_min = int((y_min - padding) * h)
        y_max = int((y_max + padding) * h)

        x_min = max(0, x_min)
        x_max = min(w, x_max)
        y_min = max(0, y_min)
        y_max = min(h, y_max)


        roi = image[y_min:y_max, x_min:x_max]
        return roi
    else:
        return image
def preprocess_frames(frame):
    pose_landmarks = extract_pose_landmarks(frame)
    roi = extract_roi(frame, pose_landmarks)
    gray = cv.cvtColor(roi, cv.COLOR_BGR2GRAY)
    normalized = cv.normalize(gray, None, 0, 255, cv.NORM_MINMAX)
    clahe = cv.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhance = clahe.apply(normalized)
    pyramid = cv.pyrDown(enhance)
    return pyramid

preprocessed = preprocess_frames(frame)
cv.imshow('Preprocessed', preprocessed)
cv.waitKey(0)
cv.destroyAllWindows()
