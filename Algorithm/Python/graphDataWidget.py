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
            settings =json.load(settingsjson)
 
        DS1 =  np.loadtxt(settings["DS1File"],delimiter=',', usecols = settings["DS1Col"])
        DS1 = DS1[ settings["DS1Fileskip"] : settings["DS1File_end"] ]
        
        DS2 =  np.loadtxt(settings["DS2File"],delimiter=',', usecols = settings["DS2Col"])
        DS2 = DS2[ settings["DS2Fileskip"] : settings["DS2File_end"] ]
        
        DS3 =  np.loadtxt(settings["DS3File"],delimiter=',', usecols = settings["DS3Col"])
        DS3 = DS3[ settings["DS3Fileskip"] : settings["DS3File_end"] ]
        
        super().__init__()
        self.resize(1000, 600)
        self.setWindowTitle("ECG Stream")
        
        pg.setConfigOption('background', 'white')
        pg.setConfigOption('foreground', 'black')
        vLine = pg.InfiniteLine(angle=90, movable=True)
        #hLine = pg.InfiniteLine(angle=0, movable=True)
  
        plotwg1 = pg.PlotWidget()
        plotwg1.addItem(vLine, ignoreBounds=True)
        proxy = pg.SignalProxy(plotwg1.scene().sigMouseMoved, rateLimit=60, slot=self.mouseMoved)
        vb = plotwg1.vb
        
        plotwg1.setLabel('top', 'DS1')
        plotwg1.setLabel('left', 'Raw ADC')
        plotwg1.setLabel('bottom', 'Time')
        
        plotwg2 = pg.PlotWidget()
        plotwg2.setLabel('top', 'DS2')
        plotwg2.setLabel('left', 'Raw ADC')
        plotwg2.setLabel('bottom', 'Time')
        
        plotwg3 = pg.PlotWidget()
        plotwg3.setLabel('top', 'DS3')
        plotwg3.setLabel('left', 'Raw ADC')
        plotwg3.setLabel('bottom', 'Time')
        
        plotwg1.plot(title="ECG Data", y=DS1, pen=(255,0,0))
        plotwg2.plot(title="ECG Data", y=DS2,pen=(255,0,0))
        plotwg3.plot(title="ECG Data", y=DS3,pen=(255,0,0))

        layout = QGridLayout(self)
        layout.addWidget(plotwg1, 0, 1)
        layout.addWidget(plotwg2, 1, 1)
        layout.addWidget(plotwg3, 2, 1)
        
    def mouseMoved(evt):
        pos = evt[0]  ## using signal proxy turns original arguments into a tuple
        print(mousePoint.x())
        
        
app = QApplication(sys.argv)
window = Window()
window.show()
sys.exit(app.exec())        
