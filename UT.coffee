INFINITE_LOOP_DETECTION_ITERATIONS = 100


#if node
fs = require 'fs'

A = require './A'
Base = require './Base'
O = require './O'
util = require './Util'
trace = require './trace'
V = require './V'



#TODO
# - make capital to only run THAT test
# - ut() to fulfill async?
# - force to run all tests
# - create UT and UTRunner as they *are* different, right?
# - decorate section (s)
# - log EVERY run to new timestamp directory with tests ran in the directory name... store ALL data
# 		- two files: currently enabled trace and ALL TRACE
#		- auto-zip at end
#		- directory: 2018-05-01 6m tot=89 P_88 F_1 3-TestClient,Store,DeathStar TR=UT_TEST_POST_ONE_LINER,ID_TRANSLATE.zip
#			traceSelected.txt
#			traceAll.txt
#			src/...
# - if run all TESTS report how many are disabled _
# - change ut to t










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

		O.DUMP sans		#NOT-DEBUG

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



decorate = (test, objectThis) ->
	me2 = Object.create objectThis

	me2.bag = proxyBag

	me2.context		= "CONTEXT"

	me2.eq = ->
#		@log "inside eq"

		if arguments.length
#			@log "arguments passed: arguments.length=#{arguments.length}"
			_ = arguments[0]
#			@log "arguments passed2"

			# both undefined?
			if !(arguments[0]?) and !(arguments[1]?)
#				@log "both undefined"
				return

#			throw "FORCED THROW: eq failure" if arguments[0] isnt arguments[1]
			for i in [0..arguments.length-1]			#H: these lines cause a hang!
#				@log "arg#{i}: #{arguments[i]}"

				#WARNING: sometimes hangs node
				unless _ is arguments[i]	#H
					@logError "#{_}"
					@logError "#{arguments[i]}"
#										throw "eq fail"
#		@log "eq: done: args=#{arguments.length}"
		return

	me2.fail = (msg) ->
		fail++
		if msg
			@logError msg


	#DUP
	me2.log			= (s, o, opt)		=>
		if trace.UT_TEST_LOG_ENABLED
			util.logBase "#{test.cname} - #{test.tn}", s, o, opt
	me2.logError	= (s, o, opt)		=>
		if @bRunToCompletion
			util.logBase "#{test.cname} - #{test.tn}", "ERROR: #{s}", o, opt
		else
			util.logBase "#{test.cname} - #{test.tn}", "FATAL_ERROR: #{s}", o, opt
#if node
			process.exit 1
#endif
	me2.logCatch	= (s, o, opt)		=>
		if @bRunToCompletion
			util.logBase "#{test.cname} - #{test.tn}", "CATCH: #{s}", o, opt
		else
			util.logBase "#{test.cname} - #{test.tn}", "FATAL_CATCH: #{s}", o, opt
#if node
			process.exit 1
#endif
	me2.logFatal	= (s, o, opt)		=>
		util.logBase "#{test.cname} - #{test.tn}", "FATAL: #{s}", o, opt
#if node
		process.exit 1
#endif
	me2.logWarning	= (s, o, opt)		=>	util.logBase "#{test.cname} - #{test.tn}", "WARNING: #{s}", o, opt

	me2.pass = ->
		pass++

	fn2 = test.fn.bind me2




aGenerate = (cmd) =>
	(tn, fn) ->
		if bRunning and t_depth is 1
			@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
		#		@log "found async: #{tn} --> #{@name}"
		testList.unshift
			bEnabled: false
			cmd: cmd
			cname: @name
			tn: tn
			fn: fn
			path: path


testGenerate = (cmd) =>
	(tn, fn) ->
		if bRunning
			if ++t_depth is 2
				@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
			fn()
			--t_depth
		else
#			@log "found test: #{tn}: cmd=#{cmd}"

			testList.unshift
				bEnabled: false
				cmd: cmd
				cname: @name
				tn: tn
				fn: fn
				path: path


sectionGenerate = (cmd) =>	#TRY
	(tn, fn) ->
		throw 0 unless typeof tn is "string"
		throw 0 unless typeof fn is "function"
		if bRunning and t_depth is 1
			@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
		#		@log "found section: #{tn}"
		testStack.push tn
		path = '/' + testStack.join '/'
		testList.unshift
			bEnabled: false
			cmd: cmd
			cname: @name
			tn: tn
			fn: fn
			path: path

		#		fn
		#			tn: tn
		fn.bind(this)
			tn: tn
		testStack.pop()





module.exports = class UT extends Base
	constructor: (@bRunToCompletion, @fnCallback) ->
		super "I DO NOT UNDERSTAND WHY I CANNOT PASS @name HERE and I don't know why it works when I don't!!!"
