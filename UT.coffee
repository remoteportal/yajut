#if node
REMOVE_ME_MS = 10		#H
#else
REMOVE_ME_MS = 10
#endif



###
YAJUT - Yet Another Javascript Unit T e s t							a.shift "pop() by doing shift LEFT"

bottom line: unit tests must be as powerful and succinct as possible... as little boilerplate as possible... and easily controllable... to isolate correct one giving you brief
    must be fast (parallel execution), vary trace easily.  quickly stop on errors
easily extendable with native commands
rich set of primatives (dump object)
logging for posterity

=> you spend most of your time writing unit tests... make it as easy and enjoyable as possible

great support for negative testing... ... ability to "unwind" errors and remove specific expected ones


USAGE:
yajut						run current configuration
yajut conffile				run configuration stored as JSON in text file
yajut list					list all tests in directory
yajut purgelogs				forceably purge all previous log directories and files without user confirmation
yajut resetstats			forceably reset all test statistics without user confirmation
yajut -k keyword			run all tests matching keyword
yajut -r					re-run all failed tests from the exact preceeding run
yajut -s conffile			save current code-specified configuration into confifile for manual editing or re-use later


EXTENDS: Base


Server: [S]
Client: [C]


TERMINOLOGY: #H
    command			-lcmd		"called inside test": @eq (string equality), @log (log), @m (milestone)
    primative		-lprim		"structure of tests": @s (section), @t (sync test), @a (asynchronous test), @p (promise-returning test)


DESCRIPTION:
The goal of JAJUT is to be absolutely the least-friction most-terse easiest to use JS unit test system.


use skinny arrows (not fat arrows) for nested tests:
	@s "async nesting test", ->
		@s "a", ->
			@s "b1", ->
    			@t "some sync test", ->
				@a "some async test", (ut) -> ut.resolve()


The UT, for the server, choses either a blank Flexbase database or a database with small user pool
For local, it chooses either a brand-new install, or a already established user account.
server: "blank" or "std"
client: "blank" or "std"

Everything is logged.... in fact you can do @snap to take a picture of both databases and all object state at that moment in separate data directory
Promise-based, hierarchical test, minimalist and least-boilerplate, inline with source code unit test framework.

- (ut) -> vs @utMethod: the value of 'ut' parameter is that:
    - @ form is shorter
    - but using ut: a test can use closure not fat arrows (=>) to access ut properties and methods
    - but using ut: if inside a overridden child method of a sub-class: onReceive where 'this' context is the object not the ut



P-tests:
	@P "test name", (ut) ->
		Promise.resolve()
		.then =>
			@log "this chain does return promise"		BUT GENERATES  (UT004) in RN because RN promises are objects not typeof => Promise
	PROBLEMS with @p TEST DISCUSSION:
    	The problem is that TWO promises are resolved:
    		A) the test itself
    		B) @env.succ()
		NOTE: the test may not appear to return a promise object, but because it has a promise chain, a promise object *is* returned (FFF2) and the value may be a real value or null
		@p "scenario 1 BROKEN", ->
			pr = @ce().run()
			.then (po) =>
				@env.succ "Kubusschnitt"			=> FFF6: ut ITSELF resolved promise: [[Kubusschnitt]]					**NO** await	t2) too late, ERROR
				"hello"								=> FFF2: @p ut return value: promise, that is NOW resolved: [[hello]]					t1) timely
		@p "scenario 2 BROKEN", ->
			pr = @ce().run()
			.then (po) =>
				await @env.succ "Kubusschnitt"		=> FFF6: ut ITSELF resolved promise: [[Kubusschnitt]]					**YES** await	t1) timely
				"hello"								=> FFF2: @p ut return value: promise, that is NOW resolved: [[hello]]					t2) too late, suite already moved on, causes Error: done: who=undefined: mState: expected=RUNNING(2) got=DONE(3)
    	#TAKE-AWAY: I don't think @env.succ can be used with @p-tests?
    		By design, @env.succ() fires promise that was created by @ce()
		@p "scenario 3 CORRECT-FORM", ->
			pr = @ce().run()
			.then (po) =>
				@env.d()		#WORKS: don't put await



EVENTS: @events
left-open
runner-done
runner-start
test-done
test-start


@ASSERTION LIBRARY	@ASSERTLIB	@ALIB:		#EASY: ut -al (show assertion library) or -la (list assertions) or -lcmd (list commands)  #H:what are these ut.method and @method's called?
    eq			a, b, msg, o				as string equal (EQ-NOT-STRICT)				pass: (new String "6") eq 6
    Eq			a, b, msg, o				value not type (EQ-MID-STRICT)				pass: (new String "6") Eq "6"
    EQ			a, b, msg, o				value and type (EQ-STRICT)					pass: (new String "6") EQ (new String "6")
    EQO			a, b, msg, o				same object (EQ-SAME)						pass: o EQO o
    eqfile		a, b, msg, o				file contents (EQ-FILE)						pass: read(file) compare read(file)


FEATURES:
- ability to add or remove flags run-over-run: +flag  /flag or something
- almost everything is customizable: mTypes, logging, primatives (t, a, p, s, etc.)


NON-FEATURES:
- human "sentence" readable assertion library: dot.dot.dot crap.   For me, brevity is way more important


ERRORS:		#TODO: out this in structure  #EASY
UT001 Unknown test option: $
UT002 Unknown mType=$
UT003 You are not allowed to define the method named '$' because it clashes with a built-in property
UT004 Promise expected but not returned from P-test
UT005 P-tests aren't supported by ReactNative
UT006 opts must be object
UT007 opts.tags must be CSV
UT008 asynch opt not allowed with $
UT009 Invalid test tag: $
UT010 two children can't have exactly the same name: $			FUTURE


GENERALIZE:
- mType's


TODOs
- log EVERY run to new timestamp directory with tests ran in the directory name... store ALL data
	- two files: currently enabled trace and ALL TRACE
	- auto-zip at end
	- directory: 2018-05-01 6m tot=89 P_88 F_1 3-ModuleName,DeathStar TR=UT_TEST_POST_ONE_LINER,ID_TRANSLATE.zip
		traceSelected.txt
		traceAll.txt
		src/...
- if run all TESTS report how many are disabled _
- put cleanup in opts  but that means @client and @server or implement our own timeout mechanism, again, inside here:
- onPost -> @testHub.directoryRemoveRecursiveForce()
- actually:  @testHub.directoryGetTempInstanceSpace
- test auto-discovery so don't need to explicity list in tests.coffee
- add @rnd() functions
- validate system-level options parameter names
- validate per-unit test on-the-fly options for mispellings
- @defined x
- at beginning of test, silently dump all it's options
- EXCEPTION to check the actual type of exception... many false positives/negatives unless do THAT
- @db_log (snapshot)
- @db_diff	do snapshot into delta arrays
- only create tables once per section, and is run een if only a single test override in place... not sure how to pull this off.  @s -> if @testing ...
- auto-teardown: you register setup things and what to do with them... if anything goes wrong they are torn down
- write test results in JSON file so that can do "query" like "when was the last time this test passed?"
- children ndoes that "build" to the current overridden child node... preceeding steps...really great idea!
- designate test as a negative test... @tn... @n...  @an...?
- run all asynch tests at same time concurrently
- classify tests: positive, negative, boundary, stress, unspecified, etc.
- run all tests < or > than so many milliseconds
- capitalize section ("S") overrides to run entire sections
- purposeful 1000ms delay between tests to let things settle
- count the number of disabled tests
- include string diff report functions to make it really easy to ascertain why @eq fails
#EASY: dump all possible test options... in grid with S T A section/test/asynch columns in front, option, desc, and example
#EASY: new option def:
    @t "some test",
			def:
				em: "Deanna is beautiful"
				b: "b-value"
			exceptionMessage: @em			HOW DO THIS?
		, ->
			throw @em
    should be readable by ut.a, @a, and other parameters.  Ensure don't stomp on system
- have eventFire be a wrapper that calls the real cb and if not return true the call process?.exit?
- keep the same numbers, even if overrides
- manufacture variables than can be passed into routines that track what values they are set to to see if they exceed, etc.  using proxy
- run this test: UT.Peter.capitalize (local)     PASS=2 instead of 1
- pass all stdout and stderr from the test
- pass metrics like # of database hits, etc.
- test info siloed--none commingled trace and logging.  even though five concurrent tests running, all the trace is separate.  Even threads of particular test are siloed.
- perhaps put the "assertion library" tightly in it's own silo'ed area?
- @ut in different text color
- @ut "I'm green", color:green
- test setup and teardown in different text color
- ut -hi		implement a shell-type history... shows last 30 unique commands with a number... type number: 14<return>
- on test failure, read each and every file in the test.directory and add to the log for post-mortem analysis
- client/server with different trace colors
- track which tests seem to fail occasionally ("which dones are transient failures"); track by name and desc (NOT number)
- ut -sum			if error I don't think it tells you which test it died on
- ___7  25:06 [SyncTest] ==================== #6 t BaseUT logging/logError
  ___8  25:06 [AsyncTest] ==================== #7 a BaseUT logging/soon			<---- line up



ROUNDUP:
- https://medium.com/welldone-software/an-overview-of-javascript-testing-in-2018-f68950900bc3



KNOWN BUGS:
-
###





#GITHUB: #TODO: create new repo called AlvinUtils and put these in there
#NOTE: ILLEGAL TO USE context instance in this file only static class methods (why? instance is domain specific)
#IMPORT2 Context




#EASY #TODO: minimize these global variables
path = ''
testStack = []
testList = []



#REVISIT
log = -> global.log.apply this, arguments		#PATTERN	#R



bag = Object.create
	clear: ->
		for k of bag
			unless k is "clear"
				delete bag[k]
		return



