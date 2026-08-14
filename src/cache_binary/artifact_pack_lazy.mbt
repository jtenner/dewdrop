///|
fn ArtifactPack::verify_footer(self : ArtifactPack) -> Result[Unit, String] {
  match self.encoded {
    None => Ok(())
    Some(bytes) => {
      if self.footer_covered_bytes < 0 ||
        self.footer_covered_bytes > bytes.length() {
        return Err("artifact pack footer covered range is invalid")
      }
      let covered = artifact_pack_copy_bytes(
        bytes,
        0,
        self.footer_covered_bytes,
      )
      if !artifact_pack_digest_equal(blake3(covered), self.footer_digest) {
        return Err("artifact pack FOOT digest mismatch")
      }
      Ok(())
    }
  }
}

///|
fn ArtifactPack::decode_indexed_entry(
  self : ArtifactPack,
  indexed : ArtifactPackIndexedEntry,
) -> Result[ArtifactPackEntry, String] {
  let bytes = match self.encoded {
    Some(value) => value
    None => return Err("artifact pack indexed bytes are missing")
  }
  if indexed.offset < 0 ||
    indexed.size < artifact_pack_entry_prefix_bytes ||
    indexed.offset + indexed.size < indexed.offset ||
    indexed.offset + indexed.size > bytes.length() {
    return Err("artifact pack indexed entry range is invalid")
  }
  artifact_pack_decode_entry(
    indexed.kind,
    artifact_pack_copy_bytes(bytes, indexed.offset, indexed.size),
    indexed.owner_lane,
    indexed.content_lane,
  )
}

///|
pub fn ArtifactPack::lookup_checked(
  self : ArtifactPack,
  kind : UInt,
  schema_version : UInt,
  owner : String,
  content_digest : FixedArray[Byte],
  context_digest : FixedArray[Byte],
) -> Result[Bytes?, String] {
  let owner_lane = artifact_pack_hash32(blake3(@utf8.encode(owner)))
  let content_lane = artifact_pack_hash32(content_digest)
  for entry in self.entries {
    if entry.kind == kind &&
      entry.schema_version == schema_version &&
      artifact_pack_hash32(blake3(@utf8.encode(entry.owner))) == owner_lane &&
      artifact_pack_hash32(entry.content_digest) == content_lane &&
      entry.owner == owner &&
      artifact_pack_digest_equal(entry.content_digest, content_digest) &&
      artifact_pack_digest_equal(entry.context_digest, context_digest) {
      return Ok(Some(entry.payload))
    }
  }
  for indexed in self.indexed_entries {
    if indexed.kind != kind ||
      indexed.owner_lane != owner_lane ||
      indexed.content_lane != content_lane {
      continue
    }
    let entry = match self.decode_indexed_entry(indexed) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    if entry.schema_version == schema_version &&
      entry.owner == owner &&
      artifact_pack_digest_equal(entry.content_digest, content_digest) &&
      artifact_pack_digest_equal(entry.context_digest, context_digest) {
      self.entries.push(entry)
      return Ok(Some(entry.payload))
    }
  }
  Ok(None)
}

///|
fn ArtifactPack::materialized_entries(
  self : ArtifactPack,
) -> Result[Array[ArtifactPackEntry], String] {
  match self.verify_footer() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let output = self.entries.copy()
  for indexed in self.indexed_entries {
    let entry = match self.decode_indexed_entry(indexed) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    let mut replaced = false
    for existing in output {
      if existing.kind == entry.kind && existing.owner == entry.owner {
        replaced = true
        break
      }
    }
    if !replaced {
      output.push(entry)
    }
  }
  output.sort_by(artifact_pack_entry_compare)
  for index in 1..<output.length() {
    if output[index - 1].kind == output[index].kind &&
      output[index - 1].owner == output[index].owner {
      return Err("artifact pack contains duplicate section owners")
    }
  }
  Ok(output)
}

