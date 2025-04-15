import * as BitStream from "@thi.ng/bitstream";

export const bit_reader = (buf) => BitStream.bitReader(buf);
export const bit_writer = (capacity) => BitStream.bitWriter(capacity);

export const bit_writer_to_bytes = (writer) => writer.bytes();

export const bit_writer_write = (size) => (value) => (writer) => {
  writer.write(size, value);
  return writer;
}

export const bit_reader_read = (size) => (reader) => reader(size);
