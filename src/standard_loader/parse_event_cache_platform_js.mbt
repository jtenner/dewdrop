///|
fn cache_platform_supported() -> Bool {
  true
}

///|
extern "js" fn cache_platform_atomic_write(
  path : Bytes,
  path_length : Int,
  content : Bytes,
) -> Int =
  #| function(path, pathLength, content) {
  #|   const fs = require('fs');
  #|   const destination = Buffer.from(path)
  #|     .subarray(0, pathLength)
  #|     .toString('utf8');
  #|   const counter = (globalThis.dewdropAtomicWriteCounter || 0) + 1;
  #|   globalThis.dewdropAtomicWriteCounter = counter;
  #|   const temporary = `${destination}.tmp-${process.pid}-${counter}`;
  #|   let descriptor;
  #|   try {
  #|     descriptor = fs.openSync(temporary, 'w');
  #|     fs.writeFileSync(descriptor, Buffer.from(content));
  #|     fs.fsyncSync(descriptor);
  #|     fs.closeSync(descriptor);
  #|     descriptor = undefined;
  #|     fs.renameSync(temporary, destination);
  #|     return 0;
  #|   } catch (error) {
  #|     if (descriptor !== undefined) {
  #|       try { fs.closeSync(descriptor); } catch (_) {}
  #|     }
  #|     try { fs.unlinkSync(temporary); } catch (_) {}
  #|     return Number.isInteger(error.errno) && error.errno < 0
  #|       ? error.errno
  #|       : -5;
  #|   }
  #| }
