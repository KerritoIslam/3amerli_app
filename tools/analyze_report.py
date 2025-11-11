import json
from pathlib import Path
p=Path('3amerli_app/reports/api_test_report_latest.json')
if not p.exists():
    print('Report not found:', p)
    raise SystemExit(1)
report=json.loads(p.read_text(encoding='utf-8-sig'))
endpoints=report.get('endpoints',[])
summary={'total':len(endpoints),'non_2xx':0,'unauthorized':0,'not_found':0,'other_errors':0,'details':[]}
for e in endpoints:
    resp=e.get('response',{})
    sc=resp.get('status_code')
    ok=resp.get('ok')
    if not ok or not (200<=int(sc or 0)<300):
        summary['non_2xx']+=1
        if sc==401:
            summary['unauthorized']+=1
        elif sc==404:
            summary['not_found']+=1
        else:
            summary['other_errors']+=1
        summary['details'].append({'path':e.get('path'),'method':e.get('method'),'status_code':sc,'body':resp.get('body_text')})
out=Path('3amerli_app/reports/api_test_analysis_summary.json')
out.write_text(json.dumps({'base_url':report.get('base_url'),'timestamp':report.get('timestamp'),'summary':summary},indent=2,ensure_ascii=False),encoding='utf-8')
print('WROTE',out)
