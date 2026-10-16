"""Optional native stock x64sc complete-view qualification."""
from pathlib import Path
import runpy,sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'work'))
runpy.run_module('mode8.native',run_name='__main__')
