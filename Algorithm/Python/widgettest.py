from PyQt6.QtWidgets import QApplication, QWidget, QPushButton, QLineEdit, QListWidget
from PyQt6.QtWidgets import QGridLayout
from PyQt6.QtCore import Qt

import sys
import pyqtgraph as pg
import numpy as np
import json

class Window(QWidget):
    def __init__(self):
        
        #import settings
        with open('settings.json','r') as settingsjson:
            settingsData =json.load(settingsjson)
        filename = settingsData["ECGFile"] 
        data =  np.loadtxt(filename,delimiter=',', usecols = 1)

        
        super().__init__()
        self.resize(1000, 600)
        self.setWindowTitle("ECG Stream")
        btn = QPushButton('press me')
        text = QLineEdit('enter text')
        listw = QListWidget()
        
        plotwg1 = pg.PlotWidget()
        plotwg2 = pg.PlotWidget()
        plotwg3 = pg.PlotWidget()
        plotwg1.plot(title="ECG Data", y=data)
        plotwg2.plot(title="ECG Data", y=data)
        plotwg3.plot(title="ECG Data", y=data)
        layout = QGridLayout(self)
        layout.addWidget(plotwg1, 0, 1)
        layout.addWidget(plotwg2, 1, 1)
        layout.addWidget(plotwg3, 2, 1)
        layout.addWidget(text,3,1)
        
        
app = QApplication(sys.argv)
window = Window()
window.show()
sys.exit(app.exec())        
