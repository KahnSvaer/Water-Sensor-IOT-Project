import cv2
import numpy as np


def show_image(numpy_image_list, scale_factor=1, window_name = "Frame") -> None:
    for i in range(len(numpy_image_list)):
        copy_image = np.copy(numpy_image_list[i])
        copy_image = cv2.resize(copy_image, None, fx=scale_factor, fy=scale_factor, interpolation=cv2.INTER_AREA)
        cv2.imshow(window_name+f"{i}", copy_image)
    while True:
        if cv2.waitKey(0) & ord("c"):
            cv2.destroyAllWindows()
            break