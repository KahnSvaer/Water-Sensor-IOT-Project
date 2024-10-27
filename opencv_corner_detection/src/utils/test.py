import cv2
from utils.image import show_image

def check_mask_alignment(final_image, final_mask, scale=0.25):
    """Display the masked form of the final image on a white background."""
    # Ensure mask is grayscale for applying as a mask
    if len(final_mask.shape) == 3 and final_mask.shape[2] == 3:
        final_mask = cv2.cvtColor(final_mask, cv2.COLOR_BGR2GRAY)

    # Apply the mask to the final image to get masked form
    masked_image = cv2.bitwise_and(final_image, final_image, mask=final_mask)

    # Show the result
    show_image([masked_image], scale, "Masked Final Image on White Background")