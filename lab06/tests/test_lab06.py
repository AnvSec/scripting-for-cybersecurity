#!/usr/bin/env python3
"""Run from any directory with Python 3 on Linux. Fixtures are temporary."""
from pathlib import Path
from collections import Counter
import os, re, subprocess, tempfile, hashlib
P = Path(__file__).resolve().parents[1]
rows = []
def check(name, condition):
    rows.append(('PASS' if condition else 'FAIL') + ' ' + name)
    if not condition:
        raise AssertionError(name)
def run(script, *args, data='', cwd=P, user=None):
    opts = {} if user is None else {'user':user, 'group':user}
    return subprocess.run(['bash',str(P/script),*map(str,args)],input=data,
                          text=True,capture_output=True,cwd=cwd,timeout=10,**opts)
def command(*args, cwd=P):
    return subprocess.run(args,text=True,capture_output=True,cwd=cwd,timeout=10)
def error(name, result, code):
    check(name, result.returncode == code and bool(result.stderr) and not result.stdout)
def main():
    evidence = list((P/'case').rglob('*')) + list((P/'intel').rglob('*'))
    hashes = {f:hashlib.sha256(f.read_bytes()).hexdigest() for f in evidence if f.is_file()}
    for f in sorted(P.glob('*.sh')):
        check('syntax '+f.name, command('bash','-n',str(f)).returncode == 0)
    auth=(P/'case/logs/auth.log').read_text().splitlines()
    failed=[s for s in auth if 'Failed password' in s]
    ips=Counter(re.search(r' from (\S+)',s)[1] for s in failed)
    users=Counter(re.search(r'Failed password for (?:invalid user )?(\S+)',s)[1] for s in failed)
    check('independent supplied SSH totals',len(auth)==60 and len(failed)==45)
    r=run('attacker_report.sh','case/logs/auth.log')
    check('SSH report success',r.returncode==0 and not r.stderr)
    check('SSH report counts and ranking',all(re.search(rf'^\s*{count}\s+{re.escape(ip)}$',r.stdout,re.M) for ip,count in ips.most_common(3)) and 'Failed password events: 45' in r.stdout and 'source: 203.0.113.10' in r.stdout)
    check('SSH report username counts',all(re.search(rf'^\s*{count}\s+{name}$',r.stdout,re.M) for name,count in users.most_common(3)))
    r=run('attacker_report.sh','case/logs/access.log')
    check('web report zero events and no invented attacker',r.returncode==0 and 'events: 0' in r.stdout and 'source: None' in r.stdout and 'does not rule out' in r.stdout)
    for name in ['auth.log','access.log','firewall.log']:
        rel='case/logs/'+name; b=(P/rel).read_bytes(); r=run('logstats.sh',rel,data='\n')
        check('statistics '+name,r.returncode==0 and not r.stderr and f'Total lines     : {b.count(bytes([10]))}' in r.stdout and f'Total words     : {len(b.split())}' in r.stdout and f'Total bytes     : {len(b)}' in r.stdout and f'Longest line    : {max(map(len,b.splitlines()))} characters' in r.stdout and 'First line      : '+b.splitlines()[0].decode() in r.stdout and 'Last line       : '+b.splitlines()[-1].decode() in r.stdout)
    for rel in ['intel/users.csv','intel/iocs.txt']:
        check('statistics '+rel,run('logstats.sh',rel).returncode==0)
    for keyword in ['Failed','Accepted','root','198.51.100.77']:
        expected=sum(bool(re.search(keyword,s)) for s in auth)
        r=run('logstats.sh','case/logs/auth.log',data=keyword+'\n')
        check('keyword '+keyword,r.returncode==0 and f"Lines containing '{keyword}': {expected}" in r.stdout)
    r=run('logstats.sh','case/logs/access.log',data='sqlmap\n')
    check('sqlmap keyword and grep status',r.returncode==0 and "'sqlmap': 22" in r.stdout and 'grep exit code: 0' in r.stdout)
    r=run('logstats.sh','case/logs/auth.log',data='NEVER_PRESENT_TEST_KEYWORD\n')
    check('no matches is not a script error',r.returncode==0 and 'grep exit code: 1' in r.stdout and 'No matches found.' in r.stdout)
    r=run('logstats.sh','case/logs/auth.log',data='[\n')
    check('invalid regex returns nonzero and stderr',r.returncode==4 and bool(r.stderr) and 'grep exit code: 2' in r.stdout)
    for script in ['logstats.sh','attacker_report.sh','validate_file.sh']:
        error(script+' missing argument',run(script),1)
        error(script+' too many arguments',run(script,'a','b'),1)
        error(script+' missing file',run(script,'missing-test-file'),2)
        error(script+' directory',run(script,'case'),2)
    error('top3 missing file',run('top3.sh','missing-test-file'),2)
    error('top3 extra arguments',run('top3.sh','a','b'),1)
    check('top3 default equals explicit path',run('top3.sh').stdout==run('top3.sh','case/logs/auth.log').stdout)
    check('check_file success',run('check_file.sh').returncode==0)
    error('check_file from case has wrong relative path',run('check_file.sh',cwd=P/'case'),1)
    check('validate_file real data',run('validate_file.sh','case/logs/auth.log').returncode==0)
    error('buggy fixed missing file',run('buggy.sh','missing-test-file'),1)
    check('buggy valid file',run('buggy.sh','case/logs/auth.log').returncode==0)
    r=command('bash','-c','./buggy.sh missing-test-file && echo "ok" || echo "failed"')
    check('fixed buggy chain',r.stdout=='failed\n' and bool(r.stderr))
    for args, count in [((),0),(('a','b','c'),3)]:
        r=run('args_demo.sh',*args)
        check('args_demo '+str(count),r.returncode==0 and f'Argument count : {count}' in r.stdout)
    r=command('bash','-c','./args_demo.sh case/logs/*.log')
    check('log wildcard expands to 3', 'Argument count : 3' in r.stdout)
    r=command('bash','-c','./args_demo.sh case/*')
    check('partial case wildcard expands to 1','Argument count : 1' in r.stdout)
    check('one_arg quoted', 'Argument count: 1' in run('one_arg.sh','Failed password').stdout)
    check('one_arg unquoted', 'Argument count: 2' in run('one_arg.sh','Failed','password').stdout)
    quoted=run('search.sh','case/logs/auth.log','Accepted password')
    unquoted=run('search.sh','case/logs/auth.log','Accepted','password')
    check('search quoted versus unquoted',quoted.returncode==0 and unquoted.returncode==0 and quoted.stdout.splitlines()[1:]==unquoted.stdout.splitlines()[1:] and "'Accepted password'" in quoted.stdout and "'Accepted'" in unquoted.stdout)
    for name,count in [('auth.log',5),('access.log',0),('firewall.log',1)]:
        r=run('search.sh','case/logs/'+name,'203.0.113.200')
        check('IP search '+name,len(r.stdout.splitlines())-1==count and r.returncode==(0 if count else 1))
    for name, expected in [('today.sh','auth.log has 60 lines'),('nested_sub.sh','45 are failed logins and 15 are successful'),('failedlogin.sh','203.0.113.10'),('sql.sh','22, which is 27%'),('exercise1.sh','3 BLOCK decisions')]:
        r=run(name); check('run '+name,r.returncode==0 and not r.stderr and expected in r.stdout)
    for name,code in [('eve',0),('mallory',1)]:
        check('grep '+name,command('grep',name,'intel/users.csv').returncode==code)
    with tempfile.TemporaryDirectory(prefix='lab06-tests-') as tmp:
        t=Path(tmp); t.chmod(0o755)
        empty=t/'empty.bin'; empty.touch()
        a=t/'baseline.conf'; a.write_text('mode=old\n')
        b=t/'current.conf'; b.write_text('mode=new\n')
        check('diff identical',run('config_drift.sh',a,a).returncode==0)
        r=run('config_drift.sh',a,b)
        check('diff changed',r.returncode==1 and '-mode=old' in r.stdout and '+mode=new' in r.stdout)
        error('diff missing file',run('config_drift.sh',a,t/'missing'),2)
        error('diff wrong argument count',run('config_drift.sh'),2)
        for right,expected in [(a,'NO DRIFT'),(b,'DRIFT DETECTED')]:
            r=command('bash','-c','./config_drift.sh "$1" "$2" > /dev/null && echo "NO DRIFT" || echo "DRIFT DETECTED"','test',str(a),str(right))
            check('diff chain '+expected,r.stdout==expected+'\n')
        error('validate empty file',run('validate_file.sh',empty),4)
        r=run('logstats.sh',empty)
        check('empty log sensible zeros',r.returncode==0 and 'Total lines     : 0' in r.stdout and 'Longest line    : 0 characters' in r.stdout and 'Failed logins   : 0' in r.stdout)
        check('empty attacker report',run('attacker_report.sh',empty).returncode==0 and 'source: None' in run('attacker_report.sh',empty).stdout)
        sample=t/'log with spaces.log'
        sample.write_text('Sep 20 10:00:00 server sshd[1]: Failed password for invalid user deploy from 192.0.2.9 port 1234 ssh2\nSep 20 10:00:01 server sshd[2]: Failed password for root from 192.0.2.9 port 1235 ssh2\n')
        r=run('attacker_report.sh',sample,cwd=t)
        check('space path, alternate cwd and invalid-user parsing',r.returncode==0 and re.search(r'^\s*1 deploy$',r.stdout,re.M) and 'invalid' not in r.stdout and 'source: 192.0.2.9' in r.stdout)
        check('logstats filename with spaces',run('logstats.sh',sample).returncode==0)
        # Permission tests must not run as root, which can read mode-000 files.
        unreadable=t/'unreadable.log'; unreadable.write_text('secret\n'); unreadable.chmod(0)
        for script in ['validate_file.sh','logstats.sh','attacker_report.sh','top3.sh']:
            if os.geteuid()==0:
                rows.append('SKIP '+script+' unreadable file: runtime is root; switching user is unavailable here.')
            else:
                error(script+' unreadable file',run(script,unreadable),3)
        # Deliberately broken copies are kept outside case/ and intel/.
        broken=t/'broken-top3.sh'
        broken.write_text((P/'top3.sh').read_text().replace('echo "$TOP_ATTACKERS"','echo $TOP_ATTACKERS'))
        r=command('bash',str(broken),'case/logs/auth.log')
        check('broken quote demo collapses three rows',len(r.stdout.splitlines())==2 and '15 203.0.113.10 14 198.51.100.24 8 198.51.100.77' in r.stdout)
        broken.write_text((P/'buggy.sh').read_text().replace('echo "Error: file not found" >&2','echo "Error: file not found"').replace('    exit 1\nfi\n\necho "File found."','fi\n\necho "File found."'))
        r=command('bash',str(broken),'missing-test-file')
        check('broken exit demo lies about failure',r.returncode==0 and 'Error: file not found' in r.stdout and not r.stderr)
        broken.write_text((P/'logstats.sh').read_text().replace('[ -n "$KEYWORD" ]','[ -z "$KEYWORD" ]'))
        r=command('bash','-c','printf "sqlmap\\n" | bash "$1" case/logs/access.log','test',str(broken))
        check('-z demo skips nonempty keyword','Lines containing' not in r.stdout and 'grep exit code' not in r.stdout)
        r=command('bash','-c','printf "\\n" | bash "$1" case/logs/access.log','test',str(broken))
        check('-z demo empty pattern matches every line',"Lines containing '': 80" in r.stdout)
        sample.write_text('one\nsecond')
        check('wc newline semantics without final newline','Total lines     : 1' in run('logstats.sh',sample).stdout)
    check('evidence bytes unchanged',all(hashlib.sha256(f.read_bytes()).hexdigest()==h for f,h in hashes.items()))
try:
    main()
except Exception as e:
    print('\n'.join(rows)); print('TEST ERROR:',repr(e)); raise
print('\n'.join(rows))
print(f"\n{sum(r.startswith('PASS') for r in rows)} checks passed; {sum(r.startswith('SKIP') for r in rows)} skipped.")
print('Real server-log and configuration comparisons: NOT TESTED; source files were not supplied.')
