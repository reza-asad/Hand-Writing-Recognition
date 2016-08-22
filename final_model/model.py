# imports
import pandas as pd
from config import NUM_TREES
from sklearn.ensemble import RandomForestClassifier
import os

# This reads the preprocessed data
dir = os.path.dirname(os.getcwd())
data_path = dir+'/model_evaluation/data'
data = pd.read_pickle(data_path)

def rf_model(data):
	# Run the random forrest model using the best number of trees
	# On the validation set
	rf = RandomForestClassifier(n_estimators=NUM_TREES, oob_score=True)
	rf.fit(data.drop('response', axis=1), data['response'])
	return rf
