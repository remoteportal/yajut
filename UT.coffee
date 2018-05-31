INFINITE_LOOP_DETECTION_ITERATIONS = 100



###			**MASTER**
YAJUT - Yet Another Javascript Unit Test


EXTENDS: Base

b
Promise-based, hierarchical test, minimalist and least-boilerplate, inline with source code unit test framework.

- (ut) -> vs @utMethod: the value of 'ut' parameter is that:
    - @ form is shorter
    - but using ut: a test can use closure not fat arrows (=>) to access ut properties and methods
    - but using ut: if inside a overridden child method of a sub-class: onReceive where 'this' context is the object not the ut



FEATURES
-


TODOs
- ut() to fulfill async?
- force to run all tests
- create UT and UTRunner as they *are* different, right?
- decorate section (s)
- log EVERY run to new timestamp directory with tests ran in the directory name... store ALL data
	- two files: currently enabled trace and ALL TRACE
	- auto-zip at end
	- directory: 2018-05-01 6m tot=89 P_88 F_1 3-TestClient,Store,DeathStar TR=UT_TEST_POST_ONE_LINER,ID_TRANSLATE.zip
		traceSelected.txt
		traceAll.txt
		src/...
- if run all TESTS report how many are disabled _
- change ut to t
- target=NODE_SERVER command line switch
- put cleanup in opts  but that means @client and @server or implement our own timeout mechanism, again, inside here:
- onPost -> @testHub.directoryRemoveRecursiveForce()
- actually:  @testHub.directoryGetTempInstanceSpace
- test auto-discovery so don't need to explicity list in tests.coffee
- add @rnd() functions
- add milepost functionality
- validate system-level options parameter names
- validate per-unit test on-the-fly options for mispellings


KNOWN BUGS:
-
###





#if node
fs = require 'fs'


A = require './A'
Base = require './Base'
O = require './O'
trace = require './trace'
util = require './Util'
V = require './V'








bHappy = true
g_timer = null
path = ''
testStack = []
testList = []
testIndex = null
bRunning = null
iterations = null
testListSaved = null
t_depth = 0

pass = fail = 0
bRan = false

msStart = null



bag = Object.create
	clear: ->
		for k of bag
			unless k is "clear"
				delete bag[k]
		return


target = (cmdUNUSED_TODO) ->
	if trace.UT_BAG_DUMP
	#	console.log "HI: cmd=#{cmdUNUSED_TODO}"
		sans = Object.assign {}, bag
		delete sans.clear

		O.LOG sans		#NOT-DEBUG

		if _=O.CNT_OWN sans
			console.log "*** bag: #{_} propert#{if _ is 1 then "y" else "ies"}:"
			for k,v of sans
				console.log "*** bag: #{k} = #{V.DUMP v}"
		else
			console.log "*** bag: empty"
		return


handler =	# "traps"
	get: (target, pn) ->
		bag[pn]

	set: (target, pn, pv) ->
		console.log "proxy: set: #{pn}=#{pv} <#{typeof pv}>"										if trace.UT_BAG_SET
		throw "clear is not appropriate" if pn is "clear"
		bag[pn] = pv


proxyBag = new Proxy target, handler


decorate = (test, fn, objectThis) ->
	unless fn
		console.error "#{test.tn}: function body is required"
#if node
		process.exit 1
#endif

	me2 = Object.create objectThis

	decorateJustObject test, me2

#	console.log "*** bRunToCompletion=#{me2.bRunToCompletion}"

	fn2 = fn.bind me2




decorateJustObject = (test, me2) ->
	me2.tn = test.tn

	me2.opts = test.opts

	me2.bag = proxyBag

	me2.context		= "CONTEXT set in decorateJustObject"





	#METHODS
	me2.assert = (b, msg) ->
		_ = if msg then ": #{msg}" else ""

		@logSilent "assert: b=#{b}#{_}"

		if b
			pass++
		else
			@log "ASSERTION FAILURE#{_}"
			fail++

		b


	#TODO: create V.EQ routine
	me2.eq = ->
		bEQ = true

		@logSilent "inside eq: arguments.length=#{arguments.length}"

