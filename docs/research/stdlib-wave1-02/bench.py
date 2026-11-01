"""Generate a pure production consumer; run under the campaign build lock."""
from pathlib import Path
p = Path('.tmp/trim-consumer.dew')
s = 'open dew.std.string\n'
for n in (16, 256, 4096):
    text = ' ' * n + 'λ🌍' + ' ' * n
    s += f'pub fn scan_{n}() -> U32 {{ "x{text}y".view(1u32, {2*n+6}u32).trim_ascii().byte_length() }}\n'
s += '''pub fn convenience() -> U32 {
  " x ".trim_ascii_start().byte_length() +
  " x ".trim_ascii_end().byte_length() + " x ".trim_ascii().byte_length()
}
pub fn empty() -> U32 { "".trim_ascii().byte_length() }
'''
p.write_text(s)