#PATTERN: target is function
target = (cmdUNUSED_TODO) ->
	if trace.UT_BAG_DUMP
	#	log "HI: cmd=#{cmdUNUSED_TODO}"
		sans = Object.assign {}, bag
		delete sans.clear

		O.LOG sans		#NOT-DEBUG

		if _=O.CNT_OWN sans
			log "bag: #{_} propert#{if _ is 1 then "y" else "ies"}:"
			for k,v of sans
				if typeof v is "object"
					log "bag: #{k} ="
					O.LOG v
				else
					log "bag: #{k} = #{V.DUMP v}"
		else
			log "bag: empty"
		return



#PATTERN: target isn't actually proxy target (ONLY WORKS FOR SINGLETONS)
handler =	# "traps"
	get: (target, pn) ->
#		log "read from bag: #{pn} => #{bag[pn]}"
		bag[pn]

	set: (target, pn, pv) ->
#H: 	I don't know why this following line isn't green with -hl CLI
		global.log "UT handler: set: #{pn}=#{pv} <#{typeof pv}>"										if trace.UT_BAG_SET
		throw Error "clear is not appropriate" if pn is "clear"
		bag[pn] = pv



proxyBag = new Proxy target, handler



class UTBase extends Base		#@UTBase
	constructor: ->
		super()

		@const "NEG", 0
		@const "PROOF", 1
#													  FAILURE HANDLER
		@const "FAIL_ASSERT", 1						# onAssertFail()
		@const "FAIL_EQ", 2							# onEqFail()
		@const "FAIL_ERROR", 3						# onError() FUTURE
		@const "FAIL_EXCEPTION", 4					# onException()
		@const "FAIL_MARKERS", 5					# onMarkers()
		@const "FAIL_TIMEOUT", 6					# onTimeout()
		@const "FAIL_UNFAIL", 7						# onUnfail()		something was supposed to fail but didn't!
		@const "FAIL_UNEXPECTED_PROMISE", 8			# onUnexpectedPromise
		@const "failTypes", [null, "Assert", "Eq", "Error", "Exception", "Markers", "Timeout", "Unfail", "Unexpected_Promise"]

		@const "FM_FAILFAST", 0
		@const "FM_FAILTEST", 1
		@const "FM_RUNALL", 2

		@const "STAGE_SETUP", 1
		@const "STAGE_RUN", 2
		@const "STAGE_TEARDOWN", 3

		@const "STATE_WAITING", 1
		@const "STATE_RUNNING", 2
		@const "STATE_DONE", 3
		@const "STATE_LIST", [null, "WAITING", "RUNNING", "DONE"]

		@const "stateFrag", (m = @mState) -> "#{@STATE_LIST[m]}(#{m})"

		@const "WHY_ALL_TESTS_RUN", 1
		@const "WHY_FAIL_FAST", 2
		@const "WHY_FATAL", 3
		@const "WHY_TOLD_TO_STOP", 4
		@const "WHY_CLI", 5
		@const "WHY_NO_TESTS_FOUND", 6
		@const "WHY_LIST", [null, "ALL_TESTS_RUN", "FAIL_FAST", "FATAL", "TOLD_TO_STOP", "CLI", "WHY_NO_TESTS_FOUND"]
		
		O.MAKE_LG @, "UTSYS", trace, "UT_RUNNER", => @__CLASS_NAME2 ? @__CLASS_NAME




#TODO: combine MAKEa and MAKEt?
MAKEa = (cmd) =>
	(tn, fn) ->
		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		unless typeof fn is "function"
			abort "MISSING fn"

#		if bRunning and t_depth is 1 => @lgFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
#		@lg "found async: #{tn} --> #{@__CLASS_NAME}"
#		@lg "CLASS=#{@__CLASS_NAME}  TN=#{tn} PATH=#{path}"
#		@lg "#{@__CLASS_NAME}#{path}/#{tn}"

		new AsyncTest
			cmd: cmd
			cname: @__CLASS_NAME
			common: Object.getOwnPropertyNames(Object.getPrototypeOf(this)).filter (mn) -> mn not in ["constructor","run"]
			fn: fn
			hier: "#{path}/#{tn}"
			tn: tn
			opts: opts
			parent: this
#			path: "cn=#{@__CLASS_NAME} path=(#{path}) tn=#{tn}"
			path: "#{@__CLASS_NAME} #{path}/#{tn}"



MAKEt = (cmd) =>
	(tn, fn) ->
		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		unless typeof fn is "function"
			abort "MISSING fn"

		new SyncTest
			cmd: cmd
			cname: @__CLASS_NAME
			fn: fn
			hier: "#{path}/#{tn}"
			tn: tn
			opts: opts
			parent: this
			path: "#{@__CLASS_NAME} #{path}/#{tn}"



#TODO: combine these three somehow
MAKEs = (cmd) =>
	(tn, fn) ->
		throw 0 unless typeof tn is "string"
		throw 0 unless typeof fn is "function"

		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		unless typeof fn is "function"
			abort "MISSING fn"

		testStack.push tn

		path = testStack.join '/'
#		log "BEG: MAKEs: #{path}"

		fn.bind(this)
			opts: opts
			parent: this
			tn: tn

		testStack.pop()
		path = testStack.join '/'
#		log "END: MAKEs: #{path}"
#END:UTBase



























#
##H: overloaded between UT runner and superclass
EXPORTED = class UT extends UTBase			#@UT
	constructor: (@WORK_AROUND_UT_CLASS_NAME_OVERRIDE) ->
		super()
		@__CLASS_NAME = @WORK_AROUND_UT_CLASS_NAME_OVERRIDE ? @constructor.name

	#COMMAND: asynchronous test
	_A: (a, b, c) ->
	_a: (a, b, c) ->
	A: (a, b, c) -> MAKEa('A').bind(this) a, b, c		#REVISIT: apply...
	a: (a, b, c) -> MAKEa('a').bind(this) a, b, c

	#COMMAND: asynchronous test
	_P: (a, b, c) ->
	_p: (a, b, c) ->
# if rn
#	P: (a, b, c) -> throw Error "UT005 P-tests aren't supported by ReactNative"
#	p: (a, b, c) -> throw Error "UT005 P-tests aren't supported by ReactNative"
# else
	P: (a, b, c) -> MAKEa('P').bind(this) a, b, c
	p: (a, b, c) -> MAKEa('p').bind(this) a, b, c
# endif

	#COMMAND: section / to build a hierarchy of tests
	_S: (a, b, c) ->
	_s: (a, b, c) ->
	S: (a, b, c) -> MAKEs('S').bind(this) a, b, c
	s: (a, b, c) -> MAKEs('s').bind(this) a, b, c

	#COMMAND: synchronous test
	_T: (a, b, c) ->
	_t: (a, b, c) ->
	T: (a, b, c) -> MAKEt('T').bind(this) a, b, c
	t: (a, b, c) -> MAKEt('t').bind(this) a, b, c

	@s_runner: -> UTRunner				#WORKAROUND: so don't have to change all the individual tests
	@UTRunner: -> UTRunner				#PATTERN: not sure why can't just pass UTRunner itself (instead of function returning value)
	@s_ut: -> new UT_UT().run()
#END:UT





#TODO: expose these for customization
class Test extends UTBase		#@Test #@test
	constructor: (optsOrig, optsMore) ->
		super()

#		@lg "Test constructor: optsOrig", optsOrig

		for k,v of optsOrig
			@[k] = v

		for k,v of optsMore
			@[k] = v

		_ = @cmd + ' ' + @path			#		_ = "CN=#{@__CLASS_NAME} PATH=[#{@path}]"

		@bForcePass = false
		@markers = ""
		@pass = 0
		failList_CLOSURE = @failList = []


		#GENERALIZE #PRODUCTIONIZE
		validOptsMap = null		#TODO #EASY #RECONCILE: already handled by validate() function... do it all here?
		validTagsMap =
			daemon: "daemon must be running"
			human: "meant only to be run manually by a human (not in a suite of tests)"
			internet: "only run test if connected to the Internet if '-tagy internet' option specified"
			localdaemon: "HELP: local daemon must be running at: ws://localhost:4000"

		if @opts
			unless IS.o @opts
				console.log "UT006 pre-flight failure: opts must be object: #{@path}"		#H: not console.log
				O.LOG @opts
				return undefined
		if @opts?.tags
			unless IS.csv @opts.tags
				console.log "UT007 pre-flight failure: opts.tags must be CSV: #{@path}"		#H: not console.log
				O.LOG @opts.tags
				return undefined

		@opts = @opts ? {}
		@opts.tags = @opts.tags ? ""
		@tags = {}
		if @opts.tags.length
			for k in @opts.tags.split ','
				if k of validTagsMap
					@tags[k] = true
				else
					console.log S.autoTable validTagsMap, headerMap:{key:"tag",value:"description"}
					console.log()
					console.log "UT009 Invalid test tag:"			#H: not console.log
					console.log S.autoTable
						"file:": @cname
						"path:": @hier
						"tag:": k
					return undefined
#				console.log "> tag: #{k}"
		@optsCSV = Object.getOwnPropertyNames(@opts).filter((tag) => tag isnt "tags").sort().join ','
		@tagsCSV = @opts.tags
		if @opts.mon
			@mon = @opts.mon
			delete @opts.mon
#			console.log "FOUND mon: #{@mon}"
		delete @opts.tags				# remove from options since it's been promoted to top-level


		#TODO: move to Log.coffee?
		class @Fail extends UTBase		#@Fail	#@fail   #PATTERN
			constructor: (@mFail, @summary, @detail, @o) ->
				super()
				failList_CLOSURE.unshift @
				@lg "fail constructor: mFail=#{@mFail} #{@summary} nowLen=#{failList_CLOSURE.length}", @o
				@bEnabled = true
#				console.log "Fail=#{V.Type @o}"
				if V.Type(@o) is "Error"
#					console.log "got error <<<<<<<<<<<<<<<"
					@ex = @o
					@o = null
					@stack = @ex
