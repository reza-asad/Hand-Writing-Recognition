import pandas as pd
from pandas import DataFrame, Series
import numpy as np
from config import NUM_STROKES_AS_FEATURE
from preprocessing import drawing_record


# This preprocesses the data
def preprocess_data(recording, with_label=False):
    dr = drawing_record(recording[recording.keys()[0]])
    if len(dr.strokes) > NUM_STROKES_AS_FEATURE:
        continue
    dr.remov_None_strokes()
    dr.stroke_connect()
    dr.dehook(beg=True, end=True)
    dr.average_smoothing()
    try:
        dr.resample()
    except LinAlgError:
        pass
    dr.scale_shift()
    dr.extract_local_features()
    dr.extract_global_features()
    if np.isnan(dr.features).any():
        print 'nan value found', i
        continue    
    if with_label:
        return [dr.features], [recording.keys()[0]]
    return [dr.features], None

# This returns the top k characters that the drawing is likely to be
# Input: 
#   -recording: A json with key user_id and value a list of strokes.
#               Strokes are a list of dictionaries with (x,y,t)
#               coordinates.
#   -k: The number of characters that the drawing is most likely
# Output:
#   - The top k characters that the drawing is most likely
def find_top_k_chars(recording, rf, k=3):
    x_test, true_labels = preprocess_data(recording, with_label=False)
    
    # This is a dictionary with a unique id as key and labels as value
    id_to_char = dict(zip(range(len(rf.classes_)), rf.classes_))

    # Predict using the rf model and check accuracy
    test_prediction = rf.predict_proba(x_test)
    top_k_chars = sorted(range(len(test_prediction)), key=lambda x: test_prediction[x], reverse=True)[:k]
    return [id_to_char[e] for e in top_k_chars]
