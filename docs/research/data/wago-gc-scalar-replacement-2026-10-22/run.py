import os,sys,time,json,subprocess,pathlib
label,*cmd=sys.argv[1:];root=pathlib.Path('/tmp/wago-gc-scalar-evidence');root.mkdir(exist_ok=True);started=time.monotonic()
with (root/(label+'.log')).open('w') as log:
 p=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT);pid,status,usage=os.wait4(p.pid,0);p.returncode=os.waitstatus_to_exitcode(status)
record=dict(command=cmd,seconds=time.monotonic()-started,exit=p.returncode,user_seconds=usage.ru_utime,system_seconds=usage.ru_stime,peak_rss_kib=usage.ru_maxrss)
(root/(label+'.json')).write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record));print((root/(label+'.log')).read_text()[-10000:]);sys.exit(p.returncode)
