///|
let artifact_pack_magic : Bytes = b"dewartv1\x00\x00\x00\x00\x00\x00\x00\x00"

///|
let artifact_pack_entry_prefix_bytes = 144

///|
let artifact_pack_footer_kind = 0x544f4f46U

///|
let artifact_pack_maximum_entries = 0x00100000

///|
pub struct ArtifactPackEntry {
  kind : UInt
  schema_version : UInt
  flags : UInt
  owner_kind : UInt
  owner : String
  content_digest : FixedArray[Byte]
  context_digest : FixedArray[Byte]
  payload : Bytes
} derive(Eq, Debug)

///|
struct ArtifactPackIndexedEntry {
  kind : UInt
  owner_lane : UInt
  content_lane : UInt
  offset : Int
  size : Int
} derive(Eq, Debug)

///|
pub struct ArtifactPack {
  entries : Array[ArtifactPackEntry]
  indexed_entries : Array[ArtifactPackIndexedEntry]
  encoded : Bytes?
  footer_covered_bytes : Int
  footer_digest : FixedArray[Byte]
} derive(Eq, Debug)

///|
pub fn ArtifactPackEntry::new(
  kind : UInt,
  schema_version : UInt,
  flags : UInt,
  owner_kind : UInt,
  owner : String,
  content_digest : FixedArray[Byte],
  context_digest : FixedArray[Byte],
  payload : Bytes,
) -> ArtifactPackEntry {
  {
    kind,
    schema_version,
    flags,
    owner_kind,
    owner,
    content_digest,
    context_digest,
    payload,
  }
}

///|
pub fn ArtifactPack::empty() -> ArtifactPack {
  {
    entries: [],
    indexed_entries: [],
    encoded: None,
    footer_covered_bytes: 0,
    footer_digest: artifact_pack_zero_digest(),
  }
}

///|
fn artifact_pack_digest_equal(
  left : FixedArray[Byte],
  right : FixedArray[Byte],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}

///|
fn artifact_pack_validate_digest(
  digest : FixedArray[Byte],
  field : String,
) -> Result[Unit, String] {
  if digest.length() != 32 {
    Err("artifact pack \{field} must be a 32-byte BLAKE3 digest")
  } else {
    Ok(())
  }
}

///|
fn artifact_pack_hash32(digest : FixedArray[Byte]) -> UInt {
  digest[0].to_uint() |
  (digest[1].to_uint() << 8) |
  (digest[2].to_uint() << 16) |
  (digest[3].to_uint() << 24)
}

///|
fn artifact_pack_align16(value : Int) -> Int {
  (value + 15) & -16
}

///|
fn artifact_pack_write_u16(writer : Writer, value : UInt) -> Unit {
  writer.write_byte((value & 0xffU).to_byte())
  writer.write_byte(((value >> 8) & 0xffU).to_byte())
}

///|
fn artifact_pack_write_digest(
  writer : Writer,
  digest : FixedArray[Byte],
) -> Unit {
  for byte in digest {
    writer.write_byte(byte)
  }
}

///|
fn artifact_pack_zero_digest() -> FixedArray[Byte] {
  FixedArray::make(32, (0 : Byte))
}

///|
fn artifact_pack_copy_bytes(bytes : Bytes, start : Int, length : Int) -> Bytes {
  let output = Buffer(size_hint=length)
  for index in 0..<length {
    output.write_byte(bytes[start + index])
  }
  output.to_bytes()
}

///|
fn artifact_pack_digest_from_bytes(bytes : Bytes) -> FixedArray[Byte] {
  let output = FixedArray::make(32, (0 : Byte))
  for index in 0..<32 {
    output[index] = bytes[index]
  }
  output
}

///|
fn artifact_pack_compare_digest(
  left : FixedArray[Byte],
  right : FixedArray[Byte],
) -> Int {
  for index in 0..<32 {
    let compared = left[index].compare(right[index])
    if compared != 0 {
      return compared
    }
  }
  0
}

