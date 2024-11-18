import cv2
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial.distance import euclidean
import json


def return_colors(image_path, template_path):

    #Image Loading
    template = cv2.imread(template_path)
    image = cv2.imread(image_path)

    if template is None or image is None:
        return json.dumps({'error': 'Image not found'})

    #Image Preprocessing
    img_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    img_gray = cv2.medianBlur(img_gray, 3)
    _, thresh = cv2.threshold(img_gray, 127, 255, cv2.THRESH_BINARY) # Should remove small lighting issues      # TODO: HYPERPARAMETER
    edges = cv2.Canny(thresh, 100, 200, apertureSize=3) # TODO: HYPERPARAMETER

    #Contour filtering
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    image_copy = np.zeros_like(image)
    if len(contours):
      for idx, contour in enumerate(contours):
        epsilon = 0.01 * cv2.arcLength(contour, True)
        contour = cv2.approxPolyDP(contour, epsilon, True)
        cv2.drawContours(image_copy, [contour], -1, (0, 255, 0), 3)
    else:
        return json.dumps(({'error': 'No Contour detected'}))

    min_contour_area = image.shape[0]*image.shape[1]*0.03 # TODO: HYPERPARAMETER (Later increase) # Should make computation easier later also remove the logo contour
    max_contour_area = image.shape[0]*image.shape[1]*0.95  # TODO: HYPERPARAMETER (Later decrease)
    filtered_contours = [contour for contour in contours if min_contour_area < cv2.contourArea(contour) < max_contour_area]
    image_copy = np.zeros_like(image)
    if len(filtered_contours):
      for idx, contour in enumerate(filtered_contours):
        cv2.drawContours(image_copy, [contour], -1, (0, 255, 0), 3)
    else:
        return json.dumps(({'error': 'No large enough Contour detected'}))

    # Template Matching using ORB and FLANN
    orb = cv2.ORB_create()
    image_gray_for_orb = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    template_gray_for_orb = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)
    kt, d_temp = orb.detectAndCompute(template_gray_for_orb, None)
    ki, d_img = orb.detectAndCompute(image_gray_for_orb, None)
    index_params = dict(algorithm=6,
                        table_number=6,
                        key_size=12,
                        multi_probe_level=1)
    search_params = dict(checks=5)  # Number of checks during search (higher value = more accuracy)# TODO: HYPERPARAMETER (keep low to ensure that there is not much accuracy)
    flann = cv2.FlannBasedMatcher(index_params, search_params)

    matches = flann.knnMatch(d_temp, d_img, k=2)

    good_matches = []
    for m in matches:
        if len(m) == 2:  #
            if m[0].distance < 0.8 * m[1].distance: # TODO: HYPERPARAMETER
                good_matches.append(m[0])


    good_points_template = []
    good_points_image = []

    for match in good_matches:
        good_points_template.append(kt[match.queryIdx].pt)
        good_points_image.append(ki[match.trainIdx].pt)

    good_points_template = np.array(good_points_template)
    good_points_image = np.array(good_points_image)

    contour_matched = []

    # Removing unmatched contours
    if len(filtered_contours) == 1:
      contour_matched.append(filtered_contours[0])
    else:
      for contour in filtered_contours:
          for point in good_points_image:
              if cv2.pointPolygonTest(contour, tuple(point), False) >= 0:
                  contour_matched.append(contour)
                  break

    image_copy_1 = np.zeros_like(image)
    segmented_mask_intermediate = np.zeros_like(image)
    if len(contour_matched):
      for idx, contour in enumerate(contour_matched):
        cv2.drawContours(image_copy_1, [contour], -1, (0, 255, 0), 3)
      largest_contour = max(contour_matched, key=cv2.contourArea)
      cv2.drawContours(segmented_mask_intermediate, [largest_contour], -1, (0, 255, 0), -1)
    else:
        return json.dumps({'error': 'Improper Matching'})

    final_mask = segmented_mask_intermediate.copy()
    if segmented_mask_intermediate.ndim == 3:
        final_mask = cv2.cvtColor(segmented_mask_intermediate, cv2.COLOR_BGR2GRAY)

    _, final_mask = cv2.threshold(final_mask, 127, 255, cv2.THRESH_BINARY) # TODO: Hyperparameter Decrease Later
    segmented_strip_intermediate = cv2.bitwise_or(image,image,mask=final_mask)

    segmented_strip_modified = cv2.cvtColor(segmented_strip_intermediate, cv2.COLOR_BGR2GRAY)
    segmented_strip_modified = cv2.morphologyEx(segmented_strip_modified, cv2.MORPH_OPEN, None)
    _, segmented_strip_modified = cv2.threshold(segmented_strip_modified, 127, 255, cv2.THRESH_BINARY)

    contours_segmented, _ = cv2.findContours(segmented_strip_modified, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    segmented_strip_mask = np.zeros_like(image)
    if len(contours_segmented):
      for idx, contour in enumerate(contours_segmented):
        epsilon = 0.01 * cv2.arcLength(contour, True)
        contour = cv2.approxPolyDP(contour, epsilon, True)
        cv2.drawContours(segmented_strip_mask, [contour], -1, (0, 255, 0), -1)
    segmented_strip_mask = cv2.cvtColor(segmented_strip_mask, cv2.COLOR_BGR2GRAY)
    _,segmented_strip_mask = cv2.threshold(segmented_strip_mask, 127, 255, cv2.THRESH_BINARY)

    segmented_strip = cv2.bitwise_or(image, image, mask=segmented_strip_mask)

    def order_pts(pts):

        rect = np.zeros((4, 2), dtype="float32")

        s = pts.sum(axis=1)
        rect[0] = pts[np.argmin(s)]
        rect[3] = pts[np.argmax(s)]

        diff = np.diff(pts, axis=1)
        rect[1] = pts[np.argmin(diff)]
        rect[2] = pts[np.argmax(diff)]

        return rect

    # Perspective Transforming
    img = segmented_strip.copy()
    img_with_contour = img.copy()
    (rows, cols, _) = img.shape

    u0 = cols / 2.0
    v0 = rows / 2.0

    contours, _ = cv2.findContours(cv2.cvtColor(segmented_strip, cv2.COLOR_BGR2GRAY), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        largest_contour = max(contours, key=cv2.contourArea)
        cv2.drawContours(img_with_contour, [largest_contour], 0, (255, 0, 0), 1)

        epsilon = 0.01 * cv2.arcLength(largest_contour, True)
        approx_corners = cv2.approxPolyDP(largest_contour, epsilon, True)

        if len(approx_corners) == 4:
            p = np.float32([point[0] for point in approx_corners])
            p = order_pts(p)

            w1 = euclidean(p[0], p[1])
            w2 = euclidean(p[2], p[3])
            h1 = euclidean(p[0], p[2])
            h2 = euclidean(p[1], p[3])

            for (x, y) in p:
                cv2.circle(img_with_contour, (int(x), int(y)), 10, (0, 255, 0), -1)

            w = max(w1, w2)
            h = max(h1, h2)

            ar_vis = float(w) / float(h)

            m1 = np.array((p[0][0], p[0][1], 1)).astype('float32')
            m2 = np.array((p[1][0], p[1][1], 1)).astype('float32')
            m3 = np.array((p[2][0], p[2][1], 1)).astype('float32')
            m4 = np.array((p[3][0], p[3][1], 1)).astype('float32')

            k2 = np.dot(np.cross(m1, m4), m3) / np.dot(np.cross(m2, m4), m3)
            k3 = np.dot(np.cross(m1, m4), m2) / np.dot(np.cross(m3, m4), m2)

            n2 = k2 * m2 - m1
            n3 = k3 * m3 - m1

            f = np.sqrt(np.abs((1.0 / (n2[2] * n3[2])) *
                                 ((n2[0] * n3[0] - (n2[0] * n3[2] + n2[2] * n3[0]) * u0 + n2[2] * n3[2] * u0 ** 2) +
                                  (n2[1] * n3[1] - (n2[1] * n3[2] + n2[2] * n3[1]) * v0 + n2[2] * n3[2] * v0 ** 2))))

            A = np.array([[f, 0, u0], [0, f, v0], [0, 0, 1]]).astype('float32')

            ar_real = np.sqrt(np.dot(np.dot(np.dot(n2, np.linalg.inv(A.T)), np.linalg.inv(A)), n2) /
                                np.dot(np.dot(np.dot(n3, np.linalg.inv(A.T)), np.linalg.inv(A)), n3))

            if ar_real < ar_vis:
                W = int(w)
                H = int(W / ar_real)
            else:
                H = int(h)
                W = int(ar_real * H)

            pts1 = np.array(p).astype('float32')
            pts2 = np.float32([[0, 0], [W, 0], [0, H], [W, H]])

            M = cv2.getPerspectiveTransform(pts1, pts2)
            dst = cv2.warpPerspective(img, M, (W, H))
        else:
            return json.dumps({'error': 'exact 4 points not found'})
    else:
        return json.dumps({'error': 'Contour not found'})

    # Image Realigning
    if np.sum(dst[:,:int(0.1*dst.shape[1]),:])>np.sum(dst[:,int(0.9*dst.shape[1]):,:]):
      dst = cv2.rotate(dst, cv2.ROTATE_180)

    # Color segmentation
    img = dst.copy()
    rows, cols, _ = img.shape
    middle_row = np.ones((20,img.shape[1],img.shape[2]),dtype='uint8')*255
    middle_row[:, :int(0.9*cols), :] = img[rows//2-10:rows//2+10, :int(0.9*cols), :]
    middle_row_gray = cv2.cvtColor(middle_row, cv2.COLOR_BGR2GRAY)
    _, thresholded_row = cv2.threshold(middle_row_gray, 200, 255, cv2.THRESH_BINARY)

    contours, _ = cv2.findContours(np.bitwise_not(thresholded_row), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    box_centers = []
    for contour in contours:
        if cv2.contourArea(contour) > 100:  # Filter out small contours
            x, y, w, h = cv2.boundingRect(contour)
            box_center_x = x + w // 2
            box_centers.append(box_center_x)

    box_centers.sort()

    first_box = box_centers[0]
    last_box = box_centers[-1]

    total_width = last_box - first_box

    distance_between_centers = total_width // 13

    calculated_centers = [first_box + i * distance_between_centers for i in range(14)]

    cv2.drawContours(thresholded_row, contours, -1, 120, 10)

    for center in calculated_centers:
        cv2.circle(img, (center, rows // 2), 20, (0, 0, 255), 5)

    # plt.figure(figsize=(10, 10))
    # plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    # plt.title("Detected Contours and Box Centers")
    # plt.show()



    img = (cv2.cvtColor(dst, cv2.COLOR_BGR2RGB)).copy()
    rows, cols, _ = img.shape

    def find_Color_center_one(img_copy, vert, horiz, percentage):
      """removes noise by taking mean""" # TODO: Before this add lighting compensation somewhat to make it work
      box_half_side = int(percentage * img_copy.shape[1]) // 2

      y_start = vert - box_half_side
      y_end = vert + box_half_side
      x_start = horiz - box_half_side
      x_end = horiz + box_half_side

      return list(np.mean(img_copy[y_start: y_end, x_start: x_end].reshape(-1, 3), axis=0))

    img = (cv2.cvtColor(dst, cv2.COLOR_BGR2RGB)).copy()
    rows, cols, _ = img.shape

    center_row = rows//2
    colors = [find_Color_center_one(img,center_row,x, 0.015) for x in calculated_centers]
    return json.dumps({'error': '', 'colors':colors, 'message': 'Processed successfully'})

if __name__ == '__main__':
    IMAGE_PATH = r"D:\Projects\Water_Sensing_IOT\opencv_corner_detection\data\synthetic_data\generated_image\synthetic_image_4.png"
    TEMPLATE_PATH = r"D:\Projects\Water_Sensing_IOT\opencv_corner_detection\data\real_data\logo\transparent-Logo2-final.png"
    print(return_colors(image_path=IMAGE_PATH, template_path=TEMPLATE_PATH))

