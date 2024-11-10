import cv2 as cv
import numpy as np
from matplotlib import pyplot as plt


def find_best_contour(image_path, template_path, MIN_MATCH_COUNT=10):
    # Load the images
    img1 = cv.imread(template_path)  # Template image (logo)
    img2 = cv.imread(image_path)  # Query image

    # Check if the images are loaded properly
    if img1 is None or img2 is None:
        print("Error loading images!")
        return

    # Convert images to grayscale
    gray1 = cv.cvtColor(img1, cv.COLOR_BGR2GRAY)  # Template image in grayscale
    gray2 = cv.cvtColor(img2, cv.COLOR_BGR2GRAY)  # Query image in grayscale

    # Initialize the ORB detector
    orb = cv.ORB_create()

    # Detect keypoints and descriptors in both images
    kp1, des1 = orb.detectAndCompute(gray1, None)
    kp2, des2 = orb.detectAndCompute(gray2, None)

    # Use FLANN-based matcher for descriptor matching
    FLANN_INDEX_LSH = 6
    index_params = dict(algorithm=FLANN_INDEX_LSH, table_number=6, key_size=12, multi_probe_level=1)
    search_params = dict(checks=50)

    flann = cv.FlannBasedMatcher(index_params, search_params)

    # Match descriptors between the template and the query image
    matches = flann.knnMatch(des1, des2, k=2)

    # Apply the ratio test to filter out good matches
    good_matches = []
    for m, n in matches:
        if m.distance < 0.75 * n.distance:
            good_matches.append(m)

    # If we have enough good matches, we proceed to find the rough position of the logo
    if len(good_matches) > MIN_MATCH_COUNT:
        # Get the matching keypoints for both images
        pts1 = np.float32([kp1[m.queryIdx].pt for m in good_matches]).reshape(-1, 1, 2)
        pts2 = np.float32([kp2[m.trainIdx].pt for m in good_matches]).reshape(-1, 1, 2)

        # Find the center of the matched keypoints in the query image
        center_of_matches = np.mean(pts2, axis=0)
        center_of_matches_int = np.int32(center_of_matches)  # Convert to integer for drawing
        print(f"Rough position of the logo (center of matched keypoints): {center_of_matches_int}")

        # Convert the image to grayscale for contour detection
        gray_img = cv.cvtColor(img2, cv.COLOR_BGR2GRAY)

        # Threshold the image to get binary image for contour detection
        _, thresh = cv.threshold(gray_img, 127, 255, cv.THRESH_BINARY)

        # Find contours
        contours, _ = cv.findContours(thresh, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

        # Find the smallest contour closest to the rough position
        smallest_contour = None
        min_distance = float('inf')

        for contour in contours:
            # Calculate the centroid of the contour
            M = cv.moments(contour)
            if M["m00"] != 0:
                cx = int(M["m10"] / M["m00"])
                cy = int(M["m01"] / M["m00"])
                contour_center = np.array([cx, cy])

                # Calculate the distance from the rough position
                distance = np.linalg.norm(contour_center - center_of_matches[0])

                # Update the smallest contour if a smaller one is found
                if distance < min_distance:
                    min_distance = distance
                    smallest_contour = contour

        if smallest_contour is not None:
            # Draw the smallest contour on the image
            img2_marked = img2.copy()
            cv.drawContours(img2_marked, [smallest_contour], -1, (0, 255, 0), 10)

            # Mark the best point (center of matches)
            cv.circle(img2_marked, tuple(center_of_matches_int[0]), 10, (255, 0, 0), -1)  # Red circle at the center

            # Display the result
            plt.figure(figsize=(10, 5))

            # Original image
            plt.subplot(1, 2, 1)
            plt.imshow(cv.cvtColor(img2, cv.COLOR_BGR2RGB))
            plt.title("Original Image")
            plt.axis('off')

            # Image with the smallest contour and marked best point
            plt.subplot(1, 2, 2)
            plt.imshow(cv.cvtColor(img2_marked, cv.COLOR_BGR2RGB))
            plt.title("Image with Smallest Contour and Best Point")
            plt.axis('off')

            plt.show()
        else:
            print("No valid contour found!")
    else:
        print(f"Not enough matches are found - {len(good_matches)}/{MIN_MATCH_COUNT}")


# Example usage
image_path = r"D:\Projects\Water_Sensing_IOT\opencv_corner_detection\data\synthetic_data\generated_image\synthetic_image_2.png"
template_path = r"D:\Projects\Water_Sensing_IOT\opencv_corner_detection\data\real_data\logo\Logo1.png"
find_best_contour(image_path, template_path)