///|
fn artifact_pack_entry_compare(
  left : ArtifactPackEntry,
  right : ArtifactPackEntry,
) -> Int {
  let kind = left.kind.compare(right.kind)
  if kind != 0 {
    return kind
  }
  let left_owner = blake3(@utf8.encode(left.owner))
  let right_owner = blake3(@utf8.encode(right.owner))
  let owner_lane = artifact_pack_hash32(left_owner).compare(
    artifact_pack_hash32(right_owner),
  )
  if owner_lane != 0 {
    return owner_lane
  }
  let content_lane = artifact_pack_hash32(left.content_digest).compare(
    artifact_pack_hash32(right.content_digest),
  )
  if content_lane != 0 {
    return content_lane
  }
  let owner = left.owner.compare(right.owner)
  if owner != 0 {
    return owner
  }
  let content = artifact_pack_compare_digest(
    left.content_digest,
    right.content_digest,
  )
  if content != 0 {
    return content
  }
  artifact_pack_compare_digest(left.context_digest, right.context_digest)
}

///|
pub fn ArtifactPack::lookup(
  self : ArtifactPack,
  kind : UInt,
  schema_version : UInt,
  owner : String,
  content_digest : FixedArray[Byte],
  context_digest : FixedArray[Byte],
) -> Bytes? {
  match
    self.lookup_checked(
      kind, schema_version, owner, content_digest, context_digest,
    ) {
    Ok(value) => value
    Err(_) => None
  }
}

