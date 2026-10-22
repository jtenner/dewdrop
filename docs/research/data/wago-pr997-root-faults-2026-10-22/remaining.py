from pathlib import Path
import subprocess
root=Path('/tmp/wago-pr997-root-faults-evidence')
for args in [('arm.py','arm64-root-final'),('rv.py','rv64-root-final'),('benchmarks.py',),('lint.py',)]:
 subprocess.run(['python3',*(str(root/name) if i==0 else name for i,name in enumerate(args))],cwd=root,check=True)
