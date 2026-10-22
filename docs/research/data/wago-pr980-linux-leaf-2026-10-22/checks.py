from pathlib import Path
import os, subprocess
r=Path('/tmp/wago-pr980-ci-fix');e=Path('/tmp/wago-pr980-linux-leaf-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',GOOS='linux',GOARCH='arm64',CGO_ENABLED='0',GODEBUG='asyncpreemptoff=1')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
def run(label,args,expected=0):
 print('START',label,flush=True)
 p=subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=r,env=env)
 assert p.returncode==expected,(label,p.returncode,expected)
# Disable only the production yield macro for a negative control. Restore it
# after the build so no injected assembly change enters the final patch.
h=r/'src/core/runtime/inline_host_yield_arm64.h'; original=h.read_bytes()
try:
 h.write_text('#define INLINE_HOST_YIELD_INIT(counter)\n#define INLINE_HOST_YIELD(counter, done, abort, trapOffset, ctrlOffset)\n')
 run('yield-disabled-build',[go,'test','-c','-p','1','-o',str(e/'yield-disabled.test'),'./src/core/runtime'])
finally:
 h.write_bytes(original)
run('yield-disabled-scalar',['/usr/bin/qemu-aarch64',str(e/'yield-disabled.test'),'-test.v','-test.count=1','-test.timeout=45s','-test.run=^TestInlineHostBridgeAllowsGCWithLeafCallbacks$/^scalar$'],1)
run('leaf-gc-event-checked',[go,'test','-p','1','-v','-count=30','-timeout=2m','-tags=wago_regalloccheck,wago_inline_host_experiment','-exec','/usr/bin/qemu-aarch64','./src/core/runtime','-run','Test(InlineHostBridge|InlineBoundedBridge|LiveBounded|BoundedHelper)'])
