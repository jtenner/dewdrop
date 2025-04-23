declare module "@fry/bits" {
  export class Bits {
    constructor(value: number | Buffer);

    public static alloc(...args: Parameters<typeof Buffer.alloc>): Bits;
    public static from(...args: Parameters<typeof Buffer.from>): Bits;

    buffer: Buffer;
    _length: number;
    _offset: number;

    readonly eof: boolean;

    offset: number;
    remaining: number;

    clear(value?: number): this;
    clearBit(offset: number): this;
    clearBits(offset: number): this;
    flipBit(offset: number): 1 | 0;
    getBit(offset: number): ReturnType<typeof this.peek>;
    insert(value: number, count?: number, offset?: number): number;
    peek(value?: number, offset?: number): number;
    modifyBit(value: number, offset: number): this;
    read(count?: number): ReturnType<typeof this.peek>;
    seek(offset: number, whence?: number): this;
    setBit(offset: number): this;
    skip(count: number): this;
    testBit(offset: number): boolean;
    toString(
      ...args: Parameters<typeof Buffer.prototype.toString>
    ): ReturnType<typeof Buffer.prototype.toString>;
    write(value: number, count?: number): this;
  }
}
