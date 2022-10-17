Class {
	#name : #HeapFuzzer,
	#superclass : #Object,
	#instVars : [
		'numberOfEvents',
		'eventBuilders',
		'allocations'
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
HeapFuzzer >> buildEvents [

	^ Array streamContents: [ :str |
		1 to: numberOfEvents do: [ :i |
			str nextPut: self newHeapEvent ] ]
	
]

{ #category : #fuzzing }
HeapFuzzer >> eventBuilders [

	^ eventBuilders
]

{ #category : #accessing }
HeapFuzzer >> eventBuilders: anObject [

	eventBuilders := anObject
]

{ #category : #fuzzing }
HeapFuzzer >> fuzz [

	| fuzzing |
	fuzzing := HeapFuzzing new events: self buildEvents.
	^ fuzzing execute
]

{ #category : #fuzzing }
HeapFuzzer >> initialize [

	super initialize.
	numberOfEvents := 100.
	allocations := OrderedCollection new.
	eventBuilders := OrderedCollection new
]

{ #category : #fuzzing }
HeapFuzzer >> newHeapEvent [
	
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
