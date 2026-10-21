from pathlib import Path
import shutil,subprocess,time
r=Path('/tmp/wago-four-seconds/segment');src=r/'source-slots512';host=r/'host-source-slots512'
if not src.exists():shutil.copytree(r/'source',src,symlinks=True)
p=src/'src/core/runtime/gc/native/native_read_cache.go';s=p.read_text().replace('NativeReadCacheSlots = 128','NativeReadCacheSlots = 512');assert s!=p.read_text();p.write_text(s)
p=src/'src/core/compiler/backend/railshot/amd64/gc_native_read_cache.go';s=p.read_text().replace('R10, 254, false','R10, 1022, false');assert s!=p.read_text();p.write_text(s)
if not host.exists():shutil.copytree(r/'host-source',host)
p=host/'go.mod';p.write_text(p.read_text().replace(str(r/'source'),str(src)))
t=time.monotonic();subprocess.run(['go','build','-mod=mod','-ldflags=-X main.runtimePatchIdentity=segment-cache-slots512','-o',str(r/'host-slots512'),'.'],cwd=host,check=True);print('elapsed',time.monotonic()-t)
