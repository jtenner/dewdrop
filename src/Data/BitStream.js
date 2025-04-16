import * as BitStream from "@thi.ng/bitstream";
/**
 * @typedef {ReturnType<BitStream.bitWriter>} BitWriter
 */

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
 * @type {(size: number) => (value: number) => (writer: BitWriter) => BitWriter}
 */
export const bit_writer_write = (size) => (value) => (writer) => {
  writer.write(value, size);
  return writer;
};

/**
 * @type {Uint8Array => (writer: BitWriter) => BitWriter}
 */
export const bit_writer_write_buffer = (buffer) => (writer) => {
  for (let i = 0; i < buffer.length; i++) {
    writer.write(buffer[i], 8);
  }
  return writer;
};

/**
 * @type {(size: number) => (index: number) => (reader: BitStream.BitInputStream) => number}
 */
export const bit_reader_read = (size) => (index) => (reader) => {
  reader.seek(index);
  return reader.read(size, true);
};

/**
 * @type {(size: number) => (index: number) => (reader: BitStream.BitInputStream) => number}
 */
export const bit_reader_read_buffer = (size) => (index) => (reader) => {
  const buf = new Uint8Array(size);
  reader.seek(index);
  for (let i = 0; i < size; i++) {
    buf[i] = reader.read(8, true);
  }
  return buf;
};
