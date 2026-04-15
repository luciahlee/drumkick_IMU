import os
import glob
from PIL import Image


def stitch_song_plots(song_name):
    print(f"Stitching plots for: {song_name.upper()}...")

    # Define our grid structure
    participants = ["participant1", "participant2", "participant3", "participant4"]
    p_prefixes = ["p1", "p2", "p3", "p4"]
    plot_types = ["main", "ang", "acc"]

    # Store the opened image objects in a 2D list (rows = plot types, cols = participants)
    grid_images = [[None for _ in range(4)] for _ in range(3)]

    # 1. Find and open all the images
    for col_idx, (folder, prefix) in enumerate(zip(participants, p_prefixes)):
        for row_idx, p_type in enumerate(plot_types):
            # Use a wildcard (*) to ignore the timestamp part of the filename
            search_path = f"initial_data/p1p2/{folder}/{prefix}{song_name}_*_{p_type}.png"
            found_files = glob.glob(search_path)

            if found_files:
                # Open the first matching file
                img = Image.open(found_files[0])
                grid_images[row_idx][col_idx] = img
            else:
                print(f"  Warning: Missing file for {prefix}{song_name}_{p_type}")

    # 2. Calculate the size of the final stitched canvas
    # We will assume all images are roughly the same size, so we find the max width/height
    max_w = 0
    max_h = 0
    for row in grid_images:
        for img in row:
            if img:
                max_w = max(max_w, img.width)
                max_h = max(max_h, img.height)

    if max_w == 0 or max_h == 0:
        print(f"  Failed: No images found for {song_name}\n")
        return

    # Calculate total canvas size (4 columns wide, 3 rows tall)
    canvas_width = max_w * 4
    canvas_height = max_h * 3

    # Create a blank white canvas
    canvas = Image.new('RGB', (canvas_width, canvas_height), (255, 255, 255))

    # 3. Paste the images into the grid
    for row_idx in range(3):
        for col_idx in range(4):
            img = grid_images[row_idx][col_idx]
            if img:
                # Calculate X and Y coordinates for the top-left corner of this image
                x_offset = col_idx * max_w
                y_offset = row_idx * max_h
                canvas.paste(img, (x_offset, y_offset))

    # 4. Save the final stitched image
    output_filename = f"initial_data/p1p2/Stitched_{song_name.upper()}_Comparison.png"
    canvas.save(output_filename)
    print(f"  Success! Saved as {output_filename}\n")


# =====================================================================
# Run the function for all your songs
# =====================================================================
if __name__ == "__main__":
    songs_to_stitch = [
        "pop1", "pop2",
        "jazz1",
        "shuffle1", "shuffle2",
        "rock1", "rock2"
    ]

    for song in songs_to_stitch:
        stitch_song_plots(song)

    print("All stitching complete!")