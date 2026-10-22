import os,sys,time,json,subprocess,pathlib
label,*cmd=sys.argv[1:]
root=pathlib.Path('/tmp/wago-pr980-linux-leaf-evidence');root.mkdir(exist_ok=True)
started=time.monotonic()
with (root/(label+'.log')).open('w') as log:
 p=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT)
 pid,status,usage=os.wait4(p.pid,0);p.returncode=os.waitstatus_to_exitcode(status)
record={'command':cmd,'seconds':time.monotonic()-started,'exit':p.returncode,'user_seconds':usage.ru_utime,'system_seconds':usage.ru_stime,'peak_rss_kib':usage.ru_maxrss,'minor_faults':usage.ru_minflt,'major_faults':usage.ru_majflt,'voluntary_context_switches':usage.ru_nvcsw,'involuntary_context_switches':usage.ru_nivcsw}
(root/(label+'.json')).write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record));print((root/(label+'.log')).read_text()[-16000:]);sys.exit(p.returncode)
