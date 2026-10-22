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
run('leaf-gc-event-default',[go,'test','-p','1','-v','-count=30','-timeout=2m','-exec','/usr/bin/qemu-aarch64','./src/core/runtime','-run','^TestInlineHostBridgeAllowsGCWithLeafCallbacks$'])
env['GOOS']='darwin'
env.pop('GODEBUG',None)
run('darwin-runtime-test-build',[go,'test','-c','-p','1','-o',str(e/'darwin-runtime.test'),'./src/core/runtime'])
env.pop('GOOS',None);env.pop('GOARCH',None)
run('docs-check',[go,'run','./tests/tools/docs-check'])