#					@lg "111*^20 stack.length=#{@stack?.length}"
#					@lg "222*^20 stack.length=#{@stack?.length}", @ex
#				else
#					console.log "NOT ERROR"
#					O.DUMP @o

#					https://www.stacktracejs.com
#					console.log "console.trace():"
#					console.trace()
#					err = new Error @msg
#					@stack = err.stack
#				@lg "stack", stack
#				O.LOG @

#				@lg "*^20 mFail=#{@mFail}"				#POP
#				@lg "*^20 summary=#{@summary}"
#				@lg "*^20 detail=#{@detail}"
#				@lg "*^20 o=#{@o}"
#				@lg "*^20 stack.length=#{@stack?.length}"

#			full: -> Context.textFormat.red "#{@one()}\n\n#{@detail}#{SP.d @stack, "\n#{@stack}"}"
			full: -> "#{@one()}\n\ndetail=#{@detail}\no=#{@o}\n#{SP.d @stack, "\n#{@stack}"}"
			heal: -> @bEnabled = false
			one: -> "Fail: #{@failTypes[@mFail]}(#{@mFail})#{SP.d @msg, @msg}: #{@summary}"

		@one = -> "##{@testIndex} #{_}"
		@one2 = -> "Test: #{@one()}: cmd=#{@cmd} enabled=#{@bEnabled} mState=#{@stateFrag()} mStage=#{@mStage}#{SP.d @opts.mutex, "mutex=#{@opts.mutex}"} pf=#{@pass}/#{@failList.length}"
		@one3 = -> "#{@one2()} [#{@optsCSV}]"
		testList.unshift this



#TODO: even sync tests should be run with timer because they could take too long!
	after: (mFail, ex_s_null) ->
#		@assert mFail?, "mFail"		wrong: mFail is undefined or null if success
		@lg "#".repeat 60
		@lg "after: #{@failTypes[mFail]}(#{mFail}): #{@one2()}" #, ex_s_null

#H #DOMAIN: remove this from UT.coffee... onAfter()      	perhaps @env.onAfter()
		if @env?.server?.deliverObj?.config?.deliverList?.length > 1
			#TODO: call @FAIL
			console.log "server: not delivered: #{@env.server.deliverObj.config.deliverList.length}"
		if @env?.server?.deliverObj?.queuedCntGet()
			console.log "AFTER: " + @env.server.deliverObj.oneQ()
			#TODO: call @FAIL

#		@lg "failList.length=#{@failList.length}"
		if mFail in [@FAIL_ERROR, @FAIL_EXCEPTION, @FAIL_TIMEOUT, @FAIL_UNEXPECTED_PROMISE]		#MANAGE #ADD #OTF
#			@lg "on-the-fly append mFail to failList"
			@FAIL mFail, null, null, ex_s_null
#		@lg "DUMP IT ALL", @failList

		if @opts.markers?
			if @opts.markers isnt @markers
				s = """

-----------------------
markers: expected: #{@opts.markers}
markers: got     : #{@markers}
-----------------------
"""
				@FAIL @FAIL_MARKERS, null, null, s

		expectMap = {}
		if @opts.expect
			for k in @opts.expect.split ','
				kUC = k.toUpperCase()
				if _=@["FAIL_#{kUC}"]
#					@lg "after: expectMap[#{kUC}]=#{_}"
					expectMap[kUC] = _
				else
					throw Error "Invalid expect type: '#{k}'"

#		@lg "failList.length=#{@failList.length}"
		for EXPECT of expectMap
			@lg "EXPECT=#{EXPECT}"
			bFound = false
			for fail,i in @failList by -1
				@lg "--> #{fail.one()}   (compare #{@failTypes[fail.mFail].toUpperCase()} vs #{EXPECT})" #, fail
				if @failTypes[fail.mFail].toUpperCase() is EXPECT
					@lg "  EXPECT found... so don't call @FAIL"
					bFound = true
			unless bFound
				@lg "+ add"
				@FAIL @FAIL_UNFAIL, "Expected #{EXPECT} but didn't find one", null, null

		if @opts.exceptionMessage?
#			@lg "scanning for #{@opts.exceptionMessage}"
			bFound = false
			for fail,i in @failList by -1
#				@lg "--> #{fail.one()}" #, fail
				if fail.mFail is @FAIL_EXCEPTION
#					@lg "found exception"
					if fail.ex.message is _=@opts.exceptionMessage
						bFound = true
#						@lg "remove because exceptionMessage match"
						@failList.splice i, 1
			unless bFound
#				@lg "exceptionMessage not found"
				detail = '^' + V.COMPARE_REPORT ex_s_null.message, _, preamble:"ex.message\n\n@opts.exceptionMessage"
#				@lg "+ add"
				@FAIL @FAIL_ERROR, "exceptionMessage mismatch", detail, null

#H #UNSTABLE: if TWO promises, depending on the order in which they resolve... the splice may be incorrect order and will be indeterminate (WRONG) deletion
#WORKAROUND: only have a single handler... only guaranteed to work with a single handler
#ARCHITECTURE: or guarantee serial handler execution
		PR = new Promise (resolve, reject) =>
			afterHandler = (fail) =>
				unless fail.bEnabled
#					@lg "onHandler: remove i=#{i}"
					@failList.splice i, 1

			a = []
	#		@lg "look for onHandler"
			for fail,i in @failList by -1
	#			@lg "--> #{fail.one()}" #, fail
				if _=@opts[mn="on#{@failTypes[fail.mFail]}"]
					@fail = fail
					THAT = Object.assign {}, @, @runner.OPTS, @runner.OPTS?.perTestOpts?[@cname], @opts, {fail:fail}		# works but it's a different object
					rv = _.bind(@) @

					if V.type(rv) is "promise"
#						@lg "handler returned Promise. Pushing..."
						a.push new Promise (resolve2, reject2) =>
							rv.then (resolved) =>
#								@lg "FOUND RESOLVED PROMISE"
								afterHandler fail
								resolve2 resolved
							.catch (ex) =>
#								@lg "FOUND REJECTED PROMISE", ex
								afterHandler fail
								reject2 ex
					else
#						@lg "didn't return a promise"
						afterHandler fail
			if a.length > 0
				Promise.all a
				.then =>
					resolve()
				.catch (ex) =>
					@logCatch "Promise.all", ex
					reject()
			else
				resolve()
		PR.then =>
#			@lg "handlers all done"
			for fail,i in @failList by -1
				t = @failTypes[fail.mFail]
	#			@lg "--> #{fail.one()} ==> #{t}" #, fail
				if expectMap[t.toUpperCase()]
	#				@lg "EXPECT2: remove: i=#{i}"
					@failList.splice i, 1

			if @bForcePass
				@failList.length = 0

			if @failList.length
				console.log '-'.repeat 75
				console.log "#{@one()}: #{@failList.length} RESIDUAL ERROR#{if @failList.length is 1 then "" else "S"}"
				console.log '-'.repeat 75

				# @FAIL @FAIL_TIMEOUT, "[[#{@path}]] TIMEOUT: ut.{resolve,reject} not called within #{ms}ms in asynch test"
				for fail,i in @failList
					console.log "SHORT: ##{i+1}  #{fail.one()}"

				for fail in @failList
					console.log "----------------------------------------------"
					console.log Context.textFormat.red S.prependPerLine "LONG: ", fail.full()
			else unless @pass
				@pass++

			@done()
		.catch (ex) =>
			@logCatch "Test.after chain", ex



	decorate: ->
		@assert @fn, "function body is required"
		@assert = (b, msg) ->
			_ = if msg then ": #{msg}" else ""

			@logSilent "UT.docorate.assert: b=#{b}#{_}"

			if b
				@pass++
			else
				@FAIL @FAIL_ASSERT, "@assert#{_}", null, null

			b
		@bag = proxyBag
		@context = "CONTEXT set in decorateJustObject"		#H
		@defined = (v, msg) ->
			_ = if msg then ": #{msg}" else ""

			@logSilent "defined: b=#{b}#{_}"

			b = v?

			if b
	#			log "defined"
				@pass++
			else
				@FAIL @FAIL_ASSERT, _, null, null

			b
		@delay = (ms) ->
			to =
				ms: ms
				msActual: null
				msBeg: Date.now()
				msEnd: null

			new Promise (resolve) =>	#NEEDED
#				@logg trace.DELAY, "BEG: delay #{ms}"

				setTimeout =>
						to.msEnd = Date.now()
						to.msActual = to.msEnd - to.msBeg
#						@logg trace.DELAY_END, "END: delay #{ms} *^20", to
						resolve to
					,
						ms
		@eq  =	(a, b, msg, o) -> 	@eqINNER.apply @, ["eq",  arguments...]			#PATTERN #FORWARD #CURRYING
		@Eq  =	(a, b, msg, o) -> 	@eqINNER.apply @, ["Eq",  arguments...]			#PATTERN #FORWARD #CURRYING
		@EQ  =	(a, b, msg, o) -> 	@eqINNER.apply @, ["EQ",  arguments...]			#PATTERN #FORWARD #CURRYING
		@EQO =	(a, b, msg, o) -> 	@eqINNER.apply @, ["EQO", arguments...]			#PATTERN #FORWARD #CURRYING
		@eqINNER = (mn, a, b, msg, o) =>
			#							PASS CRITERIA
			# eq	#EQ-NOT-STRICT		"as string equal"		(new String "6") eq 6
			# Eq	#EQ-MID-STRICT		"value not type"		(new String "6") Eq "6"						#H: same as eq?
			# EQ	#EQ-STRICT			"value and type"		(new String "6") EQ (new String "6")
			# EQO	#EQ-SAME			"same object"			obj == obj

			@lg "#{mn}: BEG: a=#{a} b=#{b}"
			if !(a?) and !(b?)
				@logg trace.UT_EQ, "#{mn} pass: #{a} vs #{b}: both undefined [#{msg}]", o
				return true

			s = ""			# method passes if nothing appended

			doValue = =>
				a = "" + a
				b = "" + b