#		@log "ut: bRunToCompletion=#{@bRunToCompletion}"

		if arguments.length >= 2
			@logSilent "arguments passed: arguments.length=#{arguments.length}"


			# both undefined?
			#TODO: check all args
			if !(arguments[0]?) and !(arguments[1]?)
				@logSilent "both undefined"
				return


			# TYPES
			bEQ = true
			_ = V.TYPE arguments[0]
			for i in [0..arguments.length-1]
				@logSilent "arg#{i}: #{V.PAIR arguments[i]} #{typeof arguments[i]}"

				unless _ is V.TYPE arguments[i]
					bEQ = false

			unless bEQ
				s = "@eq types violation:\n"
				for i in [0..arguments.length-1]
					s += "> arg#{i}: #{V.TYPE arguments[i]}\n"
#				@log "ut2: bRunToCompletion=#{@bRunToCompletion}"
				@logError s


			if bEQ
				# VALUES
				bEQ = true
				_ = arguments[0]
				for i in [0..arguments.length-1]
					@logSilent "arg#{i}: #{V.PAIR arguments[i]} #{typeof arguments[i]}"

					#WARNING: old code used to sometime hang node; it was very bizarre
					unless _ is arguments[i]	#H
						bEQ = false

				unless bEQ
					s = "@eq values violation:\n"
					for i in [0..arguments.length-1]			#H: these lines cause a hang!
						s += "> arg#{i}: #{V.PAIR arguments[i]}\n"
					@logError s
		else
			throw new Error "eq: must pass at least two arguments"

		if bEQ
			pass++
		else
#			@log "fail++"
			fail++

		bEQ

	me2.fail = (msg) ->
		fail++
		if msg
			@logError msg
		false		# so cal call @fail as last statement of onException, onTimeout, etc.


	me2.fatal = (msg) ->
#		console.error "fatal: #{msg}"

		clearInterval g_timer
		bHappy = false
		bRunning = false
		util.exit msg


	#DUP
	#TODO: manufacture?
	me2.log			= (s, o, opt)		->
#		console.log "*********** s=#{s}"
#		console.log "*********** o=#{o}"
#		console.log "*********** opt=#{opt}"
		if trace.UT_TEST_LOG_ENABLED
			util.logBase "#{test.cname}/#{test.tn}", s, o, opt

	me2.logError	= (s, o, opt)		->
#		console.log "logError: bRunToCompletion=#{@bRunToCompletion}"

		if @bRunToCompletion
			util.logBase "#{test.cname}/#{test.tn}", "ERROR: #{s}", o, opt
		else
			util.logBase "#{test.cname}/#{test.tn}", "FATAL_ERROR: #{s}", o, opt
			util.exit "logError called with @bRunToCompletion=false"
	me2.logCatch	= (s, o, opt)		->
		if @bRunToCompletion
			util.logBase "#{test.cname}/#{test.tn}", "CATCH: #{s}", o, opt
		else
			util.logBase "#{test.cname}/#{test.tn}", "FATAL_CATCH: #{s}", o, opt
#if node
			process.exit 1
#endif
	me2.logFatal	= (s, o, opt)		->
		util.logBase "#{test.cname}/#{test.tn}", "FATAL: #{s}", o, opt
		util.exit()

	me2.logSilent	= (s, o, opt)		-> util.logBase "#{test.cname}/#{test.tn}", s, o, bVisible:false

	me2.logTransient = (s, o, opt)		->
		if @bRunToCompletion
			util.logBase "#{test.cname}/#{test.tn}", "TRANSIENT: #{s}", o, opt
		else
			util.logBase "#{test.cname}/#{test.tn}", "FATAL_TRANSIENT: #{s}", o, opt
			util.exit "logError called with @bRunToCompletion=false"

	me2.logWarning	= (s, o, opt)		->	util.logBase "#{test.cname}/#{test.tn}", "WARNING: #{s}", o, opt

	me2.pass = ->
		pass++
		true			# so can call @pass() as last statement of onException, onTimeout, etc.




