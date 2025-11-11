#!/usr/bin/env python3
"""
API tester for the backend OpenAPI document.
Reads `docs/backend_docs.json`, enumerates paths and methods, constructs basic example requests,
and executes them against a base URL. Produces a machine-readable JSON report with full
request/response data, timings, and errors suitable for further AI analysis.

Usage:
  Set environment variables or pass command-line args.
  - BASE_URL (env) or --base-url
  - BEARER_TOKEN (env) or --token  (optional)

Example:
  BASE_URL=https://6794279c7cb2.ngrok-free.app/ python tools/api_tester.py

Note: The script intentionally uses safe example payloads. It does not upload binary files.
Use this on a staging environment; avoid running destructive endpoints against production.
"""

import argparse
import json
import os
import time
import datetime
import random
import requests
from urllib.parse import urljoin, urlencode

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DOC_PATH = os.path.join(ROOT, 'docs', 'backend_docs.json')
REPORT_DIR = os.path.join(ROOT, 'reports')

# Basic mapping of OpenAPI simple types to example values
def example_for_schema(schema):
    if not schema:
        return None
    t = schema.get('type')
    if '$ref' in schema:
        # reference; return a placeholder
        return '<ref:%s>' % schema['$ref']
    if t == 'string':
        fmt = schema.get('format','')
        if fmt == 'date':
            return datetime.date.today().isoformat()
        if fmt == 'binary':
            return '<binary-file>'
        return schema.get('example', schema.get('default', 'string_example'))
    if t == 'number' or t == 'integer':
        return schema.get('example', schema.get('default', 1))
    if t == 'boolean':
        return schema.get('example', True)
    if t == 'array':
        items = schema.get('items', {})
        return [example_for_schema(items)]
    if t == 'object' or 'properties' in schema:
        out = {}
        props = schema.get('properties', {})
        for k,v in props.items():
            out[k] = example_for_schema(v)
        return out
    # fallback
    return schema.get('example', None)


def build_request(base_url, path, method, op):
    # path may include {param}; build url after replacing path params with placeholders
    path_params = {}
    query_params = {}
    headers = {'Accept': 'application/json'}
    body = None
    multipart = False

    parameters = op.get('parameters', []) or []
    for p in parameters:
        loc = p.get('in')
        name = p.get('name')
        schema = p.get('schema', {})
        if loc == 'path':
            path_params[name] = example_for_schema(schema) or '1'
        elif loc == 'query':
            # if array, produce a comma-separated string
            if schema.get('type') == 'array':
                query_params[name] = ','.join([str(x) for x in example_for_schema(schema)])
            else:
                query_params[name] = example_for_schema(schema)
        elif loc == 'header':
            headers[name] = example_for_schema(schema)

    # Replace path params
    formatted_path = path
    for k,v in path_params.items():
        formatted_path = formatted_path.replace('{' + k + '}', str(v))

    # Request body
    rb = op.get('requestBody')
    if rb:
        content = rb.get('content', {})
        # pick first media type
        if 'application/json' in content:
            schema = content['application/json'].get('schema', {})
            body = example_for_schema(resolve_schema(schema))
            headers['Content-Type'] = 'application/json'
        elif 'multipart/form-data' in content:
            # build form fields (no real file uploads)
            multipart = True
            schema = content['multipart/form-data'].get('schema', {})
            props = schema.get('properties', {})
            data = {}
            files = {}
            for k,p in props.items():
                if p.get('format') == 'binary' or p.get('type') == 'string' and p.get('format')=='binary':
                    # placeholder; do not attach actual file
                    files[k] = ('placeholder.txt', b'placeholder')
                else:
                    data[k] = example_for_schema(p)
            body = {'data': data, 'files': files}
            # requests will set content-type
        elif 'application/x-www-form-urlencoded' in content:
            schema = content['application/x-www-form-urlencoded'].get('schema', {})
            body = example_for_schema(schema)
            headers['Content-Type'] = 'application/x-www-form-urlencoded'
        else:
            # fallback to first media type
            mt = next(iter(content.keys()))
            schema = content[mt].get('schema', {})
            body = example_for_schema(resolve_schema(schema))

    url = urljoin(base_url, formatted_path.lstrip('/'))
    if query_params:
        url = url + ('?' + urlencode({k:v for k,v in query_params.items() if v is not None}))

    return {
        'method': method.upper(),
        'url': url,
        'headers': headers,
        'body': body,
        'multipart': multipart,
        'query': query_params,
        'path_params': path_params,
    }

