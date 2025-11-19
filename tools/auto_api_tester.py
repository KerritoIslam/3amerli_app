#!/usr/bin/env python3
"""
Auto API tester
- Reads `docs/backend_docs.json` OpenAPI-like file included in repo
- Iterates endpoints (skips /authentication endpoints per user request)
- For each endpoint and method it will:
  - Build a sample request (path params, query params, body)
  - Try requests with admin token, then supermarket token, then without auth
  - Capture request and response details
  - Flag unexpected status codes (not in spec responses)
- Writes machine-readable report to `reports/api_test_report.json`
- Writes a short human summary to `reports/api_test_summary.md`

Notes:
- This is a lightweight, best-effort tester. It synthesizes sample payloads from schema examples or types.
- Use environment variable BASE_URL to override the target base URL.
"""

import json
import os
import time
import copy
from datetime import datetime
from urllib.parse import urlencode
import mimetypes
import io

import requests

ROOT = os.path.dirname(os.path.dirname(__file__))
SPEC_PATH = os.path.join(ROOT, 'docs', 'backend_docs.json')
REPORT_DIR = os.path.join(ROOT, 'reports')
os.makedirs(REPORT_DIR, exist_ok=True)
REPORT_PATH = os.path.join(REPORT_DIR, 'api_test_report.json')
SUMMARY_PATH = os.path.join(REPORT_DIR, 'api_test_summary.md')

BASE_URL = os.environ.get('BASE_URL', 'https://6794279c7cb2.ngrok-free.app/')
if BASE_URL.endswith('/'):
    BASE_URL = BASE_URL[:-1]

# Tokens: try to read from spec (the top-level includes tokens in this repo file) or env
try:
    with open(SPEC_PATH, 'r', encoding='utf-8') as f:
        SPEC = json.load(f)
except Exception as e:
    print('Failed to read spec at', SPEC_PATH, e)
    SPEC = {}

ADMIN_TOKEN = os.environ.get('ADMIN_TOKEN') or SPEC.get('admin_accessToken')
ADMIN_REFRESH = os.environ.get('ADMIN_REFRESH') or SPEC.get('admin_refreshToken')
SUM_TOKEN = os.environ.get('SUM_TOKEN') or SPEC.get('sumermarket_accessToken')
SUM_REFRESH = os.environ.get('SUM_REFRESH') or SPEC.get('sumermarket_refreshToken')

# helper: resolve $ref

def resolve_ref(ref: str, spec: dict):
    if not ref.startswith('#/'):
        return None
    parts = ref.lstrip('#/').split('/')
    node = spec
    for p in parts:
        node = node.get(p)
        if node is None:
            return None
    return node


def sample_from_schema(schema, spec):
    if schema is None:
        return None
    if '$ref' in schema:
        ref_schema = resolve_ref(schema['$ref'], spec)
        return sample_from_schema(ref_schema, spec)
    t = schema.get('type')
    if 'example' in schema:
        return schema['example']
    if t == 'object' or (not t and 'properties' in schema):
        out = {}
        props = schema.get('properties', {})
        for k, v in props.items():
            out[k] = sample_from_schema(v, spec)
        return out
    if t == 'array':
        item = schema.get('items', {})
        return [sample_from_schema(item, spec)]
    if t == 'string':
        fmt = schema.get('format','')
        if fmt == 'date':
            return '2026-12-31'
        if fmt == 'binary':
            return 'FILE_BYTES'
        return schema.get('example', 'sample')
    if t in ('integer', 'number'):
        return schema.get('example', 1)
    if t == 'boolean':
        return schema.get('example', True)
    # fallback
    return schema.get('example', 'sample')


def build_path(path_template, parameters):
    # parameters: list of parameter objects; replace path params with sample values
    path = path_template
    if not parameters:
        return path
    for p in parameters:
        if p.get('in') == 'path':
            name = p['name']
            schema = p.get('schema', {})
            sample = sample_from_schema(schema, SPEC) if schema else '1'
            path = path.replace('{' + name + '}', str(sample))
    return path


def build_query(parameters):
    q = {}
    if not parameters:
        return q
    for p in parameters:
        if p.get('in') == 'query':
            name = p['name']
            schema = p.get('schema', {})
            if 'default' in schema:
                q[name] = schema['default']
            else:
                q[name] = sample_from_schema(schema, SPEC)
    return q


def make_request(url, method, headers, params=None, json_body=None, files=None, timeout=25):
    try:
        resp = requests.request(method, url, headers=headers, params=params, json=json_body, files=files, timeout=timeout)
        try:
            body = resp.json()
        except Exception:
            body = resp.text
        return {'ok': True, 'status_code': resp.status_code, 'headers': dict(resp.headers), 'body': body}
    except Exception as e:
        return {'ok': False, 'error': str(e)}


# main
results = {
    'base_url': BASE_URL,
    'timestamp': datetime.utcnow().isoformat() + 'Z',
    'summary': {},
    'tests': []
}

paths = SPEC.get('paths', {})

# optional limit for quicker runs during development or CI
MAX_ENDPOINTS = int(os.environ.get('MAX_ENDPOINTS', '0'))  # 0 => no limit
tested_count = 0