aGenerate = (cmd) =>
	(tn, fn) ->
#		console.log "$$$$$$$$$$$$$0 #{arguments[0]}"
#		console.log "$$$$$$$$$$$$$1 #{arguments[1]}"
#		console.log "$$$$$$$$$$$$$2 #{arguments[2]}"
#		console.log "$$$$$$$$$$$$$3 #{arguments[3]}"

		if Object::toString.call(fn) is '[object Object]'
			opts = fn
#			O.LOG "args", arguments
#			O.LOG "found", opts
#			O.LOG arguments[2]
			fn = arguments[2]

		if bRunning and t_depth is 1
			@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
		#		@log "found async: #{tn} --> #{@__CLASS_NAME}"

		testList.unshift
			bEnabled: false
			cmd: cmd
			cname: @__CLASS_NAME
			tn: tn
			fn: fn
			opts: opts
			path: "#{@__CLASS_NAME}#{path}/#{tn}"


testGenerate = (cmd) =>
	(tn, fn) ->
		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		if bRunning
			if ++t_depth is 2
				@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
			fn()
			--t_depth
		else
#			console.log "found test: #{tn}: cmd=#{cmd}"

			testList.unshift
				bEnabled: false
				cmd: cmd
				cname: @__CLASS_NAME
				tn: tn
				fn: fn
				opts: opts
				path: "#{@__CLASS_NAME}#{path}/#{tn}"


sectionGenerate = (cmd) =>
	(tn, fn) ->
		throw 0 unless typeof tn is "string"
		throw 0 unless typeof fn is "function"

		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		if bRunning and t_depth is 1
			@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"

#		@log "found section: #{tn}"
		testStack.push tn

		path = '/' + testStack.join '/'
#		console.log "sectionGenerate: #{path}"

#		testList.unshift
#			bEnabled: false
#			cmd: cmd
#			cname: @__CLASS_NAME
#			tn: tn
#			fn: fn
#			opts: opts
#			path: path

		fn.bind(this)
			tn: tn

		testStack.pop()




#H: overloaded between UT runner and superclass
module.exports = class UT extends Base
	constructor: (@bRunToCompletion, @fnCallback, @opts = {}, @WORK_AROUND_UT_CLASS_NAME_OVERRIDE) ->
		super "I DO NOT UNDERSTAND WHY I CANNOT PASS @__CLASS_NAME HERE and I don't know why it works when I don't!!!"
#		@log "bRunToCompletion=#{@bRunToCompletion}"
#		O.LOG @opts
		@__CLASS_NAME = @WORK_AROUND_UT_CLASS_NAME_OVERRIDE ? @constructor.name
		testIndex = "pre"
		bRunning = false


	#COMMAND: asynchronous test
	_A: (a, b, c) ->
	_a: (a, b, c) ->
	A: (a, b, c) -> aGenerate('A').bind(this) a, b, c
	a: (a, b, c) -> aGenerate('a').bind(this) a, b, c


	#COMMAND: section / directory of tests
	_S: (a, b, c) ->
	_s: (a, b, c) ->
	S: (a, b, c) -> sectionGenerate('S').bind(this) a, b, c
	s: (a, b, c) -> sectionGenerate('s').bind(this) a, b, c


	#COMMAND: synchronous test
	_T: (a, b, c) ->
	_t: (a, b, c) ->
	T: (a, b, c) -> testGenerate('T').bind(this) a, b, c
	t: (a, b, c) -> testGenerate('t').bind(this) a, b, c



	next: ->
		unless bRunning
			return

		objectThis = this

		#H: is this while loop even used anymore?
		while testIndex < testList.length
			if iterations++ > INFINITE_LOOP_DETECTION_ITERATIONS
				@logFatal "infinite loop detected (stopped at #{iterations} iterations)"