///|
/// Opens only the aligned section and entry indexes. Entry payloads are decoded
/// and checked only when selected. This keeps exact warm hits independent of the
/// number of cached modules.
pub fn open_artifact_pack(bytes : Bytes) -> Result[ArtifactPack, String] {
  let reader = Reader::new(bytes, context="artifact_pack")
  let magic = reader.read_raw_bytes(16, 16, "magic")
  if magic != artifact_pack_magic {
    return Err("artifact pack magic is unsupported")
  }
  let indexed_entries : Array[ArtifactPackIndexedEntry] = []
  let mut previous_kind = 0U
  let mut has_previous_kind = false
  let mut section_count = 0
  let mut saw_footer = false
  let mut footer_covered_bytes = 0
  let mut footer_digest = artifact_pack_zero_digest()
  while reader.remaining() > 0 {
    let section_start = reader.position()
    if section_start % 16 != 0 || reader.remaining() < 16 {
      return Err("artifact pack section header is unaligned or truncated")
    }
    let kind = reader.read_u32_le("section.kind")
    let section_size = reader.read_u32_le("section.size").reinterpret_as_int()
    let entry_count_u64 = reader.read_u64_le("section.entry_count")
    if section_size < 0 ||
      section_size % 16 != 0 ||
      section_size > reader.remaining() ||
      entry_count_u64 > artifact_pack_maximum_entries.to_uint64() {
      return Err("artifact pack section size or entry count is invalid")
    }
    let entry_count = entry_count_u64.to_int()
    if entry_count * 16 > section_size {
      return Err("artifact pack entry headers exceed section size")
    }
    if kind == artifact_pack_footer_kind {
      if saw_footer {
        return Err("artifact pack contains duplicate FOOT sections")
      }
    } else {
      if saw_footer || (has_previous_kind && kind <= previous_kind) {
        return Err("artifact pack sections are unordered or follow FOOT")
      }
      previous_kind = kind
      has_previous_kind = true
    }
    let owner_lanes : Array[UInt] = []
    let content_lanes : Array[UInt] = []
    let entry_sizes : Array[Int] = []
    let mut prior_owner_lane = 0U
    let mut prior_content_lane = 0U
    for entry_index in 0..<entry_count {
      let owner_lane = reader.read_u32_le("entry.owner_hash32")
      let content_lane = reader.read_u32_le("entry.content_hash32")
      let size = reader.read_u64_le("entry.size")
      if size > maximum_blob_bytes.to_uint64() {
        return Err("artifact pack entry size exceeds limit")
      }
      if entry_index > 0 &&
        (
          owner_lane < prior_owner_lane ||
          (owner_lane == prior_owner_lane && content_lane < prior_content_lane)
        ) {
        return Err("artifact pack entry headers are unordered")
      }
      prior_owner_lane = owner_lane
      prior_content_lane = content_lane
      owner_lanes.push(owner_lane)
      content_lanes.push(content_lane)
      entry_sizes.push(size.to_int())
    }
    let section_end = section_start + 16 + section_size
    let section_indexes : Array[ArtifactPackIndexedEntry] = []
    for entry_index in 0..<entry_count {
      if reader.position() % 16 != 0 {
        return Err("artifact pack entry payload is unaligned")
      }
      let size = entry_sizes[entry_index]
      if size < artifact_pack_entry_prefix_bytes ||
        reader.position() + size > section_end {
        return Err("artifact pack entry payload range is invalid")
      }
      section_indexes.push({
        kind,
        owner_lane: owner_lanes[entry_index],
        content_lane: content_lanes[entry_index],
        offset: reader.position(),
        size,
      })
      reader.skip(size, "entry.payload")
      while reader.position() % 16 != 0 {
        if reader.read_byte("entry.padding") != 0 {
          return Err("artifact pack entry has nonzero alignment padding")
        }
      }
    }
    if reader.position() != section_end {
      return Err("artifact pack section size does not match its entries")
    }
    section_count += 1
    if kind == artifact_pack_footer_kind {
      if entry_count != 1 {
        return Err("artifact pack FOOT section must contain one entry")
      }
      let footer = match
        artifact_pack_decode_entry(
          kind,
          artifact_pack_copy_bytes(
            bytes,
            section_indexes[0].offset,
            section_indexes[0].size,
          ),
          section_indexes[0].owner_lane,
          section_indexes[0].content_lane,
        ) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      if footer.schema_version != 1U || footer.payload.length() != 64 {
        return Err("artifact pack FOOT payload is invalid")
      }
      let footer_reader = Reader::new(
        footer.payload,
        context="artifact_pack.footer",
      )
      let total_size = footer_reader.read_u64_le("total_size")
      let covered_bytes = footer_reader.read_u64_le("covered_bytes")
      let expected_sections = footer_reader.read_u64_le("section_count")
      if footer_reader.read_u64_le("reserved") != 0UL {
        return Err("artifact pack FOOT reserved field is nonzero")
      }
      let expected_digest = artifact_pack_read_digest(footer_reader, "digest")
      match footer_reader.finish() {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
      if total_size != bytes.length().to_uint64() ||
        covered_bytes != section_start.to_uint64() ||
        expected_sections != section_count.to_uint64() ||
        !artifact_pack_digest_equal(footer.content_digest, expected_digest) {
        return Err("artifact pack FOOT metadata mismatch")
      }
      footer_covered_bytes = section_start
      footer_digest = expected_digest
      saw_footer = true
    } else {
      for indexed in section_indexes {
        indexed_entries.push(indexed)
      }
    }
  }
  match reader.finish() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  if !saw_footer {
    return Err("artifact pack FOOT section is missing")
  }
  Ok({
    entries: [],
    indexed_entries,
    encoded: Some(bytes),
    footer_covered_bytes,
    footer_digest,
  })
}
