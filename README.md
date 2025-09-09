# 🏋️ TrackFit

## 🤖 AI-Driven Exercise Form Analysis App

TrackFit is an advanced fitness application that uses AI and computer vision to analyze exercise form in real-time. By comparing user movements with reference exercises performed by fitness professionals, TrackFit provides personalized feedback, helping users improve their technique and maximize workout effectiveness.

![TrackFit App](https://via.placeholder.com/800x400?text=TrackFit+App+Screenshot)
---
## 📌 Index
1. 🚀 Project Overview
2. ✨ Features
3. 🛠️ Tech Stack
4. 🏗️ Project Architecture
5. 🔧 Installation
6. 📱 How to Use
7. 🚀 Future Enhancements
8. 🤝 Contributors
---
## ✨ Features

- **Real-time Form Analysis**: Analyzes exercise form through your webcam
- **Professional Comparisons**: Compares your movements to professional reference exercises
- **Detailed Feedback**: Provides specific feedback on form corrections
- **Calorie Tracking**: Estimates calories burned based on exercise intensity
- **Performance Metrics**: Tracks similarity scores and timing consistency
- **Cross-platform**: Works on web browsers through Flutter web
---
## 🛠️ Technologies Used

### 💻 Frontend
- Flutter Web for responsive cross-platform UI
- Dart for application logic
- HTML5 WebRTC for camera access

### 🖥️ Backend
- Flask Python server
- REST API for video processing

### 🤖 AI & Computer Vision
- FastSAM (Segment Anything Model) for precise human segmentation
- YOLOv8 for human detection
- OpenCV for video processing and optical flow analysis
- Dynamic Time Warping (DTW) for movement comparison
---
## 🏗️ Project Architecture

    TrackFit/
    ├── Backend/                  # Python backend
    │   ├── app.py                # Flask server
    │   ├── final.py              # Human detection & segmentation
    │   ├── flow_final.py         # Movement analysis
    │
    └── my_flutter/               # Flutter frontend
        ├── lib/
        │   ├── main.dart         # Entry point
        │   ├── app_page.dart     # Main application
        │   └── login_page.dart   # Authentication
        └── web/                  # Web-specific files
---
## 🔧 Installation

### Prerequisites
- Python 3.8+
- Flutter 3.0+
- Web browser with camera access

### Backend Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/trackfit.git
cd trackfit

# Install Python dependencies
pip install -r requirements.txt

# Start the Flask server
cd FastSAM
python app.py
```

### Frontend Setup
```bash
# Install Flutter dependencies
cd my_flutter
flutter pub get

# Run the web app
flutter run -d chrome
```
---
## 📱 How to Use

1. Open the application in your web browser
2. Login and access to the exercises through start exercise tab
3. Click "Start Webcam" to enable camera access
4. Perform the exercise while staying in frame
5. Click "Analyze Exercise" to process your form
6. Review the feedback and metrics
7. Make adjustments to improve your form
---
## 🎬 Demo

![Demo GIF](https://via.placeholder.com/500x300?text=Demo+GIF)

---

## 🚀 Future Enhancements

- Mobile app support
- More exercise types
- User profiles and progress tracking
- Social sharing features
- Custom exercise recording
---
## 🤝 Contributors
- Dr. Nupur Giri (Project Mentor)
- Karan Bhatia
- Aum Bhambhani
- Piyush Nagrani
- Samarth Nilkanth
--- 

## 🤝 Contributing

We welcome contributions to improve this research framework.
Steps to Contribute

1. Fork the repository.

2. Create a new branch:
```bash
git checkout -b feature-name
```

Make your changes and commit:
```bash
git commit -m "Add feature-name"
```

Push and open a Pull Request.
For details, see our [Contribution Guidelines](CONTRIBUTING.md).

---
## 📜 Code of Conduct
We are committed to providing a welcoming environment.
Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

 ---
## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
## 📑Citation
If you find this work useful, please cite:
```bibtex
Karan Bhatia, Phase-Wise Shapley Credit Assignment for Temporal Decomposition in Multi-Agent Reinforcement Learning, 2025.
```

TrackFit - Transform Your Exercise Form with AI
