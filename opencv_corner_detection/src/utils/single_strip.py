import random
import cv2
import numpy as np
import os

BORDER_THICKNESS = 30
TEST_SQUARE = 70
NUM_SENSORS = 14
MARGINS = 10
EXTRA_SPACE = 290
LOGO_PATH = "../../data/real_data/logo/transparent-Logo2-final.png"
LOGO_POSITION = (BORDER_THICKNESS + MARGINS, 1370)
TARGET_SIZE = (1920, 1080)
OUTPUT_PATH = '../../data/synthetic_data/test_strip.png '

def random_color():
    return tuple((random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)))

def overlay_logo_on_strip(strip_image, logo_path=LOGO_PATH, position=LOGO_POSITION, logo_dims=(TEST_SQUARE + 5, TEST_SQUARE + 5)):
    image_transformed = strip_image.copy()

    # Load and resize the logo
    logo = cv2.imread(logo_path, cv2.IMREAD_UNCHANGED)
    logo = cv2.resize(logo, logo_dims)

    if logo.shape[2] == 4:
        bgr_logo = logo[:, :, :3]
        alpha_channel = logo[:, :, 3]

        y_offset, x_offset = position
        y_end = y_offset + bgr_logo.shape[0]
        x_end = x_offset + bgr_logo.shape[1]

        # Ensure the logo fits within the strip boundaries
        if y_end > image_transformed.shape[0] or x_end > image_transformed.shape[1]:
            raise ValueError("Logo does not fit within the strip image dimensions.")

        # Blend the logo onto the strip
        for c in range(3):  # Iterate over the BGR channels
            image_transformed[y_offset:y_end, x_offset:x_end, c] = (
                alpha_channel / 255.0 * bgr_logo[:, :, c] +
                (1 - alpha_channel / 255.0) * image_transformed[y_offset:y_end, x_offset:x_end, c]
            )
    else:
        raise ValueError("Logo image must have an alpha channel for transparency.")

    return image_transformed

def create_basic_test_image(border_thickness=BORDER_THICKNESS, test_square=TEST_SQUARE, num_sensors=NUM_SENSORS, margins=MARGINS, extra_space=EXTRA_SPACE):
    strip_width = test_square + 2 * margins
    strip_length = num_sensors * test_square + (num_sensors + 1) * margins + extra_space

    # Create image and mask with black border
    image = np.zeros((strip_width + 2 * border_thickness, strip_length + 2 * border_thickness, 3), dtype=np.uint8)
    image.fill(255)

    # Outer black border
    x_offset = (image.shape[0] - (strip_width + 2 * border_thickness)) // 2
    y_offset = (image.shape[1] - (strip_length + 2 * border_thickness)) // 2
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

    return image

def save_strip_with_logo(output_path=OUTPUT_PATH):
    # Generate a basic strip image
    strip_image = create_basic_test_image()

    # Overlay logo onto the strip image
    strip_with_logo = overlay_logo_on_strip(strip_image)

    # Save the resulting image
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    cv2.imwrite(output_path, strip_with_logo)
    print(f"Strip with logo saved to {output_path}")

# Execute the function to save the strip with logo
save_strip_with_logo()
