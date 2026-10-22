from pathlib import Path
import os,subprocess
repo=Path('/tmp/wago-gc-deferred-20261022');ev=Path('/tmp/wago-gc-deferred-evidence')
os.chdir(repo)
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOWORK='off',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
def run(label,args,cwd=repo,extra={}):
 print('START',label,flush=True)
 subprocess.run(['python3','/tmp/wago-deferred-run.py',label,*map(str,args)],cwd=cwd,env=dict(env,**extra),check=True)
corpus=repo/'tests/conformance/spec-v3'
assert not list(corpus.iterdir())
corpus.rmdir();corpus.symlink_to('/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago/tests/conformance/spec-v3',target_is_directory=True)
try:
 run('gc-final-padded-wago-build',['go','test','-c','-tags','wago_gc_struct_headers','-o',ev/'final-padded.test','./src/wago'])
 run('gc-final-padded-native',[ev/'final-padded.test','-test.run=^TestGC','-test.count=1','-test.timeout=30s'],repo/'src/wago')
 run('gc-final-arm64-build',['go','test','-c','-o',ev/'final-arm64.test','./src/wago'],extra={'GOOS':'linux','GOARCH':'arm64','CGO_ENABLED':'0'})
 run('gc-final-arm64-native',['qemu-aarch64',ev/'final-arm64.test','-test.run=^TestGC','-test.skip=^TestGCReducedBatchHonorsDeadline$','-test.count=1','-test.timeout=30s'],repo/'src/wago')
 run('gc-final-arm64-guards-build',['go','test','-c','-o',ev/'final-arm64-backend.test','./src/core/compiler/backend/railshot/arm64'],extra={'GOOS':'linux','GOARCH':'arm64','CGO_ENABLED':'0'})
 run('gc-final-arm64-guards',['qemu-aarch64',ev/'final-arm64-backend.test','-test.run=TestGCObject','-test.count=1'],repo/'src/core/compiler/backend/railshot/arm64')
 for target in ['darwin/amd64','darwin/arm64','windows/amd64','windows/arm64','linux/386']:
  goos,goarch=target.split('/')
  run('gc-final-cross-'+goos+'-'+goarch,['go','test','-c','-o',ev/('final-native-'+goos+'-'+goarch+'.test'),'./src/core/runtime/gc/native'],extra={'GOOS':goos,'GOARCH':goarch,'CGO_ENABLED':'0'})
finally:
 corpus.unlink();corpus.mkdir()
