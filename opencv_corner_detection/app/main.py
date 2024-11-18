from flask import Flask, request, jsonify
import os
from werkzeug.utils import secure_filename
import Color_segmentor as colSeg
import logging

app = Flask(__name__)

UPLOAD_FOLDER = './uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/process_image', methods=['POST'])
def process_image():
    app.logger.debug('Received request for /process_image')
    if 'image' not in request.files or 'template' not in request.files:
        return jsonify({'error': 'Both image and template files are required'}), 400

    image_file = request.files['image']
    template_file = request.files['template']

    if not allowed_file(image_file.filename) or not allowed_file(template_file.filename):
        return jsonify({'error': 'Invalid file format. Only jpg, jpeg, and png are allowed'}), 400

    image_path = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(image_file.filename))
    template_path = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(template_file.filename))

    image_file.save(image_path)
    template_file.save(template_path)

    result = colSeg.return_colors(image_path=image_path, template_path=template_path)

    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
