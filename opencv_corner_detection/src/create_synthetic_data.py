import random
from utils.image import show_image
from utils.test import check_mask_alignment
import cv2
import numpy as np
import pandas as pd
import os

def random_color():
    return tuple((random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)))

def create_basic_test_image(border_thickness=30, test_square=70, num_sensors=14, margins=10, extra_space=210):
    strip_width = test_square + 2 * margins
    strip_length = num_sensors * test_square + (num_sensors + 1) * margins + extra_space

    # Create image and mask with black border
    image = np.zeros((strip_width + 2 * border_thickness, strip_length + 2 * border_thickness, 3), dtype=np.uint8)
    image.fill(255)

    x_offset = (image.shape[0] - (strip_width + 2 * border_thickness)) // 2
    y_offset = (image.shape[1] - (strip_length + 2 * border_thickness)) // 2

    # Outer black border
    cv2.rectangle(image, (x_offset, y_offset),
                  (x_offset + strip_length + 2 * border_thickness, y_offset + strip_width + 2 * border_thickness),
                  (0, 0, 0), -1)

    # Inner white rectangle
    cv2.rectangle(image, (x_offset + border_thickness, y_offset + border_thickness),
                  (x_offset + strip_length + border_thickness, y_offset + strip_width + border_thickness),
                  (255, 255, 255), -1)

    # Draw sensor squares
    x_ptr = x_offset + border_thickness + margins
    y_ptr = margins + border_thickness
    colors = [random_color() for _ in range(num_sensors)]
    for color in colors:
        cv2.rectangle(image, (x_ptr, y_ptr), (x_ptr + test_square, y_ptr + test_square), color, -1)
        x_ptr += test_square + margins

    # Create black masks with white strip areas
    mask = np.zeros_like(image)
    reading_mask = np.zeros_like(image)
    cv2.rectangle(mask, (x_offset + border_thickness, y_offset + border_thickness),
                  (x_offset + strip_length + border_thickness, y_offset + strip_width + border_thickness),
                  (255, 255, 255), -1)
    cv2.rectangle(reading_mask, (x_offset, y_offset),
                  (x_offset + strip_length + 2 * border_thickness, y_offset + strip_width + 2 * border_thickness),
                  (255, 255, 255), -1)

    # show_image([image,mask,reading_mask])

    return image, mask, reading_mask, colors

def apply_random_perspective(image, mask, reading_mask, max_warp=30):

    # Add padding for perspective transform
    padding = max_warp
    padded_image = cv2.copyMakeBorder(image, padding, padding, padding, padding, cv2.BORDER_CONSTANT, value=(0, 0, 0))
    padded_mask = cv2.copyMakeBorder(mask, padding, padding, padding, padding, cv2.BORDER_CONSTANT, value=(0, 0, 0))
    padded_reading_mask = cv2.copyMakeBorder(reading_mask, padding, padding, padding, padding, cv2.BORDER_CONSTANT, value=(0, 0, 0))

    ph, pw = padded_image.shape[:2]
    src_pts = np.float32([[0, 0], [pw, 0], [0, ph], [pw, ph]])
    dest_pts = src_pts + np.random.uniform(-max_warp, max_warp, src_pts.shape).astype(np.float32)

    matrix = cv2.getPerspectiveTransform(src_pts, dest_pts)
    warped_image = cv2.warpPerspective(padded_image, matrix, (pw, ph))
    warped_mask = cv2.warpPerspective(padded_mask, matrix, (pw, ph))
    warped_reading_mask = cv2.warpPerspective(padded_reading_mask, matrix, (pw, ph))

    # show_image([warped_image, warped_mask, warped_reading_mask])

    return warped_image, warped_mask, warped_reading_mask

