///|
let parse_event_f32_bits_key = "$dew-f32-bits"

///|
fn parse_event_json_preserve_float_bits(value : Json) -> Json {
  match value {
    Array(values) => {
      let output : Array[Json] = []
      for item in values {
        output.push(parse_event_json_preserve_float_bits(item))
      }
      Json::array(output)
    }
    Object(values) => {
      let output : Map[String, Json] = Map::default()
      for key, item in values {
        output[key] = parse_event_json_preserve_float_bits(item)
      }
      Json::object(output)
    }
    Number(number, ..) =>
      if number.is_nan() ||
        number > @double.max_value ||
        number < -@double.max_value {
        let bits = Float::from_double(number).reinterpret_as_uint()
        let encoded : Map[String, Json] = Map::default()
        encoded[parse_event_f32_bits_key] = Json::string(bits.to_string())
        Json::object(encoded)
      } else {
        value
      }
    _ => value
  }
}

///|
fn parse_event_json_restore_float_bits(value : Json) -> Result[Json, String] {
  match value {
    Array(values) => {
      let output : Array[Json] = []
      for item in values {
        match parse_event_json_restore_float_bits(item) {
          Ok(decoded) => output.push(decoded)
          Err(error) => return Err(error)
        }
      }
      Ok(Json::array(output))
    }
    Object(values) =>
      if values.length() == 1 && values.contains(parse_event_f32_bits_key) {
        match values.get(parse_event_f32_bits_key) {
          Some(String(text)) => {
            let bits : UInt = @strconv.from_str(text) catch {
              _ => return Err("invalid cached F32 bit pattern")
            }
            Ok(Json::number(Float::reinterpret_from_uint(bits).to_double()))
          }
          _ => Err("invalid cached F32 bit marker")
        }
      } else {
        let output : Map[String, Json] = Map::default()
        for key, item in values {
          match parse_event_json_restore_float_bits(item) {
            Ok(decoded) => output[key] = decoded
            Err(error) => return Err(error)
          }
        }
        Ok(Json::object(output))
      }
    _ => Ok(value)
  }
}

///|
/// Encodes a complete module-scope parser event stream into deterministic JSON
/// payload bytes. The persistent cache envelope owns versioning, checksums, and
/// source provenance; this payload owns only lossless syntax data.
pub fn serialize_parse_events(
  events : Array[ParseEvent],
) -> Result[Bytes, String] {
  let json = parse_event_json_preserve_float_bits(events.to_json())
  Ok(@utf8.encode(json.stringify()))
}

///|
/// Decodes parser events from a previously validated artifact payload.
pub fn deserialize_parse_events(
  payload : Bytes,
) -> Result[Array[ParseEvent], String] {
  let text = @utf8.decode(payload) catch {
    _ => return Err("parse-event payload is not UTF-8")
  }
  let json = @json.parse(text) catch {
    error => return Err("parse-event payload is not valid JSON: \{error}")
  }
  let restored = match parse_event_json_restore_float_bits(json) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let events : Array[ParseEvent] = @json.from_json(restored) catch {
    error => return Err("parse-event payload schema mismatch: \{error}")
  }
  Ok(events)
}
