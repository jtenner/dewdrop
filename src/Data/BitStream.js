import * as BitStream from "@thi.ng/bitstream";

/**
 *
 * @param {Uint8Array} buf
 */
export const bit_reader_source = (buf) => new BitStream.BitInputStream(buf);

/**
 *
 * @param {BitStream.BitInputStream} reader
 */
export const bit_reader_limit = (reader) => reader.limit;

export const bit_writer_source = (capacity) => BitStream.bitWriter(capacity);

/**
 *
 * @type {(writer: BitStream.BitOutputStream) => Uint8Array}
 */
export const bit_writer_to_bytes = (writer) => writer.bytes();

/**
 *
 * @type {(size: number) => (value: number) => (writer: ReturnType<BitStream.bitWriter>) => void}
 */
export const bit_writer_write = (size) => (value) => (writer) => {
  writer.write(value, size);
};

/**
 *
 * @type {(size: number) => (index: number) => (reader: BitStream.BitInputStream) => number}
 * @returns
 */
export const bit_reader_read = (size) => (index) => (reader) => {
  reader.seek(index);
  return reader.read(size);
};
