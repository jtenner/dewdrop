import * as fs from "node:fs";

/**
 * Read binary data from a file.
 * 
 *  * @type {(path: string) => Uint8Array}
 */
export const read_binary = (path) => fs.readFileSync(path); 

/**
 * Write binary data to a file.
 * 
 *  * @type {(path: string) => (data: Uint8Array) => string}
 */
export const write_binary = (path) => (data) => fs.writeFileSync(path, data);
