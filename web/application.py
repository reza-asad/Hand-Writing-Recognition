import json
from flask import Flask, request, abort, jsonify
import pandas as pd
from config import NUM_TREES
from sklearn.ensemble import RandomForestClassifier
import os
from final_model import model

# This reads the preprocessed data
dir = os.path.dirname(os.getcwd())
data_path = dir+'/final_model/data'
data = pd.read_pickle(data_path)
rf = None

application = Flask(__name__)        
KEYS = ['x', 'y', 'time']


# header must be "Content-Type:application/json"
@application.route('/letter', methods = ['GET', 'POST'])
def predict():
    # parse the GET request
    # should be in the following form:
    # {'99999' : [
    #   [{'y': y, 'x': x, 'time': time}, {'y': y, 'x': x, 'time': time}, ...], - stroke 1
    #   [{'y': y, 'x': x, 'time': time}, {'y': y, 'x': x, 'time': time}, ...], - stroke 2
    #   ...
    # ]}
    if request.method == 'GET':
        resp = {'success': True, 'message': 'Use this API to predict handwritten letter based on strokes'}
        resp = jsonify(resp)
        resp.status_code = 200
        return resp
        
    req = request.get_json()
    if req == None:
        abort(400)
    
    if not isinstance(req, dict):
        abort(400)

    if len(req.keys()) != 1:
        print(req.keys())
        abort(400)

    user = req.keys()[0]

    if not isinstance(user, basestring):
        print('not string')
        abort(400)

    strokes = req[user]

    if not isinstance(strokes, list):
        print('not list')
        abort(400)

    if len(strokes) == 0:
        print('no strokes')
        abort(400)

    for stroke in strokes:
        if not isinstance(stroke, list):
            print('bad stroke')
            abort(400)
        for data_point in stroke:
            if not isinstance(data_point, dict):
                print('bad data point')
                abort(400)
            try:
                for key in KEYS:
                    if not isinstance(data_point[key], int):
                        abort(400)
            except KeyError:
                abort(400)

    # generate response
    data = ['A', 'B', 'C'] #TODO
    result = {'1': data[0], '2': data[1], '3': data[2]}

    resp = jsonify(result)
    resp.status_code = 200
    return resp
			
if __name__ == "__main__":
    print('initialized')
    rf = model.rf_model(data)
    application.run()
