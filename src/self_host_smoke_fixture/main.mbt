///|
fn self_host_smoke_fingerprint(prefix : Bytes, provider : Bytes) -> Bytes {
  let input = Buffer(size_hint=prefix.length() + provider.length())
  input.write_bytes(prefix)
  input.write_bytes(provider)
  let digest = @cache_binary.blake3(input.to_bytes())
  let output = Buffer(size_hint=32)
  for byte in digest {
    output.write_byte(byte)
  }
  output.to_bytes()
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() != 5 {
    println(
      "usage: self_host_smoke_fixture REQUEST PROVIDER FINGERPRINT_PREFIX OUTPUT",
    )
    @sys.exit(2)
  }
  let provider = @fs.read_file_to_bytes(args[2]) catch {
    error => {
      println("cannot read Starshine provider: \{error}")
      @sys.exit(2)
      b""
    }
  }
  let fingerprint_prefix = @fs.read_file_to_bytes(args[3]) catch {
    error => {
      println("cannot read fingerprint prefix: \{error}")
      @sys.exit(2)
      b""
    }
  }
  let request : @compile_request.CompilerRequest = {
    command: @compile_request.CompilerBuild,
    output_kind: @compile_request.CompilerWasmOutput,
    response: @compile_request.CompilerOutputFile(args[4]),
    root_module: "fixture.main",
    modules: [
      {
        name: "fixture.main",
        files: [
          {
            logical_path: "src/main.dew",
            source: b"struct Point {\n  x: I32\n  y: I64\n}\nenum Choice {\n  Empty\n  One(I32)\n  Pair {\n    left: I32\n    right: I64\n  }\n}\nfn point_x() -> I32 {\n  Point::{\n    x: 5\n    y: 6i64\n  }.x\n}\nfn add(left: I32, right: I32) -> I32 {\n  left + right\n}\nfn twice(value: I32) -> I32 {\n  add(value, value)\n}\nfn is_large(value: U32) -> Bool {\n  value > 2147483648u32\n}\nfn bool_value(value: Bool) -> I32 {\n  match value {\n    true => 1\n    false => 0\n  }\n}\nfn countdown(initial: I32) -> I32 {\n  while initial {\n    value if value == 0 => break 70\n    value => continue value - 1\n  }\n}\nfn wide(value: I64) -> I64 {\n  let next = value + 2i64\n  -next\n}\nfn unsigned_wide(value: U64) -> Bool {\n  value > 9223372036854775808u64\n}\nfn float32(value: F32) -> F32 {\n  -value + 2.5f32\n}\nfn float64(value: F64) -> F64 {\n  value * 4.0f64\n}\nfn fixed_word() -> U32 {\n  let words = FixedArray::make(2u32, 0u32)\n  words.set_unchecked(1u32, 4u32)\n  let word = words.get_unchecked(1u32) | 1u32\n  word\n}\nfn choose(value: I32) -> I32 {\n  if value == 70 && true {\n    return value + 3\n  } else {\n    0\n  }\n}\nfn invoke(callback: fn(I32) -> I32, value: I32) -> I32 {\n  callback(value)\n}\nfn increment(value: I32) -> I32 {\n  value + 1\n}\nstruct PatternRefBox {\n  value: I32\n}\nfn read_pattern_ref_box(value: PatternRefBox) -> I32 {\n  value.value\n}\nfn read_pattern_ref(value: Option<PatternRefBox>) -> I32 {\n  match value {\n    Some(item) => read_pattern_ref_box(item)\n    None => 0\n  }\n}\nfn push_pattern_scalar(values: Array<I32>, value: Option<I32>) -> I32 {\n  match value {\n    Some(item) => {\n      values.push(item)\n      values.get_unchecked(0u32)\n    }\n    None => 0\n  }\n}\nstruct PairBox {\n  value: I32\n}\nfn read_pair(pair: (I32, PairBox)) -> I32 {\n  let (left, right) = pair\n  left + right.value\n}\nfn read_reverse_pair(pair: (PairBox, I32)) -> I32 {\n  let (left, right) = pair\n  left.value + right\n}\nenum BytesPairChoice {\n  NoBytesPair\n  BytesPairValue((Bytes, I32))\n}\nfn read_bytes_pair_match(value: BytesPairChoice) -> I32 {\n  let pair = match value {\n    BytesPairChoice::BytesPairValue(pair) => pair\n    BytesPairChoice::NoBytesPair => {\n      return 0\n    }\n  }\n  let (left, right) = pair\n  if left == b\"abc\" {\n    right\n  } else {\n    0\n  }\n}\nenum ReversePairChoice {\n  NoReversePair\n  ReversePairValue((PairBox, I32))\n}\nfn read_reverse_pair_match(value: ReversePairChoice) -> I32 {\n  let pair = match value {\n    ReversePairChoice::ReversePairValue(pair) => pair\n    ReversePairChoice::NoReversePair => {\n      return 0\n    }\n  }\n  let (left, right) = pair\n  left.value + right\n}\nenum PairChoice {\n  NoPair\n  PairValue((I32, PairBox))\n}\nfn read_pair_match(value: PairChoice) -> I32 {\n  let pair = match value {\n    PairChoice::PairValue(pair) => pair\n    PairChoice::NoPair => {\n      return 0\n    }\n  }\n  let (left, right) = pair\n  left + right.value\n}\npub fn main() -> I32 {\n  let _fixed_word = fixed_word()\n  let callback = fn(value: I32) -> I32 {\n    value + 1\n  }\n  let named = increment\n  let value = twice(35)\n  choose(add(countdown(2), value - 70)) + invoke(callback, 0) - 1 + invoke(named, 0) - 1 + read_pattern_ref(Some(PatternRefBox::{\n    value: 0\n  })) + push_pattern_scalar([], Some(0)) + read_pair((2, PairBox::{\n    value: 3\n  })) - 5 + read_pair_match(PairChoice::PairValue((2, PairBox::{\n    value: 3\n  }))) - 5 + read_reverse_pair((PairBox::{\n    value: 3\n  }, 2)) - 5 + read_reverse_pair_match(ReversePairChoice::ReversePairValue((PairBox::{\n    value: 3\n  }, 2))) - 5 + read_bytes_pair_match(BytesPairChoice::BytesPairValue((b\"abc\", 2))) - 2\n}\n",
          },
        ],
      },
    ],
    dependency_interfaces: [],
    static_providers: [{ name: "starshine", wasm: provider }],
    standard_library: @compile_request.CompilerBootstrapStandard(
      @compile_request.bootstrap_standard_library_identity(),
    ),
    config: {
      optimization: @compile_request.CompilerOptimized,
      diagnostics: @compile_request.CompilerTextDiagnostics,
      test_mode: false,
      default_preamble: true,
      cache_policy: @compile_request.CompilerCachesDisabled,
      cache_report: false,
    },
    compiler_fingerprint: self_host_smoke_fingerprint(
      fingerprint_prefix, provider,
    ),
  }
  let encoded = match request.encode() {
    Ok(value) => value
    Err(error) => {
      println(error)
      @sys.exit(2)
      b""
    }
  }
  @fs.write_bytes_to_file(args[1], encoded) catch {
    error => {
      println("cannot write self-host smoke request: \{error}")
      @sys.exit(2)
    }
  }
}
