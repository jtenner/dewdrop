import * as util from "node:util";

/**
 * @type {(value: string) => Uint8Array}
 */
export const to_uint8array = (value) => {
  const encoder = new TextEncoder();
  return encoder.encode(value);
};

/**
 * Uint8Array -> Maybe String -> (String -> Maybe String) -> Maybe String
 * @type {(value: Uint8Array) => (default_value: Maybe<string>) => (callback: (string) => Maybe<string>) => Maybe<string>}
 */
export const from_uint8array = (value) => (default_value) => (callback) => {
  try {
    const decoder = new TextDecoder();
    return callback(decoder.decode(value));
  } catch (_) {
    return default_value;
  }
};

/**
 * @type {(value: Uint8Array) => number}
 */
export const uint8array_length = (value) => value.length;

/**
 *
 * @type {(a: string) => (b: string) => string}
 */
export const str_char = (a) => (b) => a + b;

/**
 *
 * @type {(a: string) => (b: string) => string}
 */
export const char_str = str_char;

/**
 *
 * @type {(tag: string) => (value: A) => A}
 */
export const trace = (tag) => (value) => {
  console.log(
    `${tag}: ${util.inspect(value, {
      depth: Number.POSITIVE_INFINITY,
      colors: false,
      compact: false,
      breakLength: Number.POSITIVE_INFINITY,
    })}`,
  );
  return value;
};

/**
 * @type {(ArrayLike<number>) => Uint8Array}
 */
export const array_to_uint8array = (value) => new Uint8Array(value);