///|
pub fn ArtifactPack::upsert(
  self : ArtifactPack,
  entry : ArtifactPackEntry,
) -> Result[Unit, String] {
  if entry.kind == artifact_pack_footer_kind {
    return Err("artifact pack FOOT entries are reserved")
  }
  if entry.schema_version > 0xffffU || entry.flags > 0xffffU {
    return Err("artifact pack entry schema or flags exceed U16")
  }
  match artifact_pack_validate_digest(entry.content_digest, "content digest") {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match artifact_pack_validate_digest(entry.context_digest, "context digest") {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  for index, existing in self.entries {
    if existing.kind == entry.kind && existing.owner == entry.owner {
      self.entries[index] = entry
      return Ok(())
    }
  }
  self.entries.push(entry)
  Ok(())
}

///|
fn artifact_pack_encoded_entry(
  entry : ArtifactPackEntry,
) -> Result[Bytes, String] {
  let owner = @utf8.encode(entry.owner)
  let root_offset = artifact_pack_align16(
    artifact_pack_entry_prefix_bytes + owner.length(),
  )
  if root_offset < artifact_pack_entry_prefix_bytes ||
    root_offset + entry.payload.length() > maximum_blob_bytes {
    return Err("artifact pack entry exceeds the maximum payload size")
  }
  let writer = Writer::new(size_hint=root_offset + entry.payload.length())
  artifact_pack_write_u16(writer, entry.schema_version)
  artifact_pack_write_u16(writer, entry.flags)
  writer.write_u32_le(entry.owner_kind)
  writer.write_u32_le(owner.length().reinterpret_as_uint())
  writer.write_u32_le(root_offset.reinterpret_as_uint())
  artifact_pack_write_digest(writer, blake3(owner))
  artifact_pack_write_digest(writer, entry.content_digest)
  artifact_pack_write_digest(writer, entry.context_digest)
  artifact_pack_write_digest(writer, blake3(entry.payload))
  writer.write_raw(owner)
  while writer.length() < root_offset {
    writer.write_byte(0)
  }
  writer.write_raw(entry.payload)
  Ok(writer.to_bytes())
}

///|
fn artifact_pack_write_section(
  output : Writer,
  kind : UInt,
  entries : Array[ArtifactPackEntry],
) -> Result[Unit, String] {
  let encoded : Array[Bytes] = []
  let mut section_size = entries.length() * 16
  for entry in entries {
    let value = match artifact_pack_encoded_entry(entry) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    encoded.push(value)
    section_size += artifact_pack_align16(value.length())
  }
  if section_size < 0 || section_size.to_uint64() > 0xffffffffUL {
    return Err("artifact pack section exceeds U32 size")
  }
  output.write_u32_le(kind)
  output.write_u32_le(section_size.reinterpret_as_uint())
  output.write_u64_le(entries.length().to_uint64())
  for index, entry in entries {
    let owner_digest = blake3(@utf8.encode(entry.owner))
    output.write_u32_le(artifact_pack_hash32(owner_digest))
    output.write_u32_le(artifact_pack_hash32(entry.content_digest))
    output.write_u64_le(encoded[index].length().to_uint64())
  }
  for value in encoded {
    output.write_raw(value)
    while output.length() % 16 != 0 {
      output.write_byte(0)
    }
  }
  Ok(())
}

///|
fn artifact_pack_footer_entry(
  total_size : Int,
  covered_bytes : Int,
  section_count : Int,
  digest : FixedArray[Byte],
) -> ArtifactPackEntry {
  let payload = Writer::new(size_hint=64)
  payload.write_u64_le(total_size.to_uint64())
  payload.write_u64_le(covered_bytes.to_uint64())
  payload.write_u64_le(section_count.to_uint64())
  payload.write_u64_le(0UL)
  artifact_pack_write_digest(payload, digest)
  {
    kind: artifact_pack_footer_kind,
    schema_version: 1U,
    flags: 0U,
    owner_kind: 3U,
    owner: "pack",
    content_digest: digest,
    context_digest: artifact_pack_zero_digest(),
    payload: payload.to_bytes(),
  }
}

///|
pub fn ArtifactPack::encode(self : ArtifactPack) -> Result[Bytes, String] {
  if self.entries.length() > artifact_pack_maximum_entries {
    return Err("artifact pack entry count exceeds limit")
  }
  let entries = match self.materialized_entries() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  entries.sort_by(artifact_pack_entry_compare)
  let output = Writer::new(size_hint=4096)
  output.write_raw(artifact_pack_magic)
  let mut section_count = 0
  let mut index = 0
  while index < entries.length() {
    let kind = entries[index].kind
    let section : Array[ArtifactPackEntry] = []
    while index < entries.length() && entries[index].kind == kind {
      section.push(entries[index])
      index += 1
    }
    match artifact_pack_write_section(output, kind, section) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    section_count += 1
  }
  let covered_bytes = output.length()
  let digest = blake3(output.to_bytes())
  let footer_payload_size = artifact_pack_align16(
      artifact_pack_entry_prefix_bytes + 4,
    ) +
    64
  let footer_section_size = 16 + artifact_pack_align16(footer_payload_size)
  let total_size = covered_bytes + 16 + footer_section_size
  let footer = artifact_pack_footer_entry(
    total_size,
    covered_bytes,
    section_count + 1,
    digest,
  )
  match
    artifact_pack_write_section(output, artifact_pack_footer_kind, [footer]) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  if output.length() != total_size {
    return Err("artifact pack footer size calculation mismatch")
  }
  Ok(output.to_bytes())
}

///|
fn artifact_pack_read_u16(reader : Reader, field : String) -> UInt {
  reader.read_byte(field).to_uint() | (reader.read_byte(field).to_uint() << 8)
}

///|
fn artifact_pack_read_digest(
  reader : Reader,
  field : String,
) -> FixedArray[Byte] {
  let bytes = reader.read_raw_bytes(32, 32, field)
  if bytes.length() != 32 {
    return artifact_pack_zero_digest()
  }
  artifact_pack_digest_from_bytes(bytes)
}

///|
fn artifact_pack_decode_entry(
  kind : UInt,
  encoded : Bytes,
  expected_owner_lane : UInt,
  expected_content_lane : UInt,
) -> Result[ArtifactPackEntry, String] {
  if encoded.length() < artifact_pack_entry_prefix_bytes {
    return Err("artifact pack entry prefix is truncated")
  }
  let reader = Reader::new(encoded, context="artifact_pack.entry")
  let schema_version = artifact_pack_read_u16(reader, "schema_version")
  let flags = artifact_pack_read_u16(reader, "flags")
  let owner_kind = reader.read_u32_le("owner_kind")
  let owner_length = reader.read_u32_le("owner_length").reinterpret_as_int()
  let root_offset = reader.read_u32_le("root_offset").reinterpret_as_int()
  let owner_digest = artifact_pack_read_digest(reader, "owner_digest")
  let content_digest = artifact_pack_read_digest(reader, "content_digest")
  let context_digest = artifact_pack_read_digest(reader, "context_digest")
  let payload_digest = artifact_pack_read_digest(reader, "payload_digest")
  if owner_length < 0 ||
    root_offset < artifact_pack_entry_prefix_bytes ||
    root_offset % 16 != 0 ||
    artifact_pack_entry_prefix_bytes + owner_length > root_offset ||
    root_offset > encoded.length() {
    return Err("artifact pack entry owner or root range is invalid")
  }
  let owner_bytes = reader.read_raw_bytes(
    owner_length, maximum_blob_bytes, "owner",
  )
  while reader.position() < root_offset {
    if reader.read_byte("owner_padding") != 0 {
      return Err("artifact pack entry has nonzero owner padding")
    }
  }
  let payload = reader.read_raw_bytes(
    encoded.length() - root_offset,
    maximum_blob_bytes,
    "payload",
  )
  match reader.finish() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let owner = @utf8.decode(owner_bytes) catch {
    _ => return Err("artifact pack entry owner is not UTF-8")
  }
  if !artifact_pack_digest_equal(blake3(owner_bytes), owner_digest) ||
    artifact_pack_hash32(owner_digest) != expected_owner_lane {
    return Err("artifact pack entry owner digest mismatch")
  }
  if artifact_pack_hash32(content_digest) != expected_content_lane {
    return Err("artifact pack entry content digest lane mismatch")
  }
  if !artifact_pack_digest_equal(blake3(payload), payload_digest) {
    return Err("artifact pack entry payload digest mismatch")
  }
  Ok({
    kind,
    schema_version,
    flags,
    owner_kind,
    owner,
    content_digest,
    context_digest,
    payload,
  })
}

///|
pub fn decode_artifact_pack(bytes : Bytes) -> Result[ArtifactPack, String] {
  let reader = Reader::new(bytes, context="artifact_pack")
  let magic = reader.read_raw_bytes(16, 16, "magic")
  if magic != artifact_pack_magic {
    return Err("artifact pack magic is unsupported")
  }
  let entries : Array[ArtifactPackEntry] = []
  let mut previous_kind = 0U
  let mut has_previous_kind = false
  let mut section_count = 0
  let mut saw_footer = false
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
    for _ in 0..<entry_count {
      owner_lanes.push(reader.read_u32_le("entry.owner_hash32"))
      content_lanes.push(reader.read_u32_le("entry.content_hash32"))
      let size = reader.read_u64_le("entry.size")
      if size > maximum_blob_bytes.to_uint64() {
        return Err("artifact pack entry size exceeds limit")
      }
      entry_sizes.push(size.to_int())
    }
    let payload_start = reader.position()
    let section_end = section_start + 16 + section_size
    let decoded : Array[ArtifactPackEntry] = []
    for entry_index in 0..<entry_count {
      if reader.position() % 16 != 0 {
        return Err("artifact pack entry payload is unaligned")
      }
      let size = entry_sizes[entry_index]
      if size < artifact_pack_entry_prefix_bytes ||
        reader.position() + size > section_end {
        return Err("artifact pack entry payload range is invalid")
      }
      let encoded = reader.read_raw_bytes(
        size, maximum_blob_bytes, "entry.payload",
      )
      let entry = match
        artifact_pack_decode_entry(
          kind,
          encoded,
          owner_lanes[entry_index],
          content_lanes[entry_index],
        ) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      decoded.push(entry)
      while reader.position() % 16 != 0 {
        if reader.read_byte("entry.padding") != 0 {
          return Err("artifact pack entry has nonzero alignment padding")
        }
      }
    }
    ignore(payload_start)
    if reader.position() != section_end {
      return Err("artifact pack section size does not match its entries")
    }
    section_count += 1
    if kind == artifact_pack_footer_kind {
      if entry_count != 1 || decoded.length() != 1 {
        return Err("artifact pack FOOT section must contain one entry")
      }
      let footer = decoded[0]
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
        expected_sections != section_count.to_uint64() {
        return Err("artifact pack FOOT size or section count mismatch")
      }
      let covered = artifact_pack_copy_bytes(bytes, 0, section_start)
      if !artifact_pack_digest_equal(blake3(covered), expected_digest) ||
        !artifact_pack_digest_equal(footer.content_digest, expected_digest) {
        return Err("artifact pack FOOT digest mismatch")
      }
      saw_footer = true
    } else {
      for entry in decoded {
        entries.push(entry)
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
  let ordered = entries.copy()
  ordered.sort_by(artifact_pack_entry_compare)
  if ordered != entries {
    return Err("artifact pack entries are not canonical")
  }
  for index in 1..<entries.length() {
    if entries[index - 1].kind == entries[index].kind &&
      entries[index - 1].owner == entries[index].owner {
      return Err("artifact pack contains duplicate section owners")
    }
  }
  Ok({
    entries,
    indexed_entries: [],
    encoded: None,
    footer_covered_bytes: 0,
    footer_digest: artifact_pack_zero_digest(),
  })
}
