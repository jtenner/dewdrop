from pathlib import Path
import subprocess
root=Path('/tmp/wago-pr997-root-faults-evidence')
subprocess.run(['python3',str(root/'host-guard.py')],cwd=root,check=True)
s=(root/'full-checks.py').read_text()
a=s.index(" run('normal-root-v2'");b=s.index('\nfinally:',a)
s=s[:a]+''' run('publish-normal-wago',[e/'candidate-host.test','-test.count=1'],r/'src/wago')
 run('publish-checked-wago',[go,'test','-p','2','-count=1','-tags=wago_regalloccheck','./src/wago','./tests/integration/runtimeconcurrency'])'''+s[b:]
exec(s)
subprocess.run(['python3',str(root/'arm.py'),'arm64-publish'],cwd=root,check=True)
