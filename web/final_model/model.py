# imports
import pandas as pd
from config import NUM_TREES
from sklearn.ensemble import RandomForestClassifier
from sknn.mlp import Classifier, Layer

# Random Forrest Model
def rf_model(x, y):
    # Run the random forrest model using the best number of trees
    # On the validation set
    rf = RandomForestClassifier(n_estimators=NUM_TREES, oob_score=True)
    rf.fit(x, y)
    return rf

# Neural Network Model
def nn_model(x, y):
    nn = Classifier(
    layers=[
        Layer("Sigmoid", units=500),
        Layer("Sigmoid", units=500),
        Layer("Softmax")],
    learning_rate=0.008,
    weight_decay = 0.0001,
    dropout_rate=0.1,
    n_iter=400)
    nn.fit(x.as_matrix(), y)
    return nn