from pathlib import Path
import os,subprocess,sys
r=Path('/tmp/wago-pr997-root-faults-20261022');e=Path('/tmp/wago-pr997-root-faults-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2')
env.pop('GOWORK',None)
env.update(GOOS='linux',GOARCH='arm64',CGO_ENABLED='0')
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:'+env['PATH']
label=sys.argv[1]
p=subprocess.run(['python3',str(e/'measure.py'),label,go,'test','-p','1','-v','-count=3','-timeout=2m','-tags=wago_regalloccheck','-exec','/usr/bin/qemu-aarch64','./src/wago','-run','Test(CachedBoundedNumericEntry|DetachedNumeric|RuntimeConcurrencyHarness|NativeScalarLeafShortEntry|PluginScalarHostImportStaysOrdinary|GCScalarAdapter|GCCollectorFreeReturnMaps|GCExtern|GCNativeFrameOwner|GCNativeFrameRoots|GCSingleNativeFrameRoots)'],cwd=r,env=env)
sys.exit(p.returncode)