#				console.log "------------"			#DEBUGGING
#				console.log "aaa> #{a}"
#				console.log "bbb> #{b}"

				if b.includes '*'
# mask asterisks(*) in the LEFT string if they are present in the RIGHT string
#TODO #BUG: truncates the 'a' string
					aa = ""
					for c,i in b
	#					@lg c
						if c is '*'
							aa += '*'
	#						console.log "MASK!"
						else
							aa += if i < a.length then a[i] else ''
					a = aa

#					console.log "aaa> #{a}"
#					console.log "bbb> #{b}"

				unless V.EQ a, b
					s = "#{mn} values violation"

			switch mn
				when "eq"
					doValue()
				when "Eq"
					doValue()
				when "EQ"
					unless V.Type(a) is V.Type(b)
						s = "types violation"
					else
						doValue()
				when "EQO"
					unless a is b
						s = "EQO not same object"

			if s
				s += """

a> #{V.vt a}
b> #{V.vt b}
"""
				report = V.COMPARE_REPORT a, b
				@FAIL @FAIL_EQ, "#{mn} #{a} vs. #{b}#{AP.c_d msg}", "#{s}#{AP.crlf_d report}", o
				@logg trace.UT_EQ, "#{mn} fail: #{a} vs #{b} [#{msg}]"
				false
			else
				@logg trace.UT_EQ, "#{mn} pass: #{a} vs #{b}#{SP.sq msg}"
				@logSilent "inside #{mn}: PASS: #{msg}", o
				@logSilent V.vt a
				@logSilent V.vt b
				@pass++
				@logSilent "#{mn}: pass=#{@pass}"
				true
		@eqfile = (a, b) ->		#CONVENTION
			#EQ-FILE-CONTENTS: "file contents"	path eqfile path
			@lg "a: #{a}"
			@lg "b: #{b}"

			_a = await @file.fileSize a
			if _a < 0
				@lg "a dne"
				return @FAIL @FAIL_EQ, "eq \"doesn't exist\" vs. \"b\"", "a=#{a}"

			_b = await @file.fileSize b
			if _b < 0
				@lg "b dne"
				return @FAIL @FAIL_EQ, "eq \"a\" vs. \"doesn't exist\"", "b=#{b}"

			@eq _a, _b
		@ex = (ex) ->
			@logCatch ex
			@reject ex
		@FAIL = (mFail, summary, detail, v) ->
			throw Error "bad mFail" unless mFail
#			console.log "\n\n\nX X X X X X X X X"		#POP

			fail = new @Fail mFail, summary, detail, v
#			@lg "TYPE: #{Context.TYPE v}"

			_ = "FAIL: #{IF summary, "#{summary}: "}fail666=#{@failList.length}"

			if v
#				Context.O.DUMP v
				if typeof v is "object"
#					console.log "a"
					@lg _, v
				else
					if IS.ml v
						@lg _
						console.log "multi-line dump:"
						console.log v
					else
						@lg "#{_}: #{v}"
			else
				@lg _

			if @runner.OPTS.mFailMode is @FM_FAILFAST
				log fail.full()
				@exit @WHY_FAIL_FAST, summary
				log @one()
				abort "FM_FAILFAST: #{_}"

			false
		@fatal = (msg) ->
			console.error "fatal: #{msg}"
			@exit @WHY_FATAL, msg
			abort msg
		@h = (s) ->
			@log s, undefined, bHeader:false,format:"blue,bold,uc",orTrace:"H"
		#DUP: this is principal @log of unit tests		#TODO #USE: Context.MAKE
		@log = (sU, oU, opts) ->
			if opts?.orTrace
#				log "OR TRACE: #{opts.orTrace}"
				bbb = trace[opts.orTrace]
#				console.log "bbb => #{bbb}"
#				console.log "SUMMARY=#{trace.summary()}"
#			console.log bbb
			if trace.UT or bbb
				Context.logBase.apply this, ["#{@cname}/#{@tn}", arguments...]						#PATTERN: CALL #FORWARD
		@m = (s) =>
			@markers += s
			@log "MARK #{s}", undefined, bHeader:false,format:"magenta,bold,uc"
		MAKE_UT_LOG_FAIL = (mn, mFail) =>
			do (mn, mFail, that=@) =>		#PATTERN #CURRYING
#				console.log "mn=#{mn} mFail=#{mFail}"
				that[mn] = (msg, o, opt) ->
#					console.log "method #{mn}: #{msg}: type=#{V.type msg}"

					if V.type(msg) is "string"
						@FAIL mFail, msg, "", o, opt
					else
						o = msg
						opt = o
						msg = ""

						@FAIL mFail, msg, "UT~MAKE_UT_LOG_FAIL", o, opt		#H:opt #EXTRA_PARAM
		MAKE_UT_LOG_FAIL "logCatch", @FAIL_EXCEPTION
		MAKE_UT_LOG_FAIL "logError", @FAIL_ERROR
		@mStage = @STAGE_SETUP
		@ok = (vOpt) ->			#CONVENTION
	#		drill this, grep:"env"
			@lg "OK", @env
	#		@env.succ()		#TODO: get reference to @env and tear down resources
			@resolve vOpt
		@PASS = -> @bForcePass = true
		@PASS_CNT = (n=1) -> @pass += n
		@throw = (msg) -> throw Error msg			#USED?




		#H: what is this?  write test for it
# I JUST DO NOT UNDERSTAND THIS!
# in ServerStoreUT it moves alloc() to be reachable from unit test
		if @common
#			@lg "common: #{JSON.stringify @common}"
			for mn in @common
#				log "found common routine: #{mn}"
				if @[mn]
#					console.log "@common:"
#					O.LOG @common
					throw Error "UT003 You are not allowed to define the method named '#{mn}' because it clashes with a built-in property"
				@[mn] = @parent[mn]


		@fn.bind this
# ################### end of decorate ###################



	done: (who) ->
		syncTestsCount--
#		@lg "DONE DONE DONE DONE DONE: Test.done: #{@one2()}"
		Base.auditEnsureClosed "Test.done"
#		abort()

		@auditMark "" + @one2()
		throw Error "done: who=#{who}: mState: expected=#{@stateFrag(@STATE_RUNNING)} got=#{@stateFrag()}" unless @mState is @STATE_RUNNING

		@mState = @STATE_DONE
		@msEnd = Date.now()
		@msDur = @msEnd - @msBeg

#		@logg trace.UT_DUR, "dur=#{@msDur}: #{@path}"
#		@lg "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ post: who=#{who} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

#TODO: need mode to run in series rather than parallel
#		if Base.openCntGet()
#			Base.logOpenMap()
#			@stack()
#			abort "INTERMEDIATE RESOURCES LEFT OPEN!"

		@eventFire "test-done"
		@runner.testDone this



	enable: ->
		@bEnabled = true
		@mStage = @STAGE_SETUP
		@mState = @STATE_WAITING
#		@lg "enable: #{@one2()}"




#  	delegate to runner
	eventFire: (eventName, msg) ->
		@runner.eventFire eventName, msg ? @cmd, this, @opts


#	Test.exit
	exit: (mWhy, msg) ->
		@runner.exit mWhy, msg



	isAsyncRunnable: -> false



# 	Test.start()
	start: ->
		@opts = Object.assign {}, @runner.OPTS, @runner.OPTS?.perTestOpts?[@cname], @opts
		delete @opts.perTestOpts		#H: this assumes PER TEST not PER FILE

#TODO: remove extranous test name in front: 39:58 [AsyncTest] #27 a FSUT /fileSize
		@logg trace.UT_TEST_PRE_ONE_LINER, "=^20 #{@one()}"		# /#{testList.length} #{@cname} #{@cmd}:#{@tn}#{AP.c_d trace.DETAIL, "path=#{@path}"}"

		@msBeg = Date.now()
		@mState = @STATE_RUNNING
		syncTestsCount++

		for k,v of @parent
			@[k] = v

		for pn,pv of @opts.decorate?.test
#			console.log "decorate?.test: #{pn}"
			@[pn] = pv

###
		testThis = Object.assign {}, @parent
RN:
TypeError: One of the sources for assign has an enumerable key on the prototype chain. Are you trying to assign a prototype property? We don't allow it, as this is an edge case that we do not support. This error is a performance optimization and not spec compliant.
###
		@fnTest = @decorate()
		@eventFire "test-start"
		Base.UT_OWNER = @one2()


#	Test.exit()		#DELEGATE
	exit: (@mWhy, msg) ->
#		log "Test.exit called"
		@runner.exit.apply @runner, arguments				#PATTERN: PROXY propagate arguments	#TODO: add this UT to Proof.coffee


	optsValidate: ->
		if @opts
#			@lg "opts", @opts			#RN #POP

			if @opts.exceptionMessage and !@opts.expect?
				@opts.expect = "EXCEPTION"

			cmds = "bManual,desc,exceptionMessage,expect,hang,markers,mon,mType,mutex,onAssert,onEq,onError,onException,onTimeout,onUnfail,onUnexpectedPromise,SO,RUNTIME_SECS,tags,timeout,url,USER_CNT".split ','
			cmds.push '_' + cmd for cmd in cmds

			for k of @opts
				unless k in cmds
					@logFatal "[[#{@path}]] UT001 Unknown test option: '#{k}'", @opts

			if (@opts.onTimeout or @opts.timeout) and @cmd not in ["_a","a","_A","A","_p","p","_P","P"]
				@logFatal "[[#{@path}]] UT008 asynch opt not allowed with '#{@cmd}' cmd", @opts

			if @opts.mType?
#				@lg "opts.mType=#{@opts.mType}"
				if 0 <= @opts.mType <= 1
					@runner.mTypeCtrList[@opts.mType]++
				else
					@logFatal "[[#{@path}]] UT002 Unknown mType=#{@opts.mType}", @opts
