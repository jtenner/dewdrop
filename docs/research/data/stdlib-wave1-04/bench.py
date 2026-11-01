"""Generate bounded production query probes. Run compilers only under build.lock."""
from pathlib import Path
root = Path(__file__).resolve().parents[4]
for size in (64, 512, 4096):
    # No dot forces a full extension scan; one component forces full parent scan.
    value = 'x' * size
    source = f'''open dew.std.path
open dew.std.string
pub fn main() -> I32 {{
  match relative_path("{value}") {{
    Result::Err(_) => 0
    Result::Ok(path) => {{
      if path.filename().byte_length() == {size}u32 &&
        path.stem().byte_length() == {size}u32 &&
        path.extension() is Option::None && path.parent() is Option::None {{
        1
      }} else {{
        0
      }}
    }}
  }}
}}
'''
    (root / f'.tmp/bench-{size}.dew').write_text(source)
