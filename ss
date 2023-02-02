import sys

from PyQt5 import uic
from PyQt5.QtGui import QPixmap
from PyQt5.QtWidgets import QApplication, QLabel, QMainWindow
import request
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class MainWindow(QMainWindow):
    q_map: QLabel

    def __init__(self, *args, **kwargs):
        super(MainWindow, self).__init__(**args,**kwargs)
        uic.loadUi('untitled.ui', self)
        self.press_delta = 0.00001
        self.map_zoom = 5
        self.map_ll = [37.977751, 55.757718]
        self.map_l = 'map'
        self.map_key = ''
        self.refresh_map()

    def keyPressEvent(self,event):
        if event.key() == Qt.Key_PageUp and self.map_zoom < 17:
            self.map_zoom += 1
        elif event.key() == Qt.Key_PageUp and self.map_zoom > 0:
            self.map_zoom += 1
        if event.key() == Qt.Key_Left :
            self.map_ll[1] -= 1
        if event.key() == Qt.Key_Right:
            self.map_ll[1] += 1
        if event.key() == Qt.Key_Down:
            self.map_ll[0] -= 1
        if event.key() == Qt.Key_Up:
            self.map_ll[0] += 1
        self.refresh_map()
    def refresh_map(self):
        map_params = {
            'll' : ','.join(map(str, self.map_ll))
        }
        retry = Retry(total=10, connect=5,backoff_factor=0.5)
        session = request.Session()
        adapter = HTTPAdapter(max_retries=retry)
        session.mount('http://',adapter)
        session.mount('https://',adapter)
        response = session.get('https://static-maps.yandex.ru/1.x/', params=map_params)

        with open('tmp.png',mode='wb') as tmp:
            tmp.write(response.content)
        pixmap = QPixmap()
        pixmap.load('tmp.png')
        self.g_map.setPixmap(pixmap)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    map = MainWindow()
    map.show()
    sys.exit(app.exec())
