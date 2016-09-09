import numpy as np

# Examining some feature enhancements.
def center_scale(df):
    # Center the data
    df = df - df.mean(axis=0)
    
    # Scale the data
    df = df / (df.max(axis=0) - df.min(axis=0))

# Find the distribution distance between strokes
def find_dist(x,y):
    x = np.array([x['x'], x['y']])
    y = np.array([y['x'], y['y']])
    return np.sqrt(sum((x-y)**2))

# This return the top %x error    
def top_k_prediction(prediction, id_to_char, k=3):
	all_top_k_chars = []
	for row in prediction:
	    top_k_chars = sorted(range(len(row)), key=lambda x: row[x], reverse=True)[:k]
	    all_top_k_chars.append([id_to_char[e] for e in top_k_chars])
	return all_top_k_chars