#		@log "@@@@ #{constructor.name}"	# Object
#		@log "@@@@ #{@constructor.name}"	# Object
#		@log "name=#{@name}"
		# @log "bRunToCompletion=#{@bRunToCompletion} HELP"
		@name = @constructor.name	#+ "(UT)"			#H: @name is way to common #RENAME
		testIndex = "pre"
		bRunning = false


	#COMMAND: asynchronous test
	_a: (tn, fn) ->
	A: (tn, fn) -> aGenerate('A').bind(this) tn, fn
	a: (tn, fn) -> aGenerate('a').bind(this) tn, fn


	#COMMAND: section / directory of tests
	_s: (tn, fn) ->
	S: (tn, fn) -> sectionGenerate('S').bind(this) tn, fn
	s: (tn, fn) -> sectionGenerate('s').bind(this) tn, fn


	#COMMAND: synchronous test
	_t: (tn, fn) ->
	T: (tn, fn) -> testGenerate('T').bind(this) tn, fn
	t: (tn, fn) -> testGenerate('t').bind(this) tn, fn



	next: ->
		objectThis = this

		#H: is this while loop even used anymore?
		while testIndex < testList.length
			if iterations++ > INFINITE_LOOP_DETECTION_ITERATIONS
				@logFatal "infinite loop detected (stopped at #{iterations} iterations)"

#			@log "#{testListSaved} VS #{testList.length}"
			if testListSaved isnt testList.length
				@logFatal "testList corruption"

			test = testList[testIndex]

			# iter=#{iterations}
			@log "RUN: ##{testIndex+1}/#{testList.length} #{test.cmd}:#{test.tn}#{if trace.DETAIL then ": #{test.path}" else ""}"			if trace.UT_TEST_PRE_ONE_LINER

			if test.bRun
				@logFatal "already run!"
			else
				test.bRun = true

			switch test.cmd
				when 'a', 'A'
					pr = new Promise (resolve, reject) =>
#						@log "ASYNC #{test.tn} PATH=#{test.path}"	# type=#{typeof test.fn} fn=#{test.fn}"

						fn2 = decorate test, objectThis

						try
							fn2
								tn: test.tn
								resolve: resolve
								reject: reject
						catch ex
							util.logBase "ut-a CATCH from #{test.cname} - #{test.tn}", ex
							process.exit 1
					.then =>
						pass++
						@post "a-then"
					.catch (ex) =>
						fail++
						@logFatal "a", ex
						@post "a-catch"
					return		#IMPORTANT
				when 't', 'T'
#					@log "RUNNING #{test.tn} PATH=#{test.path}"#" #{test.fn}"
					passSave = pass
					try
						if ++t_depth is 2
							@logFatal "nested tests"

						utParameter =
							tn: test.tn

						#TODO: also have coffeeScript scan for documentation if -doc flag passed or whatever
						@fnCallback? "pre", "t", utParameter, objectThis

						fnBoundObjectThis = decorate test, objectThis
						fnBoundObjectThis utParameter

#						@log "back from test"
						@fnCallback? "post", "t", utParameter, objectThis

						@log "say something meaningful here"										if trace.UT_TEST_POST_ONE_LINER	#TODO

						if pass is passSave
							# implicit pass
							pass++

						--t_depth
						@post "t"		#WARNING: could cause very deep stack
					catch ex
						fail++
						@logFatal "in test (t) handler: b-bind", ex
						@post "t-catch"
#					@log "back"
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
#					console.log test.cmd
#					if test.cmd is 'T'
#						bFoundOverride = true
					if /^[A-Z]/.test test.cmd
						@log "OVERRIDE: #{test.cmd}"
						test.bEnabled = true
						bFoundOverride = true

				testListSaved = testList.length

				if bFoundOverride
					testList = testList.filter (test) => test.bEnabled
					@log "found #{testListSaved} tests, but also found #{testList.length} overrides"

				if testList.length > 0
					testListSaved = testList.length

					@next()

					#HACK: utilize this timer to keep node running until all tests have completed
					timer = setInterval =>
		#					@log "ping"
							unless bRunning
								secs = Math.ceil((Date.now() - msStart) / 1000)
								@log "all unit tests completed: [#{secs} second#{if secs is 1 then "" else "s"}] total=#{pass+fail}: #{unless fail then "PASS" else "pass"}=#{pass} #{if fail then "FAIL" else "fail"}=#{fail}"
								clearInterval timer
								resolve()
						,
							100

#if ut
	ut: (testHub) ->
#		@log "CLOUD=#{testHub.c.CLOUD}"
		new UTUT().run testHub
#endif












class UTUT extends UT
	run: ->
		@t "UT events", (ut) ->
#			@log "say hi: #{ut.say_hi_to_peter}"

			@eq ut.say_hi_to_peter, "Hi Pete!"

			@testHub.startClient "/tmp/ut/UTUT"
#			.then (client) =>
#				@log "one: #{client.one}"
			.catch (ex) =>
				@logCatch "startClient2", ex		#H: logCatch WHAT should be the parameter?


		@t "empty log", ->
			@log "pre"
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


		@S "sync nesting test", ->
#			@log "SYNC"
#			t = 0
#			@log "div 0"
#			t = t / t
#			O.DUMP this
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
						@A "b2c1d1", (ut) ->
							ut.resolve()










#endif