#END:Test





class SyncTest extends Test		#@SyncTest @sync
	constructor: (optsOrig) ->
		super optsOrig,
			bSync: true
			bWasException: false		#R: move to Test and get rid of altogether



# 	SyncTest.start()
	start: ->
		super.start()

		try
			rv = @fnTest @			# SYNC
		catch ex
			@lg "sync had exception"
			return @after @FAIL_EXCEPTION, ex

		if IS.pr rv
			@after @FAIL_UNEXPECTED_PROMISE, rv
		else
			@after null, null
#END:SyncBase




class AsyncTest extends Test				#@AsyncTest @async
	@s_mutexMap = {}	#STATIC

	@s_one = -> "#{AsyncTest.s_mutexDump()} (#{AsyncTest.s_mutexCnt()})"
	@s_mutexCnt = -> O.CNT_OWN AsyncTest.s_mutexMap
	@s_mutexDump = -> Object.getOwnPropertyNames(AsyncTest.s_mutexMap).sort().join ','



	constructor: (optsOrig) ->
		super optsOrig, bSync:false



# 	AsyncTest.start()
	start: ->
		super.start()

		if @opts.mutex
			AsyncTest.s_mutexMap[@opts.mutex] = true

		timer = null

		new Promise (@resolve, @reject) =>
			ms = if @opts.hang then 2147483647 else @opts.timeout
#			@lg "setting timer: #{ms}ms"
			timer = setTimeout =>
					@after @FAIL_TIMEOUT, ms			# promise is never consummated and that's okay
				,
					ms

			try
				rv = @fnTest @			# ASYNC
			catch ex
#				console.log "catch: asynch test"
				clearTimeout timer
				#YES_CODE_PATH: I've seen this but sure why... you'd think that "catch" would be run instead
#				throw new Error "REALLY?  I really don't see how this could be triggered"  it's not a promise... it's  TRY..CATCH... that's why!
				@lg "FFF1"
				return @after @FAIL_EXCEPTION, ex

			@lg "returned from asynch test! #{kvt "rv", rv}"
			if @cmd.toLowerCase() is 'p'
				@lg kvt "#{@cmd}-test rv", rv
				if IS.pr rv
#					@lg "async test returned Promise"
					rv.then (resolved) =>
						clearTimeout timer
						@lg "FFF2: @p ut return value: promise, that is NOW resolved: #{LL.PR_RESOLVED resolved}"
						@after null, null
					.catch (ex) =>
						clearTimeout timer
						@lg "FFF3: @p ut return value: promise, that is NOW rejected: #{LL.PR_REJECTED ex}"
						@after @FAIL_EXCEPTION, ex
				else
					clearTimeout timer
#					@lg "SHOULD HAVE BEEN PROMISE", rv
					@lg "FFF4"
					@after @FAIL_ERROR, "UT004 Promise expected but not returned from P-test"
			else
				if IS.pr rv
					if trace.TIP
						@logWarning "tip: async test returned a promise; consider using @p instead of @a"
					rv.then (v) =>
						if @mState isnt @STATE_DONE
							@lg "[#{@STATE_LIST[@mState]}] one3=#{@one3()}"
							@lg "[#{@STATE_LIST[@mState]}] @a returned promise. WHAT DO? resolved value=", v
					.catch (ex) =>
#						@logCatch "@a returned promise. WHAT DO? rejected value=", ex

						clearTimeout timer
						@lg "FFF5"
#						a0
#						@log()
#						a1
#						@log "FFF5-B", ex
#						a3
#						@log()
#						a4
						@after @FAIL_EXCEPTION, ex
				else
					@lg "AsyncTest.start: non-promise return value from @a.  rv=", rv
					@lg "AsyncTest.start: typeof(rv)=#{typeof rv}"
					@lg "AsyncTest.start: Context.IS.who=#{Context.IS.who rv}"
					@logSilent "non-promise return value from @a.  rv=", rv
		.then (resolved) =>
			@logg trace.UT_RESOLVE_REJECT_VALUE, "RESOLVED:", resolved		#NEEDS-LOVE
			clearTimeout timer
			@lg "FFF6: ut ITSELF resolved promise: #{LL.PR_RESOLVED resolved}"
			@after null, null
		.catch (ex) =>
			@logg trace.UT_RESOLVE_REJECT_VALUE, "REJECTED:", ex
			clearTimeout timer
			@lg "FFF7"
			@after @FAIL_EXCEPTION, ex



	isAsyncRunnable: ->
#		O.LOG "OPTS", @runner.OPTS
		if @bSync
			false
#		else if @runner.OPTS.bSerial
#			# force serial
#			_ = O.EMPTY_OWN(AsyncTest.s_mutexMap)
##			@lg "force serial: #{_}"
#			_
		else if @opts.mutex
#			@lg "isAsyncRunnable: mutex check", AsyncTest.s_mutexMap
			! AsyncTest.s_mutexMap[@opts.mutex]
		else
#			@lg "isAsyncRunnable: true (no mutex)"
			true



	done: ->
		super.done()
		if @opts.mutex
			delete AsyncTest.s_mutexMap[@opts.mutex]
#END:AsyncTest




class Section extends Base		#@Section
	constructor: ->
		super()
#END:Section



syncTestsCount = 0	#HACK

class UTRunner extends UTBase		#@UTRunner @runner
	constructor: (@argv=["",""], @opts={}, @cb=(->)) ->
		super "I DO NOT UNDERSTAND WHY I CANNOT PASS @__CLASS_NAME and I don't know why it works when I don't"	#RESEARCH
#		log "UT CONSTRUCTOR IMPLICIT CALL: #{@WORK_AROUND_UT_CLASS_NAME_OVERRIDE} #{@constructor.name}"
#		O.LOG @opts
		@OPTS = @opts	#HACK
		@OPTS.bOnline ?= true
		@OPTS.timeout ?= 3000
		O.validate @opts,
			onlyCSV: "bOnline,bSerial,decorate,mFailMode,perTestOpts,timeout,userDefined"

#		console.log "UT.UTRunner.constructor: WORK_AROUND_UT_CLASS_NAME_OVERRIDE=#{@WORK_AROUND_UT_CLASS_NAME_OVERRIDE}"
#		console.log "UT.UTRunner.constructor: constructor.name=#{@constructor.name}"
		@__CLASS_NAME = @WORK_AROUND_UT_CLASS_NAME_OVERRIDE ? @constructor.name

		#INIT
		@bRunning = true
		@failList = []
		@mTypeCtrList = [0, 0]
		@runningCnt = 0
		@pass = 0
		@selectList = []
		@runnerThread = null

		#MOVE
		Object.defineProperties @,
			UT:
				enumerable: true
				get: -> trace.UT
				set: (v) ->
#					console.log "set T=#{v}"
					trace.UT = v




#TODO: make this a subroutine to be shared with deamon.coffee?
	CLI: (a) ->
		optionList = [
#EASY #TODO
###
    -o		"g"														the actual ASCII option minus the dash
    -n		"grep tests"											the short name (title)
    -u		"pattern"												use to manufactor "-g pattern"
    -d		"list tests that match grep pattern"					short sentence description
    -s		"The g option greps the name and description..."		multi-line description
###
				o: "-a"
				d: "force all tests to be run (ignore individual test overrides)"
			,
				o: "-async"
				d: "only asychronous tests"
			,
				o: "-c ServerStoreUT"
				d: "run all tests of a specified class (FUTURE)"
			,
				o: "-dup"
				d: "display duplicate test names"				
			,
				o: "-eg key1,key2,..."
				d: "exit grep"
			,
				o: "-ex"
				d: "cli EXamples"
			,
				o: "-f FM#"
				d: "mFailMode: 0=fail fast, 1=fail after test, 2=run all"
			,
				o: "-g testPattern"
				d: "like -l (list all tests) but only show matching lines"
			,
				o: "-h"
				d: "help"
			,
				o: "-i"
				d: "ignore test#,test#,..."
			,
				o: "-l"
				d: "list all tests"
			,
				o: "-lg key1,key2,..."
				d: "log grep"
			,
				o: "-lh key1,key2,..."
				d: "log highlight"
			,
				o: "-llh key1,key2,..."
				d: "log line highlight (FUTURE)"
			,
				o: "-o"
				d: "offline"
			,
				o: "-r test#"
				d: "recursive test given a section # (FUTURE)"
			,
				o: "-s"
				d: "run the tests in a serial manner, one after another"
			,
				o: "-sum"
				d: "display just the summary"
			,
				o: "-sync"
				d: "only sychronous tests"
			,
				o: "-tagn"
				d: "exclude tag1,tag2,... (FUTURE)"
			,
				o: "-tagy"
				d: "include tag1,tag2,,... (FUTURE)"
			,
				o: "-tl"
				d: "trace list"
			,
				o: "-tg"
				d: "trace grep"
			,
				o: "-tn"
				d: "Trace No: turn off all trace"
			,
				o: "-ty"
				d: "Trace Yes: turn on all trace: naked or -ty ut,... for trace.UT (\"log tests\")"  #DOMAIN-SPECIFIC #MOVE #H
		]

		@eventFire "CLI-optionList", optionList
		optionList.sort (a,b) -> if a.o > b.o then 1 else -1

		CSV2Object = (key) =>
#			console.log "CSV2Object: global.#{key}"

			if i < a.length
				if /^[\$\.0-9a-zA-Z_]+(,[\$\.0-9a-zA-Z_]+)*$/.test (keys = a[i++])			#TODO: pass in RE as argument	#TODO: allow ANY characters
#					@lg "keys=#{keys}"
					global[key] = @OPTS[key] = _ = {}
					for k in keys.split ','
						_[k.toUpperCase()] = true
						console.log "CSV2Object: global[#{key}][#{k.toUpperCase()}] = true"		#C
