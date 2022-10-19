Class {
	#name : #HeapFuzzing,
	#superclass : #Object,
	#instVars : [
		'heap',
		'allocations',
		'events',
		'classCache',
		'count'
	],
	#category : #HeapFuzzer
}

{ #category : #'ston-core' }
HeapFuzzing class >> stonAllInstVarNames [
	"Override to encode my instances using a custom set of instance variables or to define their order."
	
	^ self allInstVarNames copyWithout: 'heap'
]

{ #category : #accessing }
HeapFuzzing >> addEvent: anEvent [

	events add: anEvent.
	anEvent isAllocation ifTrue: [ allocations add: anEvent ]
]

{ #category : #configuring }
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
HeapFuzzing >> allocations [
	
	^ allocations
]

{ #category : #fuzzing }
HeapFuzzing >> basicExecute [

	self setUp.
	(1 to: self events size)
		do: [ :index | 
			| event |
			event := self events at: index.
			count := index.
			event executeOn: self ]
		displayingProgress: [ :iteration | 
		'Fuzzing Event ' , iteration asString ].
	self tearDown
]

{ #category : #building }
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
HeapFuzzing >> events [
	
	^ events
]

{ #category : #accessing }
HeapFuzzing >> events: aCollection [ 

	events := aCollection.
	allocations := events select: [ :e | e isAllocation ].
	allocations do: #reset.
]

{ #category : #fuzzing }
HeapFuzzing >> execute [

	"Restart the heap"

	[ self basicExecute ]
		on: Error , Halt
		do: [ :error | 
			^ HeapFuzzingError new
				  iterations: count;
				  error: error freeze;
				  fuzzing: self;
				  yourself ].
	^ HeapFuzzingSuccess new
]

{ #category : #accessing }
HeapFuzzing >> heap [
	^ heap
]

{ #category : #initialization }
HeapFuzzing >> initialize [

	super initialize.
	allocations := OrderedCollection new.
	events := OrderedCollection new
]

{ #category : #testing }
HeapFuzzing >> isReducible [
	
	^ self events size > 1
]

{ #category : #preparing }
HeapFuzzing >> prepareHeap [

	heap := VMHeapFuzzer new.
	heap setUp.
	heap memory setCheckForLeaks: 31 "all"
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
	^ reducedCopy
]

{ #category : #reduction }
HeapFuzzing >> reduceBetween: index1 and: index2 [
	
	"Cut by half, if reproduced => ok.
	Otherwise, cut the other half, if reproduced => ok.
	Otherwise, we need to cut differently"
	
	| half reducedCopy result |
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

	| nextCut |
	nextCut := self events size.

	[ nextCut > 0 ] whileTrue: [ 
		| beforeCut afterCut eventsWithoutCut reducedCopy result |
		afterCut := self events copyFrom: nextCut + 1 to: self events size.
		beforeCut := nextCut - number <= 0
			            ifTrue: [ #(  ) ]
			            ifFalse: [ 
			            self events
				            copyFrom: 1
				            to: nextCut - number ].
		eventsWithoutCut := beforeCut , afterCut.

		reducedCopy := self copy.
		reducedCopy events: eventsWithoutCut.
		result := reducedCopy execute.
		result ifError: [ ^ result ].

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

	| relocationMap |
	relocationMap := Dictionary new.
	heap memory allObjectsDo: [ :e | 
		relocationMap at: (heap memory hashBitsOf: e) put: e.].
	
	self relocateClassesWith: relocationMap.
	allocations do: [ :allocation | allocation remapObjectOn: relocationMap ].
]

{ #category : #preparing }
HeapFuzzing >> setUp [

	classCache := nil.
	count := 0.
	self prepareHeap
]

{ #category : #fuzzing }
HeapFuzzing >> tearDown [

	^ events do: #reset
]
