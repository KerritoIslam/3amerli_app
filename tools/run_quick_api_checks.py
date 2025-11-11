#!/usr/bin/env python3
import requests, json, time, os
from urllib.parse import urljoin

BASE_URL = os.environ.get('BASE_URL', 'https://07af1ab51e65.ngrok-free.app')
TOKEN = os.environ.get('BEARER_TOKEN') or 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwicGhvbmVOdW1iZXIiOiIwNTYwNjIwOTk5Iiwicm9sZSI6IkFETUlOIiwiaXNSZWdpc3RlcmVkIjp0cnVlLCJpYXQiOjE3NjI4NTQzMTAsImV4cCI6MTc2Mjg2MjMxMH0.6tS7k0J06VPhKfK7EiLhNBiMLckleaJ665r6SnPVuwE'
OUT = os.path.join(os.path.dirname(__file__), '..', 'reports', 'quick_api_results.json')

endpoints = [
    ('GET', '/api/v1/analytics/daily-stats'),
    ('GET', '/api/v1/analytics/turnover'),
    ('GET', '/api/v1/analytics/top-products'),
    ('GET', '/api/v1/products/admin/all'),
    ('GET', '/api/v1/products/all'),
]

s = requests.Session()
s.verify = True
s.headers.update({'Accept': 'application/json'})

results = {'base_url': BASE_URL, 'timestamp': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()), 'checks': []}

for method, path in endpoints:
    url = urljoin(BASE_URL, path.lstrip('/'))
    headers = {'Authorization': 'Bearer ' + TOKEN}
    rec = {'path': path, 'method': method, 'url': url}
    start = time.time()
    try:
        r = s.request(method, url, headers=headers, timeout=8)
        elapsed = (time.time() - start) * 1000
        text = None
        try:
            text = r.text
            body = None
            try:
                body = r.json()
            except Exception:
                body = None
        except Exception:
            text = '<unreadable>'
            body = None

        rec.update({'ok': True, 'status_code': r.status_code, 'elapsed_ms': elapsed, 'headers': dict(r.headers), 'body_text': text, 'body_json': body})
    except Exception as e:
        rec.update({'ok': False, 'error': str(e), 'elapsed_ms': (time.time() - start) * 1000})
    results['checks'].append(rec)

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2, ensure_ascii=False)

print('Wrote quick results to', OUT)
