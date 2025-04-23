import { zeros, write, append_bits, read_u8 } from "./src/Data/Bits";

const five_bits = zeros(5);
const three_bits = zeros(3);
const last_byte = zeros(8);
const target = zeros(16);

write(5)(0)(0b10101)(five_bits);
write(3)(0)(0b111)(three_bits);
write(8)(0)(0b01001001)(last_byte);
append_bits(target)(five_bits);
append_bits(target)(three_bits);
append_bits(target)(last_byte);

console.log(read_u8(0)(target).toString(2));
console.log(read_u8(8)(target).toString(2));
