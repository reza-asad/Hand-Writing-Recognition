from utility import find_dist
import numpy as np
import pandas as pd
from config import *
from scipy.interpolate import interp1d


# Create a class drawing_record that has methods to
# handle each record (scaling, resampling, feature 
# extraction)
class drawing_record():
    def  __init__(self, strokes):
        self.strokes = strokes
        self.features = []
        self.sample_stroke = []
        self.mint, self.minx, self.miny= [float('inf')]*3
        self.maxx, self.maxy = [float('-inf')]*2
    
    def remov_None_strokes(self):
        """
        Clean the strokes from None values
        """
        self.strokes = filter(lambda stroke: stroke is not None, self.strokes)
            
    def stroke_connect(self):
        """
        Connects two srokes if the distance betwen them
        is unusualy close
        """
        # If there is only one stroke do nothing
        if len(self.strokes) < 2:
            return
        
        connected = []
        i, n = 0, len(self.strokes)
        while i < n:
            temp = self.strokes[i]
            while i+1<n and find_dist(temp[-1], self.strokes[i+1][0]) < STOROKE_CONNECT_THERESHOLD:
                temp = temp + self.strokes[i+1]
                i+=1
            connected.append(temp)
            i += 1
        self.strokes = connected 
    
    def dehook(self, beg=False, end=False):
        """
        Removes hooks at the begining or end of a stroke
        """
        if not beg and not end:
            print 'Dehooking was not done, set beg or end to True'
            return
        # Given three points p0,p1,p2 in order, it calculates
        # the angle between p_10 and p_21
        def calculate_angle(points):
            # Return euclidean distance between two points
            def diff(v,w):
                v = np.array([v['x'], v['y']])
                w = np.array([w['x'], w['y']])
                return v-w
            p_10 = diff(points[0], points[1])
            p_21 = diff(points[1], points[2])
            # Find the cosine of the angle
            cos_angle = float(p_10.dot(p_21))/((np.sqrt(p_10.dot(p_10)) + 
                                                FACTOR_CORRECTION) * 
                                               (np.sqrt(p_21.dot(p_21)) +
                                                FACTOR_CORRECTION))
            angle = np.arccos(cos_angle) * 180/np.pi
            return angle
        
        # Dehooks at the begining
        def dehook_stroke_beg(index):
            three_points = self.strokes[i][index:index+3]
            if len(three_points) < DEHOOK_THRESHOLD:
                return
            if calculate_angle(three_points) < DEHOOK_ANGLE_THRESHOLD_BEG:
                return self.strokes[i][index:]
            else:
                return dehook_stroke_beg(index+1)

        # Dehooks at the end
        def dehook_stroke_end(index):
            three_points = self.strokes[i][index-2:index] + [self.strokes[i][index]]
            if len(three_points) < DEHOOK_THRESHOLD:
                return
            if calculate_angle(three_points) < DEHOOK_ANGLE_THRESHOLD_END:
                return self.strokes[i][:index] + [self.strokes[i][index]]
            else:
                return dehook_stroke_end(index-1)
        
        for i, stroke in enumerate(self.strokes):
            if beg:
                dehook_beg = dehook_stroke_beg(0)
                if dehook_beg is not None:
                    self.strokes[i] = dehook_beg
            if end:
                dehook_end = dehook_stroke_end(-1)
                if dehook_end is not None:
                    self.strokes[i] = dehook_end
    
    def average_smoothing(self):
        """
        Smooths every stroke using a weighted average.
        """
        smoothened = []
        for stroke in self.strokes:
            smoothened.append([stroke[0]])
            for i in range(1, len(stroke)-1):
                p = {'time':0, 'x':0, 'y':0}
                for point in [stroke[i-1], stroke[i], stroke[i+1]]:
                    p['time'] += point['time']
                    p['x'] += point['x']
                    p['y'] += point['y']
                p = dict(map(lambda (x,y): (x,int(round(y*SMOOTHING_WEIGHT,2))),
                             p.items()))
                smoothened[-1].append(p)
            smoothened[-1].append(stroke[-1])
        self.strokes = smoothened
        
    def find_bounding_box(self):
        """
        Find the bounding box of the drawing character
        """
        for stroke in self.strokes:
            for point in stroke:
                if point['time'] < self.mint:
                    self.mint = point['time']
                if point['x'] < self.minx:
                    self.minx = point['x']
                if point['y'] < self.miny:
                    self.miny = point['y']
                if point['x'] > self.maxx:
                    self.maxx = point['x']
                if point['y'] > self.maxy:
                    self.maxy = point['y']

    def scale_shift(self):
        """
        Scale and shif the coordinates of the drawing.
        Only the smaller dimension gets centered
        """
        self.find_bounding_box()
        for stroke in self.strokes:
            for point in stroke:
                width = (self.maxx-self.minx) + FACTOR_CORRECTION
                height = (self.maxy-self.miny) + FACTOR_CORRECTION
                fx = 1.0/width
                fy = 1.0/height
                f = min(fx,fy)
                add = min(width, height)/2.0 * f
                addx, addy = 0, 0
                if f == fx:
                    addx = add
                else:
                    addy = add
                point['x'] = (point['x'] - self.minx) * f - addx
                point['y'] = (point['y'] - self.miny) * f - addy
                point['time'] = point['time'] - self.mint

    def resample(self):
        """
        Use interpolation to fill in the missing x and y
        values.
        """
        resampled = []
        for stroke in self.strokes:
            if len(stroke) < RESAMPLING_STROKE_THRESHOLD:
                continue
            resampled.append([])
            x, y, t = [], [], []
            for point in stroke:
                x.append(point['x'])
                y.append(point['y'])
                t.append(point['time'])
            f_x = interp1d(t, x)
            f_y = interp1d(t, y, kind='cubic')
            time_interval = np.linspace(t[0], t[-1], num=NUM_RESAMPLE)
            for t_ in time_interval:
                p = {'time':0, 'x':0, 'y':0}
                p['time'] = t_
                p['x'] = float(f_x(t_))
                p['y'] = float(f_y(t_))
                resampled[-1].append(p)
        self.strokes = resampled
    def plot_drawing(self, strokes):
        x_val = []
        y_val = []
        for stroke in strokes:
            for point in stroke:
                x_val.append(point['x'])
                y_val.append(-point['y'])
        plt.scatter(x_val, y_val, s=200, alpha=0.4)
        plt.show(block=False)
    
    def extract_local_features(self):
        """
        This takes some global features from the drawing; e.g
        the coordinates, the curvature, recurvature.
        """
        # Finds the height of a stroke
        def stroke_height(x,y):
            return np.sqrt((x[0]-x[-1])**2 + (y[0]-y[-1])**2)
        # Finds the length of a stroke
        def stroke_length(x,y):
            return sum(np.sqrt(np.diff(x,1)**2+np.diff(y,1)**2)) 
        features = []
        for i, stroke in enumerate(self.strokes):
            if i < NUM_STROKES_AS_FEATURE:
                # This takes a sample of x,y coordinates uniformly from the stroke
                x_feature = map(lambda point: point['x'], stroke[::len(stroke)/STROKE_PARTITION])
                y_feature = map(lambda point: point['y'], stroke[::len(stroke)/STROKE_PARTITION])
                features = features + x_feature + y_feature
                
                # Add recurvature; i.e, the height of the stroke divided
                # by the length of the stroke
                x = map(lambda point: point['x'], stroke)
                y = map(lambda point: point['y'], stroke) 
                height = stroke_height(x,y)
                length = stroke_length(x,y)
                features += [height/length]

                # Add the length of the stroke as a feature
                features += [length]

        num_features = ((STROKE_PARTITION) * 2 + 2) * NUM_STROKES_AS_FEATURE
        if len(features) != num_features:
            features = features + [0] * (num_features - len(features))
        self.features = features
    def extract_global_features(self):
        """
        This takes some global features from the drawing; e.g
        the total number of strokes, aspect ratio.
        """
        # Add the number of strokes as a feature
        self.features += [len(self.strokes)]
        
        # Add the aspect ratio as a feature
        aspect_ratio = float((self.maxx-self.minx))/(self.maxy-self.miny+FACTOR_CORRECTION)
        self.features += [aspect_ratio]
                