import json
import os
import requests
from datetime import datetime

ROOT = os.path.dirname(os.path.dirname(__file__))
DOCS_PATH = os.path.join(ROOT, 'docs', 'backend_docs.json')
OUT_PATH = os.path.join(ROOT, 'reports', 'invoice_test_results.json')

def load_spec():
    if not os.path.exists(DOCS_PATH):
        return {}
    with open(DOCS_PATH, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_token(spec, key_names=('admin_accessToken','admin_token','adminToken')):
    for k in key_names:
        if k in spec:
            return spec[k]
    # try scanning
    for v in spec.values():
        if isinstance(v, str) and v.startswith('ey') and len(v) > 100:
            return v
    return None

def main():
    spec = load_spec()
    base = spec.get('baseUrl') or 'https://6794279c7cb2.ngrok-free.app'
    admin_token = get_token(spec)
    supermarket_token = spec.get('sumermarket_accessToken') or spec.get('supermarket_accessToken')

    headers_admin = {'Authorization': f'Bearer {admin_token}'} if admin_token else {}
    headers_super = {'Authorization': f'Bearer {supermarket_token}'} if supermarket_token else {}

    invoice_id = 1
    paths = [
        ('GET', f'{base}/api/v1/invoices/{invoice_id}'),
        ('DELETE', f'{base}/api/v1/invoices/{invoice_id}'),
        ('GET', f'{base}/api/v1/invoices/{invoice_id}/download'),
        ('GET', f'{base}/api/v1/invoices/{invoice_id}/preview'),
        ('POST', f'{base}/api/v1/invoices/{invoice_id}/regenerate'),
    ]

    results = {'timestamp': datetime.utcnow().isoformat() + 'Z', 'checks': []}

    for method, url in paths:
        for auth_label, hdrs in (('admin', headers_admin), ('supermarket', headers_super), ('none', {})):
            entry = {'path': url.replace(base, '/api/v1'), 'method': method, 'auth': auth_label}
            try:
                resp = requests.request(method, url, headers=hdrs, timeout=15)
                entry['status_code'] = resp.status_code
                try:
                    entry['body'] = resp.json()
                except Exception:
                    entry['body'] = resp.text[:200]
            except Exception as e:
                entry['error'] = str(e)
            results['checks'].append(entry)

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print('Wrote', OUT_PATH)

if __name__ == '__main__':
    main()
