import * as util from "node:util";

export const to_uint8array = (value) => {
  const encoder = new TextEncoder();
  return encoder.encode(value);
};

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
