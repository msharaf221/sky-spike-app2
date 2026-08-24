#!/usr/bin/env python3
"""Generate Android launcher icons from the Sky Spike logo.

Run this AFTER `flutter create . --platforms=android`, because that command
(re)generates the default Flutter launcher icons and would overwrite ours.

Usage:
    python3 tool/generate_launcher_icons.py [logo_path] [res_dir]

Defaults:
    logo_path = assets/images/sky_spike_logo.png
    res_dir   = android/app/src/main/res

Requires Pillow (`pip install pillow`).
"""

import os
import sys

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    sys.stderr.write(
        "Pillow is required: python3 -m pip install --upgrade pillow\n"
    )
    raise SystemExit(1)

# Navy from AppColors primary (0xFF0B2A5B) - adaptive icon background.
BACKGROUND_HEX = "#0B2A5B"

# mipmap density bucket -> legacy launcher icon edge length in px.
BUCKETS = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

# Fraction of the adaptive foreground the artwork may occupy. Android masks
# adaptive icons to a circle/squircle, so the logo must stay well inside.
FOREGROUND_SCALE = 0.66

BACKGROUND_XML = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{color}</color>
</resources>
"""

ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""


def square(image):
    """Pad the image onto a transparent square so it is never stretched."""
    side = max(image.size)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(
        image,
        ((side - image.width) // 2, (side - image.height) // 2),
        image,
    )
    return canvas


def write(path, text):
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(text)
    print("wrote " + path)


def main():
    logo_path = sys.argv[1] if len(sys.argv) > 1 else "assets/images/sky_spike_logo.png"
    res = sys.argv[2] if len(sys.argv) > 2 else "android/app/src/main/res"

    if not os.path.isfile(logo_path):
        print("::warning::%s not found - keeping default launcher icon." % logo_path)
        return 0

    source = square(Image.open(logo_path).convert("RGBA"))

    for bucket, size in BUCKETS.items():
        out_dir = os.path.join(res, "mipmap-" + bucket)
        os.makedirs(out_dir, exist_ok=True)

        legacy = source.resize((size, size), Image.LANCZOS)
        legacy.save(os.path.join(out_dir, "ic_launcher.png"), "PNG")
        legacy.save(os.path.join(out_dir, "ic_launcher_round.png"), "PNG")

        # Adaptive foreground is 108dp against the icon's 48dp legacy box.
        fg_size = int(round(size * 108 / 48))
        inner = int(round(fg_size * FOREGROUND_SCALE))
        foreground = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
        artwork = source.resize((inner, inner), Image.LANCZOS)
        offset = (fg_size - inner) // 2
        foreground.paste(artwork, (offset, offset), artwork)
        foreground.save(os.path.join(out_dir, "ic_launcher_foreground.png"), "PNG")

        print("mipmap-%-8s legacy %dpx / foreground %dpx" % (bucket, size, fg_size))

    values_dir = os.path.join(res, "values")
    anydpi_dir = os.path.join(res, "mipmap-anydpi-v26")
    os.makedirs(values_dir, exist_ok=True)
    os.makedirs(anydpi_dir, exist_ok=True)

    write(
        os.path.join(values_dir, "ic_launcher_background.xml"),
        BACKGROUND_XML.format(color=BACKGROUND_HEX),
    )
    write(os.path.join(anydpi_dir, "ic_launcher.xml"), ADAPTIVE_XML)
    write(os.path.join(anydpi_dir, "ic_launcher_round.xml"), ADAPTIVE_XML)

    print("Launcher icons generated from %s" % logo_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