OPENAPI = None
COMPONENTS = {}

def resolve_schema(schema):
    if not schema:
        return {}
    if '$ref' in schema:
        ref = schema['$ref']
        # #/components/schemas/Name
        if ref.startswith('#/components/schemas/'):
            name = ref.split('/')[-1]
            return COMPONENTS.get(name, {})
        return {}
    return schema


def run_request(s, req, token=None, timeout=30):
    method = req['method']
    url = req['url']
    headers = dict(req['headers'])
    if token:
        headers['Authorization'] = 'Bearer ' + token

    start = time.time()
    try:
        if req['multipart']:
            data = req['body']['data']
            files = req['body']['files']
            r = s.request(method, url, headers=headers, data=data, files=files, timeout=timeout)
        else:
            if headers.get('Content-Type') == 'application/json' and req['body'] is not None:
                r = s.request(method, url, headers=headers, json=req['body'], timeout=timeout)
            else:
                r = s.request(method, url, headers=headers, data=req['body'], timeout=timeout)
        elapsed = (time.time() - start) * 1000.0
        return {
            'ok': True,
            'status_code': r.status_code,
            'headers': dict(r.headers),
            'body_text': safe_text(r),
            'elapsed_ms': elapsed,
        }
    except Exception as e:
        elapsed = (time.time() - start) * 1000.0
        return {
            'ok': False,
            'error': str(e),
            'elapsed_ms': elapsed,
        }


def safe_text(r):
    try:
        return r.text
    except Exception:
        return '<binary or unreadable body>'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--base-url', default=os.environ.get('BASE_URL', 'https://6794279c7cb2.ngrok-free.app/'))
    parser.add_argument('--token', default=os.environ.get('BEARER_TOKEN', os.environ.get('API_BEARER_TOKEN', None)))
    parser.add_argument('--output', default=None)
    parser.add_argument('--timeout', type=int, default=30)
    args = parser.parse_args()

    base_url = args.base_url
    token = args.token
    timeout = args.timeout

    if not os.path.exists(DOC_PATH):
        print('OpenAPI document not found at', DOC_PATH)
        return

    with open(DOC_PATH, 'r', encoding='utf-8') as f:
        doc = json.load(f)

    global OPENAPI, COMPONENTS
    OPENAPI = doc
    COMPONENTS = doc.get('components', {}).get('schemas', {})

    results = {
        'base_url': base_url,
        'timestamp': datetime.datetime.utcnow().isoformat() + 'Z',
        'endpoints': [],
        'summary': {
            'total': 0,
            'success': 0,
            'errors': 0,
            'details': []
        }
    }

    session = requests.Session()
    session.verify = True

    paths = doc.get('paths', {})
    for path, methods in paths.items():
        for method, op in methods.items():
            req = build_request(base_url, path, method, op)
            record = {
                'path': path,
                'method': method.upper(),
                'operationId': op.get('operationId'),
                'request': req,
                'response': None,
            }
            results['summary']['total'] += 1

            resp = run_request(session, req, token=token, timeout=timeout)
            record['response'] = resp

            # classify
            if resp.get('ok') and (200 <= int(resp.get('status_code', 0)) < 300):
                results['summary']['success'] += 1
            else:
                results['summary']['errors'] += 1
                results['summary']['details'].append({
                    'path': path,
                    'method': method.upper(),
                    'status_code': resp.get('status_code'),
                    'error': resp.get('error') if not resp.get('ok') else None,
                })

            results['endpoints'].append(record)

    # ensure report directory
    os.makedirs(REPORT_DIR, exist_ok=True)
    out_path = args.output or os.path.join(REPORT_DIR, 'api_test_report_%s.json' % datetime.datetime.utcnow().strftime('%Y%m%dT%H%M%SZ'))
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print('Report written to', out_path)

if __name__ == '__main__':
    main()