#					@lg "CSV2Object @OPTS[#{key}]=", _
				else
					er "UT: #{a[i-2]}: argument isn't in correct comma-separated format: #{keys}"
			else
				er "UT: #{a[i-1]}: must specify comma-separated keywords"


		er = (msg) =>
			console.log msg			if msg
			@exit @WHY_CLI
		

		#GITHUB: remove all trace references?
		maybeGrabTrace = (v) =>
			if i < a.length and trace.RECSV.test a[i]		#TEST
				setTrace a[i++], v
				true
			else
				false

		optionalNumber = (def) ->
			if i < a.length and /^[0-9]+$/.test a[i]
				i++
				a[i-1] * 1		#PATTERN
			else
				def

		setTrace = (csv, v) ->
			trace[csv] = v
#			console.log "UT: trace.one: #{trace.one()}"
#			O.DUMP trace
#			drill trace
			trace

		traceList = (pattern) =>
			depth = 0
			last = 'A'
			for k in Object.keys(trace).sort()
				if k[0] isnt last
					last = k[0]
					depth++
				if !pattern or k.includes pattern.toUpperCase()
					console.log "#{" ".repeat depth * 5}#{k}"
			@exit @WHY_CLI

		getKeys = (bEnable) =>		#TODO: leverage CSV2Object
			if i < a.length
				if /^[a-zA-Z_]+(,[a-zA-Z_]+)*$/.test (keys=a[i++])
					_ = {}
					for k in keys.split ','
						_[k.toUpperCase()] = true
					@OPTS["keys" + bEnable] = _
					O.LOG @OPTS
				else
					er "UT: keys must be comma-delimited"
			else
				er "UT: missing comma-delimited set of keys"

		log_help = =>
			console.log """
node tests.js [options] test# ...

OPTIONS:#{S.autoTable(optionList, bHeader:false)}"""

		CSV = "testIndex,cmd,path,optsCSV,tagsCSV"
		NUMBER_CSL_RE = /^\d+(,\d+)*$/

		class CLIParser extends Base
		parser = new CLIParser()

		class UniqueTester
			constructor: (@fnClash) ->
				@map = Object.create null
			add: (item) ->
				if item
					if @map[item]
						@fnClash item
					else
#						console.log "OKAY: #{item}"
						@map[item] = true
		monUnique = new UniqueTester (item) =>
			@logError "monikers ('#{item}') must be unique"
#		monUnique.add "peter"
#		monUnique.add "peter"
		for test in testList
#			@log test.mon
			monUnique.add test.mon #? test.tn

		i = 0			#TODO: create object with the helper functions as methods; must make @runner available
		while i < a.length
			word = a[i++]

			parser.word = word
			bActed = @eventFire "CLI-flag", parser
			unless bActed
				switch word
					when "-a"
						@OPTS.testsAll = true
					when "-async"
						@OPTS.bAsync = true
					when "-dup"
						# O.DUMP testList
						dupMap = {}
						for test in testList
							unless dupMap[test.tn]
								dupMap[test.tn] = []
							dupMap[test.tn].push
								cn: test.cn
								path: test.path
						for tn,a of dupMap
							if a.length > 1
								@box tn
								er S.autoTable a, bHeader:true, includeCSV:CSV
					when "-f"
						@OPTS.mFailMode = optionalNumber 1
					when "-g"
						testPattern = a[i++]
						er S.autoTable testList, bHeader:true, grep:testPattern, includeCSV:CSV
					when "-eg"
						CSV2Object "exitCSV"
					when "-h"
						er log_help()
					when "-i"
						word = a[i++]
						if NUMBER_CSL_RE.test word
							@OPTS.testsIgnore = word
						else
							er "UT: Illegal -i parameter: \"#{word}\".  Must be #,#,..."
					when "-kn"
						getKeys false
					when "-ky"
						getKeys true
					when "-l"
						er S.autoTable testList, bHeader:true, includeCSV:CSV
					when "-lg"			#MOVE: tests
						@OPTS.logGrepPattern = a[i++]
					when "-lh"			#MOVE: tests
						CSV2Object "logHighlightPattern"
					when "-mon"
						testPattern = a[i++]
						aMod = []
						for test in testList
							if test.mon
								aMod.push
									testIndex: test.testIndex
									mon: test.mon
									tn: test.tn
						er S.autoTable aMod, bHeader:true,boldColumnMap:{mod:true},grep:testPattern
					when "-o"
						@OPTS.bOnline = false
					when "-s"
						@OPTS.bSerial = true
					when "-sum"
						@OPTS.bSummary = true
					when "-sync"
						@OPTS.bSync = true
					when "-tg"
						traceList a[i++]
					when "-tl"
						traceList null
					when "-tn"
						unless maybeGrabTrace false
							@OPTS.traceOverride = false
					when "-ty"
						unless maybeGrabTrace true
							@OPTS.traceOverride = true
					else
						ADDTEST = (word) =>
#							@log "ADDTEST: #{word}"
							if @OPTS.testsInclude		#TODO: change to array and do push
								@OPTS.testsInclude = @OPTS.testsInclude + "," + word
							else
								@OPTS.testsInclude = "" + word

						if NUMBER_CSL_RE.test word			#TODO: support ranges (e.g., 10-19)
							ADDTEST word
						else
							# map monikers to IDs
							#HERE
#							@log "testList", testList
#							for test in testList
##								@log "tn=#{test.tn} mon=#{test.mon} opts.mon=#{test.opts.mon}"		#, test.opts
##								@log "tn=#{test.tn} opts.mon=#{test.opts.mon}"
#								if test.tn is "cat2"
##									@log "MON: #{test.opts.mon ? test.tn}"
##									@log "tn=#{test.tn} mon=#{test.mon}"	# , test.opts
#									@log "tn=#{test.tn} mon=#{test.mon}"	# , test.opts
							_ = testList.filter((test)->(test.mon ? test.tn) is word)
							if _.length
#								@log "found #{word} => #{_[0].testIndex}"
								ADDTEST _[0].testIndex
							else
								log_help()

								if word[0] is '-'
									er "UT: Illegal CLI option: \"#{word}\"."
								else
									er "UT: Illegal moniker (doesn't match test.tn or test.opts.mon): \"#{word}\"."
									@log "EXTRA", word
		sum = 0
		sum++	if @selectList.length > 0
		sum++	if @OPTS.testsAll
		sum++	if @OPTS.bAsync
		sum++	if @OPTS.bSync
#		@lg "sum=#{sum}"
		if sum > 1
			er "Can't specify #, -a, -async, -sync at the same time"

#		if @OPTS.bSummary?
#			trace.summary()		#WTF: commenting this out b/c it makes no sense at all

#		if @OPTS.traceOverride?
#			console.log "calling TRISTATE"
#			trace.tristate @OPTS.traceOverride
#		@lg "CLI", @OPTS

#		if @OPTS.mFailMode is @FM_FAILFAST			#POP
#			trace.tristate t r u e

		if @OPTS.bSerial?
			for test in testList
				unless test.opts
					console.log "falsy test.opts"
					O.LOG test
				test.opts.mutex = "same"
			return



	count: (mState) ->
		@assert @STATE_WAITING <= mState <= @STATE_DONE
		count = 0
		for test in testList
#			@lg "COUNT", test
			count++ if test.mState is mState
#		@lg "count[#{mState}] => #{count}"
		count



	eventFire: (eventName, primative, test, opts) ->
		_opts = opts ? @OPTS

		if !@bRunning and eventName isnt "runner-done"
#			console.log "shutting down is discard most events"
			return

		@cb eventName, primative, test, _opts, @
		@onEvent eventName, primative, test, _opts
		switch eventName
			when "CLI-optionList"
				@onEventCLIOptionList primative, _opts
			when "CLI-flag"
				@onEventCLIFlag primative, _opts
			when "left-open"
				@onEventLeftOpen primative, _opts
			when "runner-done"
				@onEventRunnerDone primative, _opts
			when "runner-start"
				@onEventRunnerStart primative, _opts
			when "test-done"
				@onEventTestDone primative, test, _opts
			when "test-start"
				@onEventTestStart primative, test, _opts
#			else
#				throw Error "UT004 EVENT NOT HANDLED: eventName=#{eventName}: Did subclass override methods pass all parameters to super.onEvent?"



#	Runner.exit
	exit: (@mWhy, msg) ->
		@assert @mWhy?
		@tassert @mWhy, "number"

		clearInterval @runnerThread
		@bRunning = false

		#TODO: stop all running async tests if any still running

		whyPhrase = "#{@WHY_LIST[@mWhy]}(#{@mWhy})#{SP.d msg, "details=#{msg}"}"
#		@lg "Runner.exit: #{whyPhrase}"
#		@lg @one()

		@secsElapsed = Math.ceil((Date.now() - @msStart) / 1000)

		if @pass or @failList.length
			console.log "#{Base.openMsgGet()}  All unit tests completed: [#{@secsElapsed} #{S.PLURAL "second", @secsElapsed}] total=#{@pass+@failList.length}: #{unless @failList.length then "PASS" else "pass"}=#{@pass} #{if @failList.length then "FAIL" else "fail"}=#{@failList.length}"

			if Base.openCntGet()
				@eventFire "left-open"

		@summary =
			fail: @failList.length
			frag: @frag = "[#{@secsElapsed}s]  pass=#{@pass} fail=#{@failList.length}"
			mWhy: @mWhy
			pass: @pass
			why: @WHY_LIST[@mWhy]
			whyPhrase: whyPhrase 
			whyMsg: msg

#		@lg "report.summary", @summary

		@eventFire "runner-done", {mWhy:@mWhy, msg:msg}

		if @failList.length
#			@lg "calling reject"
			@reject this
		else
			if trace.TRACE_DURATION_REPORT and testList.length
				s = "\nTests longer than #{trace.TRACE_DURATION_MIN_MS}ms:"

				testList.sort (a, b) -> if a.msDur > b.msDur then -1 else 1

				#TODO: for test in testList #EASY
				for i in [0..testList.length-1]
					test = testList[i]

					if test.msDur > trace.TRACE_DURATION_MIN_MS
						if s
							log s
							s = null

						#TODO: use string table thing
						log "> #{test.msDur}: #{test.tn}     #{test.path}"

