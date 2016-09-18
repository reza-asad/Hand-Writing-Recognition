import pandas as pd
from pandas import DataFrame, Series
import numpy as np
from config import NUM_STROKES_AS_FEATURE, STROKE_PARTITION, NUM_TREES
from preprocessing import drawing_record
from utility import center_scale, top_k_prediction
from model import rf_model


# This preprocesses the data
def preprocess_data(record):
    num_features = ((STROKE_PARTITION) * 2 + 2) * NUM_STROKES_AS_FEATURE + 2
    features = []
    labels = []
    dr = drawing_record(record[record.keys()[0]])
    if len(dr.strokes) > NUM_STROKES_AS_FEATURE:
        print 'Too many strokes'
        return
    dr.remov_None_strokes()
    dr.stroke_connect()
    dr.dehook(beg=True, end=True)
    dr.average_smoothing()
    dr.resample()
    dr.scale_shift()
    dr.extract_local_features()
    dr.extract_global_features()
    if len(dr.features) != num_features:
        print 'num_features is not what is expected'
    if np.isnan(dr.features).any():
        print 'nan value found'
        return 
    labels.append(record.keys()[0])
    features.append(dr.features)
    return features, labels

# This returns the top k characters that the drawing is likely to be
# Input: 
#   -recording: A json with key user_id and value a list of strokes.
#               Strokes are a list of dictionaries with (x,y,t)
#               coordinates.
#   -k: The number of characters that the drawing is most likely
# Output:
#   - The top k characters that the drawing is most likely
def find_top_k_chars(recording, model, k=3):
    x_test, labels = preprocess_data(recording)
    # Convert this test data to datafrmae
    test_dat = DataFrame(x_test)

    # Center and scale the data
    center_scale(test_dat)

    # This is a dictionary with a unique id as key and labels as value
    id_to_char = dict(zip(range(len(model.classes_[0])), model.classes_[0]))

    # Predict using the rf model and return the predicted characters
    test_prediction = model.predict_proba(test_dat.as_matrix())
    return dict(zip(labels, top_k_prediction(test_prediction, id_to_char)))