# scan endpoints
for path, methods in paths.items():
    # skip authentication endpoints per request
    if path.startswith('/api/v1/authentication') or '/authentication' in path:
        continue
    for method, details in methods.items():
        # respect max limit if set
        if MAX_ENDPOINTS and tested_count >= MAX_ENDPOINTS:
            break
        m_upper = method.upper()
        operation = details.get('operationId') or details.get('summary')
        parameters = details.get('parameters', [])
        req_body_def = details.get('requestBody')
        security = details.get('security') or []
        responses_spec = details.get('responses', {})

        # build path and query
        full_path = build_path(path, parameters)
        query = build_query(parameters)
        url = BASE_URL + full_path

        # build body
        json_body = None
        files = None
        if req_body_def:
            # pick first content type
            content = req_body_def.get('content', {})
            if 'application/json' in content:
                schema = content['application/json'].get('schema')
                json_body = sample_from_schema(schema, SPEC)
            elif 'multipart/form-data' in content:
                schema = content['multipart/form-data'].get('schema')
                if schema:
                    props = schema.get('properties', {})
                    # prepare files for 'binary' properties and form fields for others
                    files = {}
                    form = {}
                    for k, v in props.items():
                        if v.get('format') == 'binary' or v.get('type') == 'string' and v.get('format') == 'binary':
                            # attach a small text file
                            files[k] = ('dummy.txt', io.BytesIO(b'dummy'), 'text/plain')
                        else:
                            form[k] = sample_from_schema(v, SPEC)
                    # requests supports both files and data; keep json_body None and use files+data
                    # We'll attach form fields into files as (None,value) per requests to send multipart
                    files_payload = {}
                    for k, v in form.items():
                        files_payload[k] = (None, str(v))
                    files_payload.update(files)
                    files = files_payload

        # prepare auth attempts: admin, supermarket, none
        attempts = []
        # if security is required, still we will attempt admin then supermarket then none
        if ADMIN_TOKEN:
            attempts.append({'auth': 'admin', 'token': ADMIN_TOKEN})
        if SUM_TOKEN:
            attempts.append({'auth': 'supermarket', 'token': SUM_TOKEN})
        attempts.append({'auth': 'none', 'token': None})

        expected_statuses = set(int(k) for k in responses_spec.keys() if k.isdigit())

        test_entry = {
            'path': path,
            'method': m_upper,
            'operation': operation,
            'full_url_template': BASE_URL + path,
            'requested_url': url,
            'parameters': [p for p in parameters],
            'query': query,
            'request_body_sample': json_body if json_body is not None else ('multipart' if files else None),
            'attempts': [],
            'expected_statuses': sorted(list(expected_statuses))
        }

        for attempt in attempts:
            hdrs = {'Accept': 'application/json'}
            if attempt['token']:
                hdrs['Authorization'] = 'Bearer ' + attempt['token']
            # include a User-Agent to avoid some blocking
            hdrs['User-Agent'] = 'AutoAPI/1.0 (tester)'

            # perform request
            resp = make_request(url, m_upper, hdrs, params=query if query else None, json_body=json_body, files=files)
            attempt_entry = {
                'auth_used': attempt['auth'],
                'request': {
                    'method': m_upper,
                    'url': url,
                    'headers': hdrs,
                    'query': query,
                    'body_sent': json_body if json_body is not None else (('multipart' if files else None))
                },
                'response': resp
            }
            # mark unexpected if we got a status code and it's not in expected_statuses
            if resp.get('ok') and 'status_code' in resp:
                code = resp['status_code']
                attempt_entry['unexpected'] = (code not in expected_statuses) if expected_statuses else (code >= 400)
            else:
                attempt_entry['unexpected'] = True

            test_entry['attempts'].append(attempt_entry)

            # if we got 200-299 and content, stop trying other tokens to reduce calls
            if resp.get('ok') and 200 <= resp.get('status_code', 0) < 300:
                break

        results['tests'].append(test_entry)
        tested_count += 1
        if tested_count % 10 == 0:
            print(f"Progress: tested {tested_count} endpoints...")

    if MAX_ENDPOINTS and tested_count >= MAX_ENDPOINTS:
        print(f"Reached MAX_ENDPOINTS={MAX_ENDPOINTS}, stopping further tests")
        break

# write raw report
with open(REPORT_PATH, 'w', encoding='utf-8') as outf:
    json.dump(results, outf, indent=2, ensure_ascii=False)

# generate short summary
errors = []
for t in results['tests']:
    for a in t['attempts']:
        r = a['response']
        if not r.get('ok'):
            errors.append({
                'path': t['path'], 'method': t['method'], 'auth': a['auth_used'], 'error': r.get('error')
            })
        else:
            sc = r.get('status_code')
            expected = t.get('expected_statuses', [])
            if expected and sc not in expected:
                errors.append({
                    'path': t['path'], 'method': t['method'], 'auth': a['auth_used'], 'status_code': sc,
                    'note': 'status not in spec responses', 'response_body': r.get('body')
                })
            elif sc >= 400:
                errors.append({
                    'path': t['path'], 'method': t['method'], 'auth': a['auth_used'], 'status_code': sc,
                    'note': 'error response', 'response_body': r.get('body')
                })

with open(SUMMARY_PATH, 'w', encoding='utf-8') as s:
    s.write('# API Test Summary\n')
    s.write('\n')
    s.write('Base URL: ' + BASE_URL + '\n')
    s.write('Timestamp: ' + results['timestamp'] + '\n')
    s.write('\n')
    s.write('Total endpoints tested: {}\n'.format(len(results['tests'])))
    s.write('\n')
    if errors:
        s.write('## Unexpected results / Errors\n')
        for e in errors:
            s.write('- Path: {path}  Method: {method}  Auth: {auth}  '.format(**e))
            if 'status_code' in e:
                s.write('Status: {status_code}. '.format(**e))
            if 'note' in e:
                s.write(e['note'] + '. ')
            if 'error' in e:
                s.write('Error: {error}.'.format(**e))
            s.write('\n')
            if 'response_body' in e:
                s.write('  Response body: ' + json.dumps(e['response_body'], ensure_ascii=False)[:1000] + '\n')
    else:
        s.write('No unexpected errors detected.\n')

print('\nReport written to:', REPORT_PATH)
print('Summary written to:', SUMMARY_PATH)
print('Done.')
