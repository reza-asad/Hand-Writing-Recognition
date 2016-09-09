# imports
import pandas as pd
from config import NUM_TREES
from sklearn.ensemble import RandomForestClassifier

def rf_model(x, y):
    # Run the random forrest model using the best number of trees
    # On the validation set
    rf = RandomForestClassifier(n_estimators=NUM_TREES, oob_score=True)
    rf.fit(x, y)
    return rf