#			@log "#{testListSaved} VS #{testList.length}"
			if testListSaved isnt testList.length
				@logFatal "testList corruption"

			test = testList[testIndex]

			test.opts = Object.assign {}, @opts, @opts?.perTestOpts?[test.cname], test.opts
			delete test.opts.perTestOpts
#			O.LOG "next.opts:", test.opts

			# iter=#{iterations}
#			@log "================== ##{testIndex+1}/#{testList.length} #{test.cname} #{test.cmd}:#{test.tn}#{if trace.DETAIL then ": path=#{test.path}" else ""}"			if trace.UT_TEST_PRE_ONE_LINER
			@log "================== ##{testIndex+1} #{test.path}"			if trace.UT_TEST_PRE_ONE_LINER or 1

			if test.bRun
				@logFatal "already run!"
			else
				test.bRun = true

			switch test.cmd
				when 'a', 'A'
					handle = null

					pr = new Promise (resolve, reject) =>
#						@log "ASYNC #{test.cname} #{test.tn} PATH=#{test.path}"	# type=#{typeof test.fn} fn=#{test.fn}"

						fn2 = decorate test, test.fn, objectThis

						utParameter =
							resolve: resolve
							reject: reject

						decorateJustObject test, utParameter

#						O.LOG utParameter
						ms = utParameter.opts.timeout
#						@log "setting timer: #{ms}ms"
						handle = setTimeout =>
								bExpectTimeout = false

								if test.opts.onTimeout?
									utParameter = {}

									decorateJustObject test, utParameter

									fnBoundObjectThis = decorate test, test.opts.onTimeout, objectThis
									bExpectTimeout = fnBoundObjectThis utParameter
#									@log "a: bExpectTimeout=#{bExpectTimeout}"

								if bExpectTimeout or test.opts.expect is "TIMEOUT"
									resolve()
									return


								@log "TIMEOUT (#{ms}ms) in \"#{test.cname}/#{test.tn}\""
								fail++
								reject "TIMEOUT"
							,
								ms

						try
							fn2 utParameter
						catch ex
							clearTimeout handle
							@logCatch "a/A exception in '#{test.cname}/#{test.tn}' DOES THIS EVER HAPPEN?", ex
							unless @bRunToCompletion
								process.exit 1
					.then =>
						clearTimeout handle
						pass++
						@post "a-then"
					.catch (ex) =>
						clearTimeout handle
#						if ex is "TIMEOUT" and test.opts.expect is "TIMEOUT"
#							pass++
#							@post "a-expect-TIMEOUT"
						unless ex is "TIMEOUT"
							fail++
							@logCatch "a-cmd", ex
						unless @bRunToCompletion
							process.exit 1
						@post "a-catch"
					return		#IMPORTANT
				when 't', 'T'
					# @log "RUNNING #{test.tn} PATH=#{test.path} pass=#{pass} fail=#{fail}"#" #{test.fn}"
					passSave = pass			#TODO: do for asynch, too
					failSave = fail
					try
						#TODO: pass in node arguments, too

						if ++t_depth is 2
							@logFatal "[#{test.path}] nested tests"

						utParameter = {}

						decorateJustObject test, utParameter

						#TODO: also have coffeeScript scan for documentation if -doc flag passed or whatever
						@fnCallback? "pre", "t", utParameter, objectThis

#						O.LOG "objectThis", objectThis

						fnBoundObjectThis = decorate test, test.fn, objectThis
						fnBoundObjectThis utParameter		#RV_IGNORE

#						@log "back from test"

						if fail > failSave and test.opts.expect is "EXCEPTION"
