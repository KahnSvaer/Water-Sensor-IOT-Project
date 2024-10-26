import cv2

def show_image(numpy_image_list, window_name = "Frame") -> None:
    for i in range(len(numpy_image_list)):
        cv2.imshow(window_name+f"{i}", numpy_image_list[i])
    while True:
        if cv2.waitKey(0) & ord("c"):
            cv2.destroyAllWindows()
            break