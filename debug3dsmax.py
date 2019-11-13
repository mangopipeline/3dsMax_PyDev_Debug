import sys, imp, __builtin__
import pydevd


def start_debug():
    global G_MAX_IMP_CON
    pydevd.settrace()
    G_MAX_IMP_CON = MaxImportController()


import zipimport
def maxPythonZip( m1 ):
    importer = zipimport.zipimporter('python26.zip')
    for m1 in ['zipimport_get_code', 'zipimport_get_source']:
        source = importer.get_source( m1)
    return source


class MaxImportController(object):
    singleton = None

    def __new__(cls, *args, **kwargs):
        if not cls.singleton:
            cls.singleton = super(MaxImportController, cls).__new__(cls, *args, **kwargs)
            # Creates an instance and installs as the global importer
            cls.singleton.previousModules = sys.modules.copy()
            cls.singleton .__import__ = __builtin__.__import__
            __builtin__.__import__ = cls.singleton ._import_
            cls.singleton.newModules = {}
        return cls.singleton
    
    def __init__(self):
        pass
        
    def _import_(self, name, globals=None, locals=None, fromlist=[], level=-1):
        if self.newModules.has_key(name):
            if not self.previousModules.has_key(name):
                # Force reload when name next imported
                del(sys.modules[name])
        result = apply(self.__import__, (name, globals, locals, fromlist))
        self.newModules[name] = 1
        return result
        
    def uninstall(self):
        for name in self.newModules.keys():
            if not self.previousModules.has_key(name):
                # Force reload when name next imported
                del(sys.modules[name])
        __builtin__.__import__ = self.__import__
