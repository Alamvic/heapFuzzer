Class {
	#name : #HeapFuzzer,
	#superclass : #Object,
	#instVars : [
		'numberOfEvents',
		'eventBuilders',
		'allocations',
		'timeout',
		'eventsSize',
		'startTime'
	],
	#category : #HeapFuzzer
}

{ #category : #'as yet unclassified' }
HeapFuzzer class >> forCompaction [

	^ self new
		  addEventBuilder: (HFAllocationEventBuilder default
				   objectSizes: { 0. 20. 255. 1000 };
				   objectTypes: { #array };
				   yourself)
		  frequency: 10;
		  addEventBuilder: HFPinObjectEvent frequency: 2;
		  addEventBuilder: HFAggressiveOldSpaceCollectionEvent frequency: 3;
		  yourself
]

{ #category : #'as yet unclassified' }
HeapFuzzer class >> forCornerAllocationCases [

	^ self new
		  addEventBuilder: (HFAllocationEventBuilder default
				   objectSizes: { 0. 20. 255. 100000 };
					objectTypes: { #array };
				   yourself)
		  frequency: 10;
		  addEventBuilder: HFNewSpaceCollectionEvent frequency: 1;
		  addEventBuilder: HFOldSpaceCollectionEvent frequency: 1;
		  yourself
]

{ #category : #'as yet unclassified' }
HeapFuzzer class >> forEphemerons [

	^ self new
		  addEventBuilder: (HFAllocationEventBuilder default
				   objectTypes: { #ephemeron };
				   objectSizes: { 0. 1. 2 };
				   yourself)
		  frequency: 10;
		  addEventBuilder: HFMutatorEvent frequency: 10;
		  addEventBuilder: HFNewSpaceCollectionEvent frequency: 1;
		  addEventBuilder: HFOldSpaceCollectionEvent frequency: 1;
		  yourself
]

{ #category : #'as yet unclassified' }
HeapFuzzer class >> fullRandom [

	^ self new
		eventBuilders: { 
				HFNewSpaceCollectionEvent.
				HFOldSpaceCollectionEvent }
			, (Array new: 20 withAll: HFAllocationEvent)
			, (Array new: 20 withAll: HFMutatorEvent)
			, (Array new: 10 withAll: HFPinObjectEvent);
		yourself
]

{ #category : #fuzzing }
HeapFuzzer >> addAllocation: aHFAllocationEvent [ 
	
	allocations add: aHFAllocationEvent.
	aHFAllocationEvent id: allocations size.
	^ aHFAllocationEvent
]

{ #category : #accessing }
HeapFuzzer >> addEventBuilder: event [

	eventBuilders add: event
]

{ #category : #accessing }
HeapFuzzer >> addEventBuilder: event frequency: aFrequency [

	aFrequency timesRepeat: [ eventBuilders add: event ]
]

{ #category : #fuzzing }
HeapFuzzer >> allocations [

	^ allocations
]

{ #category : #fuzzing }
HeapFuzzer >> atEnd [
	
	^ timeout atEnd: self
]

{ #category : #fuzzing }
HeapFuzzer >> eventBuilders [

	^ eventBuilders
]

{ #category : #accessing }
HeapFuzzer >> eventBuilders: anObject [

	eventBuilders := anObject
]

{ #category : #accessing }
HeapFuzzer >> eventsSize [

	^ eventsSize
]

{ #category : #fuzzing }
HeapFuzzer >> fuzz [

	| fuzzing |
	fuzzing := HeapFuzzing new.
	fuzzing setUp.
	[self atEnd] whileFalse: [ | event |
		event := self newHeapEvent.
		fuzzing addEvent: event.
		event executeOn: fuzzing
	].
	fuzzing tearDown.
	^ fuzzing
]

{ #category : #fuzzing }
HeapFuzzer >> fuzzFor: aDuration [

	timeout := HFTimeTimeout new
		           maxTime: aDuration;
		           yourself.
	^ self fuzz
]

{ #category : #fuzzing }
HeapFuzzer >> fuzzTimes: anInteger [

	timeout := HFIterationsTimeout new
		           maxIterations: anInteger;
		           yourself.
	^ self fuzz
]

{ #category : #fuzzing }
HeapFuzzer >> initialize [

	super initialize.
	timeout := HFIterationsTimeout new
		           maxIterations: 1000;
		           yourself.
	eventsSize := 0.
	startTime := DateAndTime now.
	allocations := OrderedCollection new.
	eventBuilders := OrderedCollection new
]

{ #category : #fuzzing }
HeapFuzzer >> newHeapEvent [
	
	eventsSize := eventsSize + 1.
	^ self eventBuilders atRandom buildEventOn: self
]

{ #category : #accessing }
HeapFuzzer >> numberOfEvents [

	^ numberOfEvents
]

{ #category : #accessing }
HeapFuzzer >> numberOfEvents: anObject [

	numberOfEvents := anObject
]

{ #category : #accessing }
HeapFuzzer >> startTime [

	^ startTime
]

{ #category : #fuzzing }
HeapFuzzer >> timeout: aTimeout [

	timeout := aTimeout
]
