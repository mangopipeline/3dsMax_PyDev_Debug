global pydev_debug = undefined
struct PyDevRemoteDebugHelper
(
	ro,

	fn debug_code pytext =
	(
		tempdir = (getdir #temp)+@"\python_debug"
		
		if  (doesDirectoryExist tempdir) == False then 
			makeDir tempdir 
		
		filename = tempdir+@"\_debug_code.py"
		strm = openfile filename mode:"w"
		format pytext to:strm 
		close strm 
		py_sys = python.import "sys"
		
		--make sure we can edit debug script....
		paths = py_sys.path as array
		
		home_dir =  getFilenamePath (getThisScriptFilename())
		pydev_dir = home_dir + "pydev_source"
		
		for npath in #( pydev_dir,home_dir,tempdir) do
		(
			if  finditem paths npath == 0 then
				py_sys.path.insert 0 npath 
		)

		pydev_debug = python.import  "debug3dsmax"
		python.reload(pydev_debug)
		pydev_debug.start_debug()
		python.import "_debug_code"
		--"import debug3dsmax\ndebug3dsmax.startDebug()\nimport _debug_code" 
	),
	fn ui =
	(
		rollout ro01 "Debug Code" width:500
		(
			local self 
			edittext code "" height:400
			button debug "Debug Code" width:(ro01.width-20) 
			fn init pself = self= pself
			on debug pressed do  self.debug_code code.text
		)
		ro01
	),
	fn run =
	(
		this.ro = this.ui()
		CreateDialog this.ro
		this.ro.init this
	)
)

try(DestroyDialog PyDevRDHlp.ro)catch()
PyDevRDHlp = PyDevRemoteDebugHelper()
PyDevRDHlp.run()