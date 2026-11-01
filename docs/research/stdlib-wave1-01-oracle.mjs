import {writeFileSync} from 'node:fs';
let seed=123456789n;
const samples=[0n,1n,(1n<<64n)-1n,1n<<64n,(1n<<63n)-1n,1n<<63n,-(1n<<63n),-(1n<<63n)-1n];
for(let i=0;i<128;i++){seed=(seed*6364136223846793005n+1442695040888963407n)&((1n<<64n)-1n);samples.push(seed,-seed);}
let body='open dew.std.string\nopen dew.std.text\ntest "Node BigInt bounded decimal oracle" {\n';
let checks=0;
for(const n of samples)for(const signed of [false,true]){
 const text=n.toString(), max=signed?(1n<<63n)-1n:(1n<<64n)-1n, min=signed?-(1n<<63n):0n;
 let result;
 if(!signed&&n<0n)result='Result::Err(DecimalParseError::InvalidDigit(0u32))';
 else if(n<min||n>max){let magnitude=0n,offset=0; const limit=n<0n?-min:max;
 for(let i=text[0]==='-'?1:0;i<text.length;i++){magnitude=magnitude*10n+BigInt(text[i]);if(magnitude>limit){offset=i;break;}}
 result=`Result::Err(DecimalParseError::Overflow(${offset}u32))`;
 }else result=`Result::Ok(${n}${signed?'i64':'u64'})`;
 body+=`  assert(parse_${signed?'i':'u'}64_decimal("!${text}?".view(1u32, ${text.length}u32)) is ${result}, "oracle ${checks++}")\n`;
}
writeFileSync('.tmp/oracle_test.dew',body+'}\n');
let consumer='open dew.std.string\nopen dew.std.text\n';
for(const size of [1,20,200]) consumer+=`pub fn parse${size}() -> U64 {\n  match parse_u64_decimal("!${'0'.repeat(size-1)}7?".view(1u32, ${size}u32)) {\n    Result::Ok(n) => n\n    Result::Err(_) => 0u64\n  }\n}\n`;
consumer+='pub fn main() -> I64 {\n  match parse_i64_decimal("!-9223372036854775808?".view(1u32, 20u32)) {\n    Result::Ok(n) => n\n    Result::Err(_) => 0i64\n  }\n}\n';
writeFileSync('.tmp/consumer.dew',consumer);
console.log(`${samples.length} samples; ${checks} Node BigInt checks`);