def rotate_image(image, angle):
    h, w = image.shape[:2]
    center = (w // 2, h // 2)
    rotation_matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    abs_cos, abs_sin = abs(rotation_matrix[0, 0]), abs(rotation_matrix[0, 1])
    new_w, new_h = int(h * abs_sin + w * abs_cos), int(h * abs_cos + w * abs_sin)

    rotation_matrix[0, 2] += (new_w - w) / 2
    rotation_matrix[1, 2] += (new_h - h) / 2

    rotated_image = cv2.warpAffine(image, rotation_matrix, (new_w, new_h), borderValue=(0, 0, 0))
    return rotated_image

def overlay_strip_on_background(strip_image, strip_mask, strip_reading_mask, background_image, scale_factor_lower=0.8, scale_factor_higher=1):
    scale_factor = random.uniform(scale_factor_lower, scale_factor_higher)
    strip_image = cv2.resize(strip_image, None, fx=scale_factor, fy=scale_factor, interpolation=cv2.INTER_AREA)
    strip_mask = cv2.resize(strip_mask, None, fx=scale_factor, fy=scale_factor, interpolation=cv2.INTER_AREA)
    strip_reading_mask = cv2.resize(strip_reading_mask, None, fx=scale_factor, fy=scale_factor, interpolation=cv2.INTER_AREA)

    bg_h, bg_w = background_image.shape[:2]
    strip_h, strip_w = strip_image.shape[:2]

    if strip_h > bg_h or strip_w > bg_w:
        background_image = cv2.resize(background_image, (strip_w, strip_h))

    bg_h, bg_w = background_image.shape[:2]
    max_x = bg_w - strip_w
    max_y = bg_h - strip_h
    x_offset = random.randint(0, max_x)
    y_offset = random.randint(0, max_y)

    roi = background_image[y_offset:y_offset + strip_h, x_offset:x_offset + strip_w]
    strip_fg = cv2.bitwise_and(strip_image, strip_image, mask=strip_reading_mask[:, :, 0])
    bg_bg = cv2.bitwise_and(roi, roi, mask=cv2.bitwise_not(strip_reading_mask[:, :, 0]))
    combined = cv2.add(strip_fg, bg_bg)
    background_image[y_offset:y_offset + strip_h, x_offset:x_offset + strip_w] = combined

    background_mask = np.zeros_like(background_image)
    background_mask[y_offset:y_offset + strip_h, x_offset:x_offset + strip_w] = strip_mask

    return background_image, background_mask

def synthesize_images(num_images=5, output_dir='../data/synthetic_data'):
    os.makedirs(output_dir, exist_ok=True)
    _color_save_dict = {}
    for i in range(num_images):
        backgrounds = load_background_images()
        strip_image, strip_mask, strip_reading_mask, colors = create_basic_test_image()
        warped_strip, warped_mask, warped_reading_mask = apply_random_perspective(strip_image, strip_mask, strip_reading_mask)

        angle = random.uniform(-30, 30)
        rotated_strip = rotate_image(warped_strip, angle)
        rotated_mask = rotate_image(warped_mask, angle)
        rotated_reading_mask = rotate_image(warped_reading_mask, angle)

        # show_image([rotated_strip, rotated_mask, rotated_reading_mask])

        background = random.choice(backgrounds) if backgrounds else np.ones((640, 480, 3), dtype=np.uint8) * 255
        final_image, final_mask = overlay_strip_on_background(rotated_strip, rotated_mask, rotated_reading_mask, background)

        # show_image([final_image, final_mask], 0.25)
        # check_mask_alignment(final_image, final_mask)

        image_name = f'synthetic_image_{i + 1}.png'
        cv2.imwrite(os.path.join(output_dir+"/generated_image", image_name), final_image)
        cv2.imwrite(os.path.join(output_dir+"/generated_mask", image_name), final_mask)
        _color_save_dict[image_name]=colors

    return _color_save_dict

def load_background_images(path='../data/real_data/Backgrounds', target_size = (1920, 1080)):
    backgrounds = []
    for filename in os.listdir(path):
        img = cv2.imread(os.path.join(path, filename))
        if img is not None:
            img = cv2.resize(img, target_size)
            backgrounds.append(img)
    return backgrounds

def save_color_dict_to_csv(color_dict, excel_file='../data/synthetic_data/strip_colors.csv'):
    """
    Convert color_dict to a DataFrame and save it to an Excel file.

    Parameters:
    - color_dict (dict): Dictionary with image names as keys and an array of 14 colors as values.
    - excel_file (str): Path to save the Excel file.
    """
    # Prepare the data for DataFrame
    data = []

    for image_name, colors in color_dict.items():
        # Flatten the color array into a dictionary
        color_entry = {'Image Name': image_name}
        for j, color in enumerate(colors, start=1):
            color_entry[f'Color {j} (B)'] = color[0]
            color_entry[f'Color {j} (G)'] = color[1]
            color_entry[f'Color {j} (R)'] = color[2]

        data.append(color_entry)

    # Create a DataFrame
    color_df = pd.DataFrame(data)

    # Save the DataFrame to an Excel file
    color_df.to_csv(excel_file, index=False)
    print(f"Color data saved to {excel_file}")





color_save_dict = synthesize_images(250)
save_color_dict_to_csv(color_save_dict)
