#!/usr/bin/env python3
import sys
import os
import PIL.Image

def png_to_nasm_mask(image_path, label_name=None, alpha_threshold=128):
    """
    Converts a 32x32 PNG sprite into a 128-byte NASM bitmask matrix.
    Outputs NASM assembly 'db' statements (4 bytes per line, 32 lines).
    """
    try:
        img = PIL.Image.open(image_path).convert('RGBA')
    except Exception as e:
        print(f"Error opening image '{image_path}': {e}")
        return ""

    width, height = img.size
    if width != 32 or height != 32:
        print(f"; Warning: Image '{image_path}' is {width}x{height}. Resizing to 32x32...")
        img = img.resize((32, 32), PIL.Image.Resampling.NEAREST)

    if label_name is None:
        # Derives label name from filename (e.g., player_idle_f0.png -> sprite_player_idle_f0)
        base = os.path.basename(image_path)
        clean_name = os.path.splitext(base)[0].replace("-", "_").replace(" ", "_")
        label_name = f"sprite_{clean_name}"

    output_lines = []
    output_lines.append(f"; ==============================================================================")
    output_lines.append(f"; FRAME: {label_name} (Source: {os.path.basename(image_path)})")
    output_lines.append(f"; ==============================================================================")
    output_lines.append(f"global {label_name}")
    output_lines.append(f"{label_name}:")

    pixels = img.load()

    for y in range(32):
        row_bytes = []
        for byte_idx in range(4):  # 4 bytes per row (32 pixels / 8)
            byte_val = 0
            for bit_idx in range(8):
                x = byte_idx * 8 + bit_idx
                r, g, b, a = pixels[x, y]

                # Pixel is active if Alpha >= threshold AND RGB is non-black
                is_opaque = a >= alpha_threshold
                is_colored = (r > 30 or g > 30 or b > 30)
                
                if is_opaque and is_colored:
                    # Bit 7 is leftmost (bit_idx = 0 -> shift by 7)
                    byte_val |= (1 << (7 - bit_idx))

            row_bytes.append(byte_val)

        # Format as safe NASM hex syntax: 000h, 00Fh, 0F0h, 000h
        hex_formatted = ", ".join([f"0{b:02X}h" for b in row_bytes])
        output_lines.append(f"    db {hex_formatted}    ; Line {y:02d}")

    return "\n".join(output_lines)


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 png_to_nasm.py <image.png> [output.asm]")
        print("  python3 png_to_nasm.py <sprites_folder/> [output.asm]")
        sys.exit(1)

    target_path = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    # Determine if we need to write the file header (only if creating a brand new file)
    file_exists = False
    if output_file and os.path.exists(output_file) and os.path.getsize(output_file) > 0:
        file_exists = True

    asm_blocks = []
    
    # Add header only for new files
    if not file_exists:
        asm_blocks.extend([
            "; ==============================================================================",
            "; GENERATED SPRITE MATRICES (32x32 Bitmaps - 128 bytes per frame)",
            "; ==============================================================================",
            "bits 16",
            "segment data",
            ""
        ])

    if os.path.isdir(target_path):
        files = sorted([f for f in os.listdir(target_path) if f.lower().endswith('.png')])
        if not files:
            print(f"No PNG files found in directory '{target_path}'")
            sys.exit(1)
        
        for fname in files:
            full_path = os.path.join(target_path, fname)
            asm_blocks.append(png_to_nasm_mask(full_path))
            asm_blocks.append("")
    elif os.path.isfile(target_path):
        asm_blocks.append(png_to_nasm_mask(target_path))
        asm_blocks.append("")
    else:
        print(f"Error: Target path '{target_path}' does not exist.")
        sys.exit(1)

    final_asm = "\n".join(asm_blocks)

    if output_file:
        # Open in APPEND mode ("a") instead of WRITE mode ("w")
        with open(output_file, "a") as f:
            f.write(final_asm + "\n")
        
        action_word = "Appended" if file_exists else "Created & wrote"
        print(f"Successfully {action_word} sprite data to: {output_file}")
    else:
        print(final_asm)


if __name__ == "__main__":
    main()