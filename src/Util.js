/**
 *
 * @param {string} str
 * @returns {string[]}
 */
export const to_chars = Array.from;

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