#			@lg "Runner calling final resolve"
			@resolve this



	multi: ->
		s = @one()
		s += testList.reduce(((acc, test) => if test.mState is @STATE_RUNNING then acc+"\nrunning: #{test.one2()}" else acc), '')



	one: -> "UTRunner: tests=#{testList.length} enabled=#{@enabledCnt} sync=#{@syncCnt} async=#{@asyncCnt} waiting=#{@selectList.length} bRunning=#{@bRunning} running=#{@runningCnt} mutexes=#{AsyncTest.s_one()}"



#DEFAULT #OVERRIDE
	onEvent: (eventName, primative, test, opts) ->
#		@lg "Runner: onEvent: #{eventName}"
	onEventCLIOptionList: ->
	onEventCLIFlag: ->
	onEventLeftOpen: ->
	onEventRunnerDone: ->
	onEventRunnerStart: ->
	onEventTestDone: ->
	onEventTestStart: ->



# Runner.run
	run: ->
		Object.defineProperties @,
			"@who":
				enumerable: true
				value: "UNIT TEST RUNNER"
			msStart:
				value: Date.now()

		new Promise (@resolve, @reject) =>
			@testsSort()
			@CLI @argv.slice 2

#H: runner-done can be called without runner-start
#			console.log "bRunning=#{@bRunning}"
			if @bRunning
				@eventFire "runner-start"
				@testsValidate()
				@testsEnable()

#				console.log "count(STATE_WAITING)=#{@count @STATE_WAITING}"
				if @count(@STATE_WAITING) > 0
					# now that cleanup can be async can't run all sync tests instantly because after() code contains Promise code
	#				for testIndex,i in @selectList by -1
	#					if (test=testList[testIndex-1]).isAsyncRunnable()
	#						@selectList.splice i, 1
	#						@testStart test

					#HACK: utilize this timer to keep node running until all tests have completed
					@runnerThread = setInterval =>
#						@lg "RUNNING: #{@bRunning}"

						if @bRunning
							@startAnotherMaybe()
					,
						REMOVE_ME_MS
				else
					@exit @WHY_NO_TESTS_FOUND			#H: what if tests still RUNNING? (not just waiting)



	startAnotherMaybe: ->
		@assert @bRunning

		if @selectList.length is 0 and @runningCnt is 0
			@exit @WHY_ALL_TESTS_RUN
		else
#			@lg "startAnotherMaybe: syncTestsCount=#{syncTestsCount}"
			for testIndex,i in @selectList by -1
				if syncTestsCount is 0
					test = testList[testIndex-1]

					@eq test.mState, @STATE_WAITING, "test isn't in waiting state"

					if test.isAsyncRunnable()		# @lg "can't run '#{test.one()}' because mutex '#{test.opts.mutex}' already running"
						@selectList.splice i, 1
						@testStart test
					else if test.bSync
						@selectList.splice i, 1
#						@lg "STARTING NEXT TEST"
						@testStart test



	testDone: (test) ->
		@pass += test.pass

		@failList.push ...test.failList							#PATTERN #ARRAY #IN-PLACE #ARRAY-APPEND PREV:@failList = [...@failList, ...test.failList]
		@runningCnt--

		@logg trace.UT_SYS, "testDone: p/f=#{@pass}/#{@failList.length} concurrent=#{@runningCnt}: #{test.one()}: [#{@one()}]"

		if test.failList.length and @OPTS.mFailMode is @FM_FAILTEST
#			@stack _="mFailMode=@FM_FAILTEST: test failure without recovery: #{test.one2()}"
			_ = "mFailMode=@FM_FAILTEST: test failure without recovery: #{test.one2()}"
			@exit @WHY_FAIL_FAST, "#{test.failList.length} error(s)"
		else if @count(@STATE_WAITING) is 0 and @runningCnt is 0		#H: correct? or only let other area do it?
			@exit @WHY_ALL_TESTS_RUN



	testsEnable: ->
		@assert @selectList.length is 0

		if testList.length > 0
			add = (test) => @selectList.unshift test.testIndex

#			testList.forEach (test) =>
#				@lg ">" + test.one3()
#				if test.opts.bManual
#					@lg "MANUAL"

# 			-a always overrides capitals (if any happen to be set)
			if @OPTS.testsAll
				testList.forEach (test) =>
					unless test.opts.bManual
						add test
			else if @OPTS.keystrue
				for test in testList
					if O.INTERSECTION test.keys, @OPTS.keystrue		#TODO
						add test
			else if @OPTS.bAsync
				for test in testList
					if /^[aA]$/.test test.cmd
						unless test.opts.bManual
							add test
			else if @OPTS.bSync
				for test in testList
					if /^[tT]$/.test test.cmd
						unless test.opts.bManual
							add test
			else if @OPTS.testsInclude
				for testIndex in @OPTS.testsInclude.split ','
					@selectList.unshift testIndex * 1			#PATTERN
			else
# 				override capitals
				testList.forEach (test) =>
					if /^[A-Z]/.test test.cmd
#						@lg "found ut override: #{test.tn}"
						add test

			if @selectList.length is 0
# 				default scenario: no CLI #, no CLI -a, no capital overrides
				testList.forEach (test) =>
					unless test.opts.bManual
						add test

			if @OPTS.testsIgnore
# 				doesn't matter if default all (no capital overrides), -a, include list, or override capitals, you can always ignore specific tests
				for testIndex in @OPTS.testsIgnore.split ','
					@selectList = @selectList.filter (i) -> i isnt testIndex * 1

#			if @OPTS.keysfalse
#				for test in testList
#					if O.INTERSECTION test.keys, @OPTS.keysfalse
#						bTODO="remove from @selectList"

#			@lg "bOnline", @OPTS.bOnline
			unless @OPTS.bOnline
				@lg "OFFLINE"
				@selectList = @selectList.filter (i) =>
					! ( testList[i-1].tags.internet )

			for i in @selectList
				testList[i-1].enable()

			if 0
				@lg "-----> VERIFY REVERSE ORDER:"
				for i,idx in @selectList
					@lg "[#{idx}] -----> #{i} -> #{testList[i-1].one2()}"

			@enabledCnt = testList.reduce(((acc, test) -> if test.bEnabled then acc+1 else acc), 0)
			@syncCnt = testList.reduce(((acc, test) -> if test.bEnabled and test.bSync then acc+1 else acc), 0)
			@asyncCnt = testList.reduce(((acc, test) -> if test.bEnabled and !test.bSync then acc+1 else acc), 0)

			@lg "#{@summary} Found #{testList.length} #{S.PLURAL "test", testList.length}#{SP.d @enabledCnt < testList.length, "with #{@enabledCnt} enabled"}"



	testsSort: ->
		testList.reverse()				#IMPORTANT: testList must be in reverse order so that we can splice way elements and not break our iterators

		#TODO: read average test milliseconds from filesystem
#		_ = []
#		testList.forEach (test) =>
#			unless test.bSync
#				_.push test
#		testList.forEach (test) =>
#			if test.bSync
#				_.push test
#
#		testList = _

		testIndex = 1
		for test,i in testList
			test.testIndex = testIndex++
			test.runner = this
			test.bEnabled = false
			test.mStage = @STAGE_SETUP
			test.mState = @DISABLED
			test.testMutex ?= ''
#			@lg "[#{i}] pre: #{test.one()}"




	testStart: (test) ->
		@runningCnt++
#		@lg "testStart: concurrent now=#{@runningCnt}: #{test.one()}"
		test.start()



	testsValidate: ->
		for test in testList
			test.optsValidate()

		@summary = "[NEG=#{@mTypeCtrList[0]} PROOF=#{@mTypeCtrList[1]}]"
#END:UTRunner





class UT_UT extends UT		#@UT_UT		@unittest  @ut
	run: ->
		@s "@p - async return implicit Promise", ->
			@p "resolved", ->
				Promise.resolve "I am good"
			@p "rejected", expect:"EXCEPTION", mType:@NEG, ->
				Promise.reject "I am bad"
			@p "non-promise", expect:"ERROR", mType:@NEG, ->		#TODO: this is not an ERROR, it's a UT unit test problem, no?
				Math.pi
			@p "@p and @ce together", desc:"role model of how to use @p and @ce together.  see file header for full explanation", ->
				pr = @ce().run()
				.then (po) =>
					@env.d()		#WORKS
		@s "top", ->
			@t "test1", ->
			@t "test2", ->
		@s "top", ->
			@s "middle", ->
				@t "test1", ->
				@t "test2", ->
#COMMENTED-OUT
#		@t "UT events", (ut) ->
#			@testHub.startClient "/tmp/ut/UT_UT"
#			.then (client) =>
#				@log "one: #{client.one()}"
#			.catch (ex) =>
#				@logCatch "startClient", ex		#H: logCatch WHAT should be the parameter?
		@t "opts", (ut) ->
			@human "ut.opts", ut.opts
			@eq ut.opts.utUDOptionName, "utUDOptionValue"
			@log "@opts=", @opts
			@eq @opts.utUDOptionName, "utUDOptionValue"
			@eq @get42(), 42
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
					@FAIL @FAIL_ERROR, "it's illegal to assign 'clear' to bag", "", @bag
				catch ex
					@PASS()
		@s "sync nesting test", ->
			@s "a", (ut) =>
#				@log "section log"
#				@logError "section logError"
#				@logCatch "section logCatch"

				@s "b1", ->
					@t "b1c1", ->
