"""T1 host-only PNG input. No conversion, decoder or new state in the PRG."""
from pathlib import Path
import re


def expand_textures(textures, scene_dir=None):
    """Normalize source PNGs to the existing texture contract, in place."""
    for texture in textures:
        source = texture.get('source')
        identity = f"Mode 7 texture {texture.get('id', '<missing id>')!r}, source {source!r}"

        def fail(message):
            raise ValueError(f'{identity}: {message}')

        if ('texels' in texture) == ('source' in texture):
            fail('expected exactly one of texels or source; neither/both are invalid')
        if 'source' not in texture:
            if 'sourceColors' in texture:
                fail('sourceColors requires source; omit it for inline texels')
            continue
        if not isinstance(source, str) or not source.strip():
            fail('source must be a nonempty PNG file path')
        path = Path(source)
        if not path.is_absolute():
            if scene_dir is None:
                fail('relative source requires the scene file directory')
            path = Path(scene_dir) / path
        path = path.resolve()
        identity = f"Mode 7 texture {texture.get('id', '<missing id>')!r}, source '{path}'"
        if path.suffix.lower() != '.png':
            fail('expected a .png file; other image formats are unsupported')
        colors = texture.get('sourceColors')
        if (not isinstance(colors, list) or len(colors) != 3 or
                any(not isinstance(c, str) or re.fullmatch(r'#[0-9a-fA-F]{6}', c) is None for c in colors)):
            fail('sourceColors must contain exactly three #RRGGBB strings in Dark/High/Highlight order')
        rgb = [tuple(int(c[i:i+2], 16) for i in (1, 3, 5)) for c in colors]
        if len(set(rgb)) != 3:
            fail('sourceColors must contain three distinct RGB colors (duplicates found)')
        for dimension in ('width', 'height'):
            if dimension in texture and texture[dimension] != 16:
                fail(f'{dimension} is {texture[dimension]!r}; expected 16 or omission for PNG input')
        if not path.is_file():
            fail('file does not exist; expected a readable PNG 16x16')
        try:
            from PIL import Image
        except ImportError:
            fail('PNG import requires host dependency Pillow; install with python -m pip install Pillow')
        try:
            with Image.open(path) as image:
                if image.format != 'PNG':
                    fail(f'file content is {image.format!r}; expected PNG, regardless of extension')
                if image.size != (16, 16):
                    fail(f'dimensions are {image.width}x{image.height}; expected exactly 16x16')
                if getattr(image, 'n_frames', 1) != 1:
                    fail('animated PNG is unsupported; expected one static image')
                # Pillow can silently reduce 16-bit RGB on decode. Reject it,
                # rather than implicitly quantizing an exact RGB contract.
                with path.open('rb') as stream:
                    header = stream.read(25)
                if len(header) < 25 or header[24] > 8:
                    fail('expected PNG channels of at most 8 bits; 16-bit samples are unsupported')
                image.verify()
            with Image.open(path) as image:
                pixels = list(image.convert('RGBA').getdata())
        except (OSError, SyntaxError) as error:
            fail(f'cannot decode a valid PNG: {error}; expected an intact static PNG 16x16')
        actual = set()
        for index, pixel in enumerate(pixels):
            if pixel[3] != 255:
                fail(f'pixel ({index % 16},{index // 16}) has alpha {pixel[3]}; expected 255 (fully opaque)')
            actual.add(pixel[:3])
        if len(actual) != 3:
            fail(f'image uses {len(actual)} RGB colors; expected exactly three actually used colors')
        codes = {color: i + 1 for i, color in enumerate(rgb)}
        for index, pixel in enumerate(pixels):
            if pixel[:3] not in codes:
                color = '#%02X%02X%02X' % pixel[:3]
                fail(f'pixel ({index % 16},{index // 16}) is {color}, absent from sourceColors; expected an exact declared RGB match')
        texture['width'] = texture['height'] = 16
        texture['texels'] = [codes[pixel[:3]] for pixel in pixels]
        del texture['source']
        del texture['sourceColors']
