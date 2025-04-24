import * as util from "node:util";

export const to_uint8array = (value: string) => {
  const encoder = new TextEncoder();
  return encoder.encode(value);
};

export const from_uint8array =
  <MaybeString>(value: Uint8Array) =>
  (default_value: MaybeString) =>
  (callback: (value: string) => MaybeString) => {
    try {
      const decoder = new TextDecoder();
      return callback(decoder.decode(value));
    } catch (_) {
      return default_value;
    }
  };

export const uint8array_length = (value: Uint8Array) => value.length;

export const str_char = (a: string) => (b: string) => a + b;

export const char_str = str_char;

export const trace =
  <T>(tag: string) =>
  (value: T) => {
    const inspected = util.inspect(value, {
      depth: Number.POSITIVE_INFINITY,
      colors: false,
      compact: false,
      breakLength: Number.POSITIVE_INFINITY,
    });
    console.log(`${tag}: ${inspected}`);
    return value;
  };

export const array_to_uint8array = (value: ArrayLike<number>) =>
  new Uint8Array(value);
