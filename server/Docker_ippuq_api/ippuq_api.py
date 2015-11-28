#!/usr/bin/env python
# vim: set fileencoding=utf-8 :
#
# Author:   Itou Shunichi
# Created:  2015-11-28
from flask import Flask, jsonify, request, render_template
from flask.ext.api import status
from flask_restful import Resource, Api, reqparse
from pyapns import configure, provision, notify
from datetime import datetime
import json
import requests
import pymysql
import time
app = Flask(__name__)
api = Api(app)

db = pymysql.connect(host='us-cdbr-iron-east-03.cleardb.net',
                     port=3306,
                     user='b959f854f437cd',
                     passwd='0b53823b',
                     db='ad_e47199b04766127'
                    )

class users(Resource):
    '''
    [desc]
    新規ユーザー作成
    dbにユーザーが存在していなければ、user tableに新規登録を行う
    '''

    def post(self):
        '''
        [json]
        {user_name:xxx, "passwd:xxx"}
        [return code]
        201: created
        400: bad request
        '''
        cur = db.cursor()
        content_body_dict = request.get_json()
        CHECK_EXIST_USER_SQL = 'SELECT user_name FROM users WHERE user_name = %s AND passwd = %s'
        CREATE_USER_SQL = 'INSERT INTO users VALUE(%s, %s, %s, %s)'
        _check_exist_user = cur.execute(CHECK_EXIST_USER_SQL,
                                        (content_body_dict["user_name"],
                                         content_body_dict["passwd"],
                                        )
                                       )
        if _check_exist_user is 0:
            return "", status.HTTP_400_BAD_REQUEST
        else:
            _device_token = content_body_dict['device_token']
            _device_token_ignore_space = _device_token.split(" ", "")
            try:
                cur.execute(CHECK_EXIST_USER_SQL,
                            (content_body_dict["user_name"],
                             content_body_dict["passwd"],
                             _device_token_ignore_space,
                             content_body_dict["beacon_id"],
                            )
                           )
                db.commit()
                return "", status.HTTP_201_CREATED
            except pymysql.OperationalError:
                return "", status.HTTP_500_INTERNAL_SERVER_ERROR
    def get(self):
        '''
        [json]
        {user_name:xxx, passwd:xxx}
        [return code]
        200: OK
        400: NG
        '''

        cur = db.cursor()
        content_body_dict = request.get_json()
        CHECK_LOGIN_USER_SQL = 'SELECT user_name FROM users WHERE user_name = %s AND passwd = %s'
        _check_correct_user = cur.execute(CHECK_LOGIN_USER_SQL, (content_body_dict['user_name', content_body_dict['passwd']]))
        if _check_correct_user is 1:
            response = {'message':'login success'}
            return response, status.HTTP_200_OK
        else:
            response = {'message': 'login failed'}
            return response, status.HTTP_400_BAD_REQUEST

class places(Resource):

    def get(self):
        '''
        [json]
        {user_name:xxx}
        [return code]
        200: ok
        '''
        cur = db.cursor()
        content_body_dict = request.get_json()
        SEARCH_USER_ID_SQL = 'SELECT user_id FROM users WHERE user_name = %s'
        COUNT_SQL = 'SELECT created_at FROM place WHERE user_id = %s'
        cur.execute(SEARCH_USER_ID_SQL, (content_body_dict['user_name'],))
        _user_id = cur.fetchone()[0]
        cur.execute(COUNT_SQL, (_user_id,))
        _count_dict = cur.fetchall()
        return render_template("test.html", counts=_count_dict), status.HTTP_200_OK

    def put(self):
        cur = db.cursor()
        content_body_dict = request.get_json()
        SEARCH_USER_ID_SQL = 'SELECT user_id FROM users WHERE user_name = %s'
        cur.execute(SEARCH_USER_ID_SQL, (content_body_dict['user_name'],))
        _user_id = cur.fetchone()[0]
        print _user_id
        print  content_body_dict['len']
        print  content_body_dict['lng']

        INSERT_PLACE_SQL = 'INSERT INTO place(user_id, used_beacon_id, lat, lng) VALUES(%s, %s, %s, %s )'
        try:
            test = cur.execute(INSERT_PLACE_SQL,
                        (_user_id,
                         content_body_dict['beacon_id'],
                         str(content_body_dict['len']),
                         str(content_body_dict['lng'])
                        )
                       )
            db.commit()
            return '', status.HTTP_200_OK
        except pymysql.OperationalError:
            return '', status.HTTP_500_INTERNAL_SERVER_ERROR


api.add_resource(users, '/users')
api.add_resource(places, '/places')
app.run(host='0.0.0.0', port=80, debug=True)