#							@log "restore: eliminate: pass=#{pass} fail=#{fail}"
							pass = passSave
							fail = failSave

#						@log "lll"

						@fnCallback? "post", "t", utParameter, objectThis

#						@log "say something meaningful here"										if trace.UT_TEST_POST_ONE_LINER	#TODO

						if pass is passSave
							# implicit pass
							pass++

						--t_depth
						@post "t"		#WARNING: could cause very deep stack
					catch ex
#						@log "t-catch ------", ex		#URGENT #TODO: move the try/catch exactly around the t-function call!

						--t_depth

						bExpectException = false

						#TODO: put stuff in common routine
						if test.opts.onException?
							utParameter = {}

							decorateJustObject test, utParameter

							fnBoundObjectThis = decorate test, test.opts.onException, objectThis
							bExpectException = fnBoundObjectThis utParameter
#							@log "t: bExpectException=#{bExpectException}"

						if bExpectException or test.opts.expect is "EXCEPTION"
#							@log "restore: eliminate: pass=#{pass} fail=#{fail}"
							pass = passSave
							fail = failSave			# restore fail's from eq failures

							if pass is passSave
								# implicit pass
								pass++
							@post "t-catch"
						else
							fail++
							@logCatch "[#{test.path}] t-handler", ex
							@post "t-catch"
					return
				when 's', 'S'
#					@log "here1"
					@post "s"
#					@log "here2"
					return
				else
					@logFatal "unknown cmd=#{test.cmd}"
#			@log "bottom of while"
#		@log "UT-DONE ##{testIndex}/#{testList.length}"


	post: (who) ->
		if ++testIndex is testList.length
#			@log "UT-DONE: who=#{who}"
			bRunning = false
		else
#			@log "post: next: who=#{who}"
			@next()
#			if g_timer
#				@next()
#			else
#				console.error "g_timer is null"


	run: (@testHub) ->			#H: UT should know NOTHING about "TestHub"
		new Promise (resolve, reject) =>
			throw 0 if bRunning
			throw 0 if bRan
			bRan = true
			msStart = Date.now()

#			@log "run: test count=#{testList.length} CLOUD=#{@testHub.c.CLOUD}"

			if testList.length > 0
				testList.reverse()

				testIndex = 0
				while testIndex < testList.length
					test = testList[testIndex]
	#				@log "pre: ##{testIndex} #{test.cmd}:#{test.tn}: #{test.path}"
					testIndex++

				testIndex = 0
				bRunning = true
				iterations = 0

				bFoundOverride = false
				testList.forEach (test) =>
					if /^[A-Z]/.test test.cmd
#						@log "found ut override: #{test.tn}"
						test.bEnabled = true
						bFoundOverride = true

				testListSaved = testList.length

				if bFoundOverride
					testList = testList.filter (test) => test.bEnabled
#					console.log "FIRST"
#					@log "test", a:"a", false
#					@log "test", a:"a", true
#					@log "ONE", "TWO", "THREE"
#					util.abort "NOW"

#					fn = (a, b) ->
#						O.LOG arguments
#					fn "a", "b"
					@log "Found #{testListSaved} test#{if testListSaved is 1 then "" else "s"}, but also #{testList.length} override#{if testList.length is 1 then "" else "s"}"

				if testList.length > 0
					testListSaved = testList.length

					@next()

					#HACK: utilize this timer to keep node running until all tests have completed
					g_timer = setInterval =>
							unless bRunning
								if bHappy
									secs = Math.ceil((Date.now() - msStart) / 1000)
									@log "======================================================"
									@log "all unit tests completed: [#{secs} second#{if secs is 1 then "" else "s"}] total=#{pass+fail}: #{unless fail then "PASS" else "pass"}=#{pass} #{if fail then "FAIL" else "fail"}=#{fail}"
									clearInterval g_timer
									if fail
										resolve "[#{secs}s] fail=#{fail}"
									else
										resolve "[#{secs}s] pass=#{pass}"
						,
							100

	stackReset: ->
		testStack.length = 0
		path = ''


