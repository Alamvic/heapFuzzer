Class {
	#name : #HeapFuzzing,
	#superclass : #Object,
	#instVars : [
		'heap',
		'events',
		'classCache',
		'count',
		'timestamp',
		'deadObjects',
		'result',
		'liveObjects',
		'coverage',
		'chooseCount',
		'effectCount',
		'score',
		'duration',
		'lastReduce'
	],
	#category : #HeapFuzzer
}

{ #category : #'ston-core' }
HeapFuzzing class >> stonAllInstVarNames [
	"Override to encode my instances using a custom set of instance variables or to define their order."
	
	^ self allInstVarNames copyWithout: 'heap'
]

{ #category : #adding }
HeapFuzzing >> addEffectiveEvent: anEvent [

	"Add an event only it is not a nop (implicit or explicit)".
	
	(anEvent maybeEffectiveOn: events) ifFalse: [  ^nil ].
	
	^ self addEvent: anEvent.
]

{ #category : #accessing }
HeapFuzzing >> addEvent: anEvent [

	events add: anEvent.
	anEvent isAllocation ifTrue: [ anEvent id: events size ].
	^ anEvent.
]

{ #category : #executing }
HeapFuzzing >> addLiveObject: aHFAllocationEvent [

	liveObjects add: aHFAllocationEvent.
	deadObjects remove: aHFAllocationEvent ifAbsent: [ ]. "Can rise from the dead" 
	^ aHFAllocationEvent
]

{ #category : #executing }
HeapFuzzing >> addRoot: anOop [

	| nextLink |
	nextLink := heap newObjectWithSlots: 2.
	heap memory storePointer: 0 ofObject: nextLink withValue: anOop.

	"Insert first in the linked list"
	heap memory
		storePointer: 1
		ofObject: nextLink
		withValue: heap keptObjectInVMVariable1.

	"Make the next link the next allocation point"
	heap keepObjectInVMVariable1: nextLink
]

{ #category : #accessing }
HeapFuzzing >> append: otherFuzzing [

	"Add a copy of all events of otherFuzzing to self"

	| otherEvents size |
	otherEvents := otherFuzzing events veryDeepCopy.
	size := events size.
	otherEvents doWithIndex: [ :e :idx | e isAllocation ifTrue: [ e id: size + idx ] ].
	self events addAll: otherEvents. 
]

{ #category : #executing }
HeapFuzzing >> basicExecute [

	self setUp.
	(1 to: self events size)
		do: [ :index | 
			| event |
			event := self events at: index.
			count := index.
			event executeOn: self. ]
		displayingProgress: [ :iteration | 
		'Fuzzing Event ' , iteration asString ].
	self tearDown
]

{ #category : #'as yet unclassified' }
HeapFuzzing >> build: anInteger events: aHeapFuzzer [ 
	anInteger timesRepeat: [ self buildEvent: aHeapFuzzer ]
]

{ #category : #accessing }
HeapFuzzing >> buildEvent: aFuzzer [

	^ self addEvent: (aFuzzer newEventFor: self).
]

{ #category : #accessing }
HeapFuzzing >> chooseCount [

	^ chooseCount
]

{ #category : #accessing }
HeapFuzzing >> chooseCount: anObject [

	chooseCount := anObject
]

{ #category : #executing }
HeapFuzzing >> classWithFormat: format fixedSlots: fixedSlots [ 
	
	| classPerSizeCache |
	classCache ifNil: [ classCache := Dictionary new ].
	classPerSizeCache := classCache at: format ifAbsentPut: [ Dictionary new ].
	^ classPerSizeCache
		at: fixedSlots
		ifAbsentPut: [ | theNewClass formatWithSlots hash |
			theNewClass := heap newOldSpaceObjectWithSlots: 3.
			theNewClass := heap memory pinObject: theNewClass.
			self assert: theNewClass ~= 0.
			formatWithSlots := format << 16 + fixedSlots. 
			heap memory 
				storePointer: "InstanceSpecificationIndex" 2
				ofObject: theNewClass
				withValue: (heap memory integerObjectOf: formatWithSlots).
			hash := heap memory ensureBehaviorHash: theNewClass.
			self addRoot: theNewClass.
			self assert: (hash between: 1 and: "1 << 22 - 1" 4194303).
			HFClassAllocation new
				oop: theNewClass;
				objectHash: hash;
				yourself ]
]

{ #category : #accessing }
HeapFuzzing >> count [
	^ count
]

{ #category : #accessing }
HeapFuzzing >> coverage [

	^ coverage
]

{ #category : #accessing }
HeapFuzzing >> coverage: anObject [

	coverage := anObject
]

{ #category : #accessing }
HeapFuzzing >> effectCount [

	^ effectCount
]

{ #category : #accessing }
HeapFuzzing >> effectCount: anObject [

	effectCount := anObject
]

{ #category : #accessing }
HeapFuzzing >> events [
	
	^ events
]

{ #category : #accessing }
HeapFuzzing >> events: aCollection [ 

	events := aCollection
]

{ #category : #executing }
HeapFuzzing >> execute [

	| startTime |

	startTime := DateAndTime now.
	result := nil.
	[ self basicExecute ]
		on: Error, Halt
		do: [ :error | 
			result := HeapFuzzingError new
				  iterations: count;
				  error: error freeze;
				  fuzzing: self;
				  yourself ].
	result ifNil: [ result := HeapFuzzingSuccess new ].
	duration := DateAndTime now - startTime.
	^ result.
]

{ #category : #'as yet unclassified' }
HeapFuzzing >> executeCoverage: collector [

	collector reset.
	result := collector basicRun: [ self execute ].
	coverage := collector collectResult.
	collector reset.
	^ result
]

{ #category : #accessing }
HeapFuzzing >> heap [
	^ heap
]

{ #category : #initialization }
HeapFuzzing >> initialize [

	super initialize.
	chooseCount := 0.
	effectCount := 0.
	
	liveObjects := OrderedCollection new.
	events := OrderedCollection new.
	timestamp := DateAndTime now.
	deadObjects := OrderedCollection new.
]

{ #category : #testing }
HeapFuzzing >> isReducible [
	
	^ self events size > 1
]

{ #category : #'as yet unclassified' }
HeapFuzzing >> postCopy [

	events := events copy.
]

{ #category : #preparing }
HeapFuzzing >> prepareHeap [

	heap := VMHeapFuzzer new.
	heap setUp.
	heap memory setCheckForLeaks: 31 "all"
]

{ #category : #printing }
HeapFuzzing >> printOn: aStream [

	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream
		nextPutAll: ' events: ';
		print: events size.
	result ifNotNil: [ 
		aStream
			nextPutAll: ' error: ';
			print: result isError ].
	coverage ifNotNil: [ 
		aStream
			nextPutAll: ' coverage: ';
			print: coverage nodes size;
			nextPutAll: ' score: ';
			print: self score ]
]

{ #category : #accessing }
HeapFuzzing >> randomAllocationEvent [

	"return nil if none.
Is used by builders for events based on other events"

	^ self randomEvent: [ :e | e isAllocation ]
]

{ #category : #'as yet unclassified' }
HeapFuzzing >> randomEvent: aBlock [

		"return nil if none.
Is used by builders for events based on other events"

	| allocs |
	allocs := events select: aBlock.
	allocs ifEmpty: [ ^ nil ].
	^ allocs atRandom
]

{ #category : #reducing }
HeapFuzzing >> reduce [

	| reducedCopy previousCopy |
	reducedCopy := self.
	previousCopy := nil.
	[ previousCopy ~= reducedCopy and: [ reducedCopy isReducible ] ] 
		whileTrue: [ 
			previousCopy := reducedCopy.
			reducedCopy := reducedCopy reduceStep ].
	lastReduce := reducedCopy.
	^ reducedCopy
]

{ #category : #reducing }
HeapFuzzing >> reduceBetween: index1 and: index2 [
	
	"Cut by half, if reproduced => ok.
	Otherwise, cut the other half, if reproduced => ok.
	Otherwise, we need to cut differently"
	
	| half result |
	half := index2 + index1 // 2.

	[ half >= 1 ] whileTrue: [
		result := self reduceBy: half.
		result ifError: [ ^ result ].
		half := half // 2
	].

	^ self
]

{ #category : #reducing }
HeapFuzzing >> reduceBy: number [

	| nextCut errorResult |
	nextCut := self events size.
	errorResult := self execute.

	[ nextCut > 0 ] whileTrue: [ 
		| beforeCut afterCut eventsWithoutCut reducedCopy result |
		afterCut := self events copyFrom: nextCut + 1 to: self events size.
		beforeCut := nextCut - number <= 0
			             ifTrue: [ #(  ) ]
			             ifFalse: [ self events copyFrom: 1 to: nextCut - number ].
		eventsWithoutCut := beforeCut , afterCut.

		reducedCopy := self copy.
		reducedCopy events: eventsWithoutCut.
		result := reducedCopy execute.
		result ifError: [ errorResult label = result label ifTrue: [ ^ result ] ].

		nextCut := nextCut - number ].

	^ HeapFuzzingSuccess new
]

{ #category : #reducing }
HeapFuzzing >> reduceStep [

	self events size <= 1 ifTrue: [ ^ self ].
	^ self reduceBetween: 1 and: self events size.
]

{ #category : #relocation }
HeapFuzzing >> relocateClassesWith: relocationMap [

	classCache ifNil: [ ^ self ].
	classCache valuesDo: [ :classPerSizeCache | 
		classPerSizeCache valuesDo: [ :e | e remapObjectOn: relocationMap ] ]
]

{ #category : #remapping }
HeapFuzzing >> remapObjects [

	| relocationMap toKill |
	relocationMap := Dictionary new.
	heap memory allObjectsDo: [ :e | 
		relocationMap at: (heap memory hashBitsOf: e) put: e.].
	
	self relocateClassesWith: relocationMap.
	toKill := OrderedCollection new.
	liveObjects do: [ :allocation | 
		allocation remapObjectOn: relocationMap.
		allocation oop ifNil: [ toKill add: allocation ] ].
	toKill do: [ :allocation | 
		liveObjects remove: allocation.
		deadObjects add: allocation. ].
]

{ #category : #preparing }
HeapFuzzing >> reset [

	classCache := nil.
	count := 0.
	liveObjects removeAll.
	deadObjects removeAll.
	events do: #reset.
	heap := nil.
]

{ #category : #accessing }
HeapFuzzing >> result [

	^ result
]

{ #category : #accessing }
HeapFuzzing >> result: anObject [

	^ result := anObject
]

{ #category : #accessing }
HeapFuzzing >> score [

	^ score
]

{ #category : #accessing }
HeapFuzzing >> score: anObject [

	score := anObject
]

{ #category : #preparing }
HeapFuzzing >> setUp [

	classCache := nil.
	count := 0.
	liveObjects removeAll.
	deadObjects removeAll.
	events do: #reset.
	self prepareHeap
]

{ #category : #'as yet unclassified' }
HeapFuzzing >> simplify [

	"Remove nop events (explicit and implicit one)"
	| oldEvents |
	oldEvents := events.
	events := OrderedCollection new.
	oldEvents do: [ :e | self addEffectiveEvent: e ]
]

{ #category : #executing }
HeapFuzzing >> tearDown [

	"Do nothing as information loss makes tests harder"
]

{ #category : #accessing }
HeapFuzzing >> timestamp [

	^ timestamp
]

{ #category : #accessing }
HeapFuzzing >> timestamp: anObject [

	timestamp := anObject
]
