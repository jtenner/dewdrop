///|
pub fn standard_bloom_filter_source() -> Bytes {
  b"pub type BloomFilter = U64\n\npub fn bloom_filter_hash_mask(hash: U64) -> U64 {\n  (1u64 << (hash & 63u64)) | (1u64 << ((hash >> 32u64) & 63u64))\n}\n\nimpl BloomFilter {\n  fn empty() -> BloomFilter {\n    0u64\n  }\n  fn is_empty(self) -> Bool {\n    self == 0u64\n  }\n  fn add_hash(self, hash: U64) -> BloomFilter {\n    self | bloom_filter_hash_mask(hash)\n  }\n  fn maybe_contains_hash(self, hash: U64) -> Bool {\n    let mask = bloom_filter_hash_mask(hash)\n    (self & mask) == mask\n  }\n  fn add<t: Hash>(self, value: t) -> BloomFilter {\n    self.add_hash(value.hash())\n  }\n  fn maybe_contains<t: Hash>(self, value: t) -> Bool {\n    self.maybe_contains_hash(value.hash())\n  }\n}\n"
}
