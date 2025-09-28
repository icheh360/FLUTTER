from flask import Flask, Response
import cv2

app = Flask(__name__)

# MJPEG stream URL
stream_url = 'http://honjin1.miemasu.net/nphMotionJpeg?Resolution=640x480&Quality=Standard'

# باز کردن استریم
cap = cv2.VideoCapture(stream_url)

@app.route('/frame')
def frame():
    if not cap.isOpened():
        return 'Stream not available', 503

    ret, frame = cap.read()
    if not ret:
        return 'Failed to read frame', 500

    # تبدیل فریم به JPEG
    _, jpeg = cv2.imencode('.jpg', frame)
    return Response(jpeg.tobytes(), mimetype='image/jpeg')

if __name__ == '__main__':
    # اجرا روی همه‌ی اینترفیس‌ها
    app.run(host='0.0.0.0', port=5000)
