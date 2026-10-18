"""Optional external CPU cost atlas. Requires py65 and Pillow."""
from pathlib import Path
import runpy,sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'work'))
runpy.run_module('mode8.analyze',run_name='__main__')
