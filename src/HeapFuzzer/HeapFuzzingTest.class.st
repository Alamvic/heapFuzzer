"
A HeapFuzzingTest is a test class for testing the behavior of HeapFuzzing
"
Class {
	#name : #HeapFuzzingTest,
	#superclass : #TestCase,
	#category : #HeapFuzzer
}

{ #category : #test }
HeapFuzzingTest >> testAppend [

	| fuzzing1 fuzzing2 nop obj mut |
	fuzzing1 := HeapFuzzing new.
	nop := fuzzing1 addEvent: HFNopEvent new.

	fuzzing2 := HeapFuzzing new.
	obj := fuzzing2 addEvent: (HFAllocationEvent new).
	fuzzing2 addEvent: (HFMutatorEvent new referer: obj; referee: obj).
	
	fuzzing1 append: fuzzing2.
	
	obj := fuzzing1 events at: 2.
	mut := fuzzing1 events at: 3.
	
	self assert: fuzzing1 events size equals: 3.

	self assert: (fuzzing1 events at: 1) equals: nop.
	self assert: mut referer equals: obj.
	self assert: mut referee equals: obj.

]

{ #category : #test }
HeapFuzzingTest >> testAppendSelf [

	| fuzzing obj1 mut1 obj2 mut2 |
	fuzzing := HeapFuzzing new.
	obj1 := fuzzing addEvent: (HFAllocationEvent new).
	mut1 := fuzzing addEvent: (HFMutatorEvent new referer: obj1; referee: obj1).
	
	fuzzing append: fuzzing.
	
	obj2 := fuzzing events at: 3.
	mut2 := fuzzing events at: 4.
	
	self assert: fuzzing events size equals: 4.

	self assert: (fuzzing events at: 1) equals: obj1.
	self assert: (fuzzing events at: 2) equals: mut1.
	self deny:   (fuzzing events at: 1) equals: obj2.
	self deny:   (fuzzing events at: 2) equals: mut2.

	self assert: mut1 referer equals: obj1.
	self assert: mut1 referee equals: obj1.
	self assert: mut2 referer equals: obj2.
	self assert: mut2 referee equals: obj2.

]

{ #category : #test }
HeapFuzzingTest >> testExecute [

	| fuzzing result |
	fuzzing := HeapFuzzing new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	result := fuzzing execute.
	
	self assert: result isError not
]

{ #category : #test }
HeapFuzzingTest >> testExecuteEmpty [

	| fuzzing result |
	fuzzing := HeapFuzzing new.
	result := fuzzing execute.
	
	self assert: result isError not
]

{ #category : #test }
HeapFuzzingTest >> testExecutePoison [

	| fuzzing result |
	fuzzing := HeapFuzzing new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFPoisonEvent new.
	result := fuzzing execute.
	
	self assert: result isError
]

{ #category : #test }
HeapFuzzingTest >> testExecuteRemap [

	| fuzzing obj1 obj2 obj3 result |
	fuzzing := HeapFuzzing new.
	obj1 := fuzzing addEvent: (HFAllocationEvent new
		objectType: #array;
		objectSize: 50;
		isNew: false;
		isRoot: false;
		yourself).
	obj2 := fuzzing addEvent: (HFAllocationEvent new
		objectType: #array;
		objectSize: 50;
		isNew: false;
		isRoot: true;
		yourself).
	obj3 := fuzzing addEvent: (HFAllocationEvent new
		objectType: #array;
		objectSize: 50;
		isNew: false;
		isRoot: true;
		yourself).
	fuzzing addEvent: (HFAggressiveOldSpaceCollectionEvent new).
	fuzzing addEvent: (HFMutatorEvent new
		referer: obj3;
		referee: obj2;
		index: 25;
		yourself).
	fuzzing addEvent: (HFAggressiveOldSpaceCollectionEvent new).
	result := fuzzing basicExecute.
	
	self deny:   (obj1 isMaybeAliveIn: fuzzing).
	self assert: (obj2 isMaybeAliveIn: fuzzing).
	self assert: (obj3 isMaybeAliveIn: fuzzing).
]

{ #category : #tests }
HeapFuzzingTest >> testNewCollectedObjectIsDead [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: true;
		isRoot: false;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFNewSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self deny: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #tests }
HeapFuzzingTest >> testNewCollectedObjectIsLive [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: true;
		isRoot: true;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFNewSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self assert: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #test }
HeapFuzzingTest >> testNewEventFor [

	| fuzzer fuzzing event |
	fuzzer := HeapFuzzer new.
	fuzzing := HeapFuzzing new.
	fuzzer addEventBuilder: HFNopEvent.
	
	event := fuzzer newEventFor: fuzzing.
	self assert: event class equals: HFNopEvent.
	self assert: fuzzing events isEmpty.
	
	event := fuzzing buildEvent: fuzzer.
	self assert: event class equals: HFNopEvent.
	self assert: fuzzing events size equals: 1.

]

{ #category : #tests }
HeapFuzzingTest >> testOldCollectedObjectIsDead [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: false;
		isRoot: false;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFOldSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self deny: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #tests }
HeapFuzzingTest >> testOldCollectedObjectIsLive [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: false;
		isRoot: true;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFOldSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self assert: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #test }
HeapFuzzingTest >> testRandomAllocationEvent [

	| fuzzing evt |
	fuzzing := HeapFuzzing new.
	self assert: fuzzing randomAllocationEvent equals: nil.

	evt := fuzzing addEvent: HFNopEvent new.
	self assert: fuzzing randomAllocationEvent equals: nil.
	
	evt := fuzzing addEvent: HFAllocationEvent new.
	self assert: fuzzing randomAllocationEvent equals: evt.
]

{ #category : #test }
HeapFuzzingTest >> testReduce [

	| fuzzing reduced poison |
	fuzzing := HeapFuzzing new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	poison := fuzzing addEvent: HFPoisonEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing execute.
	reduced := fuzzing reduce.
	
	self assert: reduced fuzzing events size equals: 1.
	self assert: reduced fuzzing events first equals: poison.
]
