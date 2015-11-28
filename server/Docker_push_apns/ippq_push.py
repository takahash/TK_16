#!/usr/bin/env python
# vim: set fileencoding=utf-8 :
#
# Author:   Itou Shunichi
# Created:  2015-11-28
from flask import Flask, jsonify, request
from flask.ext.api import status
from pyapns import configure, provision, notify
import json
import requests
import logging
import httplib as http_client
app = Flask(__name__)

@app.route('/', methods=['POST'])
def push_from_device():

    #debug
    http_client.HTTPConnection.debuglevel = 1
    logging.basicConfig() 
    logging.getLogger().setLevel(logging.DEBUG)
    requests_log = logging.getLogger("requests.packages.urllib3")
    requests_log.setLevel(logging.DEBUG)
    requests_log.propagate = True
    #debug end
    params = {'app': 14,
            'id': 1}
    headers = {'Content-Type': 'application/json',
            'X-Cybozu-API-Token': 'usww5ikOCMm5Xbut97srqBYkHmcWLInbz3eLiCfL'
            }
    data = {'app': 14,
            'query': 'beacon_id="AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAA1"',
            'fields': ["device_token"],
            'totalCount': 'true'
            }
    content = {'message': 'ok. sending'}
    try:
        response = requests.get('https://redimpulz.cybozu.com/k/v1/records.json',
                    headers=headers,
                    data=json.dumps(data)
                    )
        print response.text
    except requests.exceptions:
        return 'NG'
    if not response.json()['totalCount'] is None:
        _device_token = response.json()['records'][0]['device_token']['value']
        _push_apns(_device_token)
        return 'OK' 
    else:
        return 'NG'

def _push_apns(device_id):
    configure({'HOST': 'http://localhost:7077/'})
    provision('myapp', open('pushCerDev.pem').read(), 'sandbox')
    notify('myapp', device_id, \
            {
                'aps':
                {
                    'alert': '周りにタバコが嫌いな人がいるよ！',
                    'sound': 'flynn.caf'
                    }
                }
            )
    return 'OK'
app.run(host='0.0.0.0', debug=True)