#						@log "test log"
#						@logError "test logError"
#						@logCatch "test logCatch"
					@t "b1c2", ->
				@s "b2", ->
					@s "b2c1", ->
						@t "b2c1d1", ->
		@s "async nesting test", ->
			@s "a", ->
				@s "b1", (ut) ->
					@a "b1c1", (ut) ->
						setTimeout (=> ut.resolve()), 10
					#						@log "setTimeout"
					#						@log "asynch log"
					#						@logError "asynch logError"
					#						@logCatch "asynch logCatch"
					@a "b1c2", ->
						@resolve()
				@s "b2", ->
					@s "b2c1", ->
						@a "b2c1d1", ->
							@resolve()
		@a "@delay", ->
			@delay 50
			.then (to) =>
				@log "timed out", to
				@resolve to
		@s "eqfile", ->
			@p "same size", ->										@eqfile @filepath("deanna.png"),		@filepath("same-size.png")
			@p "different sizes", expect:"EQ", mType:@NEG, ->		@eqfile @filepath("deanna.png"),		@filepath("ut.env")
			@p "a dne", expect:"EQ", mType:@NEG, ->					@eqfile @filepath("dne.png"), 		@filepath("ut.env")
			@p "b dne", expect:"EQ", mType:@NEG, ->					@eqfile @filepath("deanna.png"), 	@filepath("dne.env")
		@s "equate", ->
			@t "single parameter", {
				expect: "EQ,EQ"
				onEq: (fail) ->
					@log "inside onEq"
#					fail.heal()
			}, ->
				@eq 1,2
				@eq "only passed one parameter"
				@eq 1,2
			@t "differing types (loose)", desc:"@eq is NOT strict, i.e., it checks VALUE only (string vs. integer is okay and passes)", ->
				@eq "5", 5
			@t "differing types (kinda POS)", desc:"@Eq is kinda strict, i.e., it checks VALUE only (string vs. string is okay and passes)", ->
				@Eq "peter", "peter"
			@t "differing types okay (kinda NEG 22222)", desc:"@Eq is kinda strict", ->		# :"EQ", mType:@NEG, ->
				@Eq "5", 5
			@t "differing types (strict POS)", {}, ->
				@EQ new String("peter"), new String("peter")
			@t "differing types (strict NEG)", expect:"EQ", desc:"@EQ is strict!, i.e., VALUE and TYPE must agree!", mType:@NEG, ->
				@EQ "peter", new String "peter"
			@t "EQO", desc:"@EQO same object", ->
				o = {a: "a"}
				@EQO o, o, "same object"
			@t "EQO neg 33333", expect:"EQ", desc:"@EQO same object", mType:@NEG, ->
				@EQO {a: "a"}, {a: "a"}, "different objects (with same object signatures)"
		@s "exceptions", ->
			@a "throw exception", expect:"EXCEPTION", mType:@NEG, ->
				throw Error "this is error"
		@s "options", ->
			@s "general", ->
				@t "commented out", _desc:"this is not used", ->
			@s "specific", ->
				@t "exceptionMessage", exceptionMessage:"Deanna is beautiful",mType:@NEG, ->
					throw Error "Deanna is beautiful"
				@s "expect", ->
					@s "assert", ->
						@t "pos", ->
							@assert true, "Saturday"
						@t "neg", {expect:"ASSERT", mType:@NEG}, ->
							@assert false, "Sunday"
					@t "bManual: fatal", {desc:"can't test because it exits node",bManual:true}, ->
						@fatal()
						@fatal "display me on console"
					@a "promise timeout", {timeout:10, expect:"TIMEOUT", mType:@NEG}, ->
#						DO NOT CALL ut.resolve()
				@a "onTimeout", {
						timeout:10
						onTimeout: (ut) ->
#							@log "opts", ut.opts			#MOST-BIZARRE BUG EVER!  the get: property of ut was opening connection:
#__76  >                                   ∟ user: ut
#__77  40:58 [TestHub] open ut
#__78  40:58 [TestHub] auditOpen SQL-ut: count=1

							@log "fail", ut.fail
							@log "onTimeout called: #{ut.opts.timeout}=#{@opts.timeout}"
							ut.fail.heal()
					}, ->
						@log "do not call resolve in order to force timeout"
				@a "timeout", timeout:1000, (ut) ->
#					@log "opts parameter"
#					O.LOG ut.opts
					@eq ut.opts.timeout, 1000
					ut.resolve()
#				@t "seek exception but don't get one", expect:"EXCEPTION",mType:@NEG, ->
#					@log "hello"
		@s "logging", ->
			@t "log no arguments", ->
				if trace.HUMAN
					@["log"]()
					@["log"]()
			@t "maxDepth 1", ->
				deep = L1:
					L2:
						L3:
							L4:
								I_AM_L5: true
				@logg trace.HUMAN, "maxDepth:0", deep, maxDepth:0			#WTF: what does this even mean?   Just give summary counts of various things
				@logg trace.HUMAN, "maxDepth:1", deep, maxDepth:1
				@logg trace.HUMAN, "maxDepth:2", deep, maxDepth:2
				@logg trace.HUMAN, "maxDepth:3", deep, maxDepth:3
				@logg trace.HUMAN, "maxDepth:4", deep, maxDepth:4
				@logg trace.HUMAN, "maxDepth:5", deep, maxDepth:5
				@logg trace.HUMAN, "maxDepth:6", deep, maxDepth:6					
			@t "maxDepth 22", ->
				L1 =
					L1P: "L1P"
					L2:
						L2P: "L2P"
						L3:
							L3P: "L3P"
							L4:
								L4P: "L4P"								
				@log "hello"
				@logg trace.HUMAN, "maxDepth:0", L1, maxDepth:0			#WTF: what does this even mean?   Just give summary counts of various things
				@logg trace.HUMAN, "maxDepth:1", L1, maxDepth:1
				@logg trace.HUMAN, "maxDepth:2", L1, maxDepth:2
				@logg trace.HUMAN, "maxDepth:3", L1, maxDepth:3
				@logg trace.HUMAN, "maxDepth:4", L1, maxDepth:4
				@logg trace.HUMAN, "maxDepth:5", L1, maxDepth:5
				@logg trace.HUMAN, "maxDepth:6", L1, maxDepth:6
			@t "logCatch", expect:"EXCEPTION", ->
				@logCatch "this is logCatch"
			@t "logError", expect:"ERROR", ->
				@logError "this is logError"
			@t "logSilent", ->
				@logSilent "you can't see me"
				@logSilent "you can't see my object", a:"a"
				@logSilent "you can't see me in red", undefined, format:"red"
				#TEST: format:red   doesn't throw right error
			@t "logTransient", ->
				@logTransient "a blip"
		@t "one", ->
			@human @one()
			@human @one2()
		@a "mutex", mutex:"J", (ut) ->
			@log "inside MUTEX"
			ut.resolve()
		@a "mutex1", mutex:"orange", (ut) ->
			@log "M1: before"
			@delay 1000
			.then =>
				@log "M1: after"
				ut.resolve()
		@a "mutex2", mutex:"orange", (ut) ->
			@log "M2: before"
			@delay 1000
			.then =>
				@log "M2: after"
				ut.resolve()
		@a "parallel 1", mutex:"P1", (ut) ->
			@log "P1: before"
			@delay 1000
			.then =>
				@log "P1: after"
				ut.resolve()
		@a "parallel 2", mutex:"P2", (ut) ->
			@log "P2: before"
			@delay 1000
			.then =>
				@log "P2: after"
				ut.resolve()
		@p "@pass", ->
			@passSetup 1, 2, (pass, passRec) =>
#				console.log "PASS: #{pass} #{@passNbr} #{@pass_resolve}"
				passRec.resolve()
		@a "pass without explicit promise pattern", ->
			_resolve = null
			promiseCreator = =>
				new Promise (resolve) =>
					_resolve = resolve
			doPass = (pass) =>
				pr = promiseCreator()
				@h "PASS=#{pass}"
				if pass is 1
					_resolve()
				else
					@resolve()
				pr
			doPass 1
			.then =>
				doPass 2
		@s "primatives", ->			# all the commands.. DEFINE TERMS!
			@t "h: header", ->
				@h "header 1"
				@h "header 2"
		@s "promises", ->
			@t "synchronous", expect:"UNEXPECTED_PROMISE", mType:@NEG, ->
				Promise.resolve()
			@a "too late", (ut) ->
#BEFORE-FIXED:
# _685  29:33 [UTRunnerFBNode] testDone: p/f=1/0 concurrent=0: #106 a UT_UT promises/too late: [UTRunner: tests=256 enabled=1 sync=0 async=1 waiting=0 bRunning=true running=0 mutexes=same (1)]
# _686  29:33 [UTRunnerFBNode] All closed.    All unit tests completed: [1 second] total=1: PASS=1 fail=0
# _687  29:33 [UT_UT/too late] one3=Test: #106 a UT_UT promises/too late: cmd=a enabled=true mState=DONE(3) mStage=1 mutex=same pf=1/0 []
# _688  29:33 [UT_UT/too late] @a returned promise. WHAT DO? resolved value= NULL
				
				#YES
#				@env = await @ce().run()
#				@env.succ()

				#NO
#				@resolve()
#				Promise.resolve()

				#NO
#				new Promise (resolve, reject) =>
#					@resolve()

				#MRC
				@resolve()
				await @delay 100			#ABOVE => async function(ut) { ... }
				return "peter"				# still returns promise because of implicit "async" above
		@t "trace.T", ->
			keep = @runner.UT
			@log "keep", keep

			trace.stackPush "UT", 55
			@eq @runner.UT, 55, "set?"
#			@log "yes show"	#, @trace
			@runner.UT = false
			@eq @runner.UT, false, "false?"
#			@log "no show"	#, @trace

			trace.stackPop "UT"

			@eq @runner.UT, keep, "keep"
#		@t "clash with built-in", {mType:@NEG}, (ut) ->
#			@log "clash"
#			drill this
#			@delay = 10			#TODO: do Proxy object and handle 'set' and check pn against all built-in pn's
#END:UT_UT





#export EXPORTED