#if ut
	@ut: (testHub) ->
#		@log "CLOUD=#{testHub.c.CLOUD}"
		new UTUT().run testHub
#endif












class UTUT extends UT
	run: ->
		@t "UT events", (ut) ->
			@eq ut.say_hi_to_peter, "Hi Pete!"

			@testHub.startClient "/tmp/ut/UTUT"
#			.then (client) =>
#				@log "one: #{client.one}"
			.catch (ex) =>
				@logCatch "startClient", ex		#H: logCatch WHAT should be the parameter?
		@t "opts", (ut) ->
#			O.LOG "ut.opts=", ut.opts
			@eq ut.opts.aaa, "AAA"
#			O.LOG "@opts=", @opts
			@eq @opts.aaa, "AAA"
		@t "empty log", ->
			@log "pre"
			@log()
			@log()
			@log()
			@log "post"
		@s "bag", ->
			@t "set", ->
				@bag()
				@bag.color = "red"
				@bag()
			@t "get", ->
				@bag()
				@eq @bag.color, "red"
				@bag.clear()
				@eq @bag.color, undefined
				@bag()
			@t "clear invalid", ->
				try
					@bag.clear = "this should fail"
					@fail "it's illegal to assign 'clear' to bag"
				catch ex
					@pass()
		@s "sync nesting test", ->
#			@log "SYNC"
#			t = 0
#			@log "div 0"
#			t = t / t
#			O.LOG this
#			@log "hello"
			@s "a", (ut) =>
#				@log "section log"
#				@logError "section logError"
#				@logCatch "section logCatch"

				@s "b1", (ut) ->
					@t "b1c1", (ut) ->
#						@log "test log"
#						@logError "test logError"
#						@logCatch "test logCatch"
					@t "b1c2", (ut) ->
				@s "b2", (ut) ->
					@s "b2c1", (ut) ->
						@t "b2c1d1", (ut) ->
		@s "async nesting test", (ut) ->
			@s "a", (ut) ->
				@s "b1", (ut) ->
					@a "b1c1", (ut) ->
						setTimeout (=> ut.resolve()), 3000
					#						@log "setTimeout"
					#						@log "asynch log"
					#						@logError "asynch logError"
					#						@logCatch "asynch logCatch"
					@a "b1c2", (ut) ->
						ut.resolve()
				@s "b2", (ut) ->
					@s "b2c1", (ut) ->
						@a "b2c1d1", (ut) ->
							ut.resolve()
		@t "opts parameter", {timeout:1000,a:"a"}, (ut) ->
#			@log "opts parameter"
#			O.LOG ut.opts
			@eq ut.opts.timeout, 1000
		@a "promise timeout", {timeout:100, expect:"TIMEOUT"}, (ut) ->
#			DO NOT CALL ut.resolve()
		@a "onTimeout", {
				timeout:100
				onTimeout: (ut) ->
					@log "onTimeout called: #{ut.opts.timeout}=#{@opts.timeout}"
					true
			}, (ut) ->
				@log "do not call ut.resolve to force timeout"
		@s "eq", ->
			@t "single parameter", {
				onException: (ut, ex) ->
#					@log "in onException"
					@pass()
			}, ->
				@eq "I feel alone"

			@t "differing types", {expect:"EXCEPTION"}, ->
#				@log "in test: *** bRunToCompletion=#{@bRunToCompletion}"
				@eq "peter", new String "peter"
		@_t "fatal", {comment:"can't test because it exits node",bManual:true,peter:"alvin"}, ->
			#TODO: skip if bManual is true
			@fatal()
			@fatal "display me on console"
		@t "assert", {expect:"EXCEPTION"}, ->
			@log "hello"

			@assert true, "Saturday"
			@assert false, "Sunday"












#endif