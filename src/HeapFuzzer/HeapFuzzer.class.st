Class {
	#name : #HeapFuzzer,
	#superclass : #Object,
	#instVars : [
		'numberOfEvents',
		'eventBuilders',
		'timeout',
		'eventsSize',
		'startTime',
		'random'
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
		  addEventBuilder: HFNewSpaceCollectionEvent frequency: 1;
		  addEventBuilder: HFOldSpaceCollectionEvent frequency: 1;
		  addEventBuilder: HFAllocationEvent frequency: 20;
		  addEventBuilder: HFMutatorEvent frequency: 20;
		  addEventBuilder: HFPinObjectEvent frequency: 10;
		  yourself
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
HeapFuzzer >> atEnd [
	
	^ timeout atEnd: self
]

{ #category : #'as yet unclassified' }
HeapFuzzer >> basicMutate: aFuzzing [

	{ 
		[ aFuzzing buildEvent: self ].
		[ aFuzzing events removeAt: (aFuzzing events size atRandom: random) ].
		[ aFuzzing events at: (aFuzzing events size atRandom: random) put: (self newEventFor: aFuzzing) ] }
		atRandom value
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
	[ 
	fuzzing setUp.
	[ self atEnd ] whileFalse: [ 
		| event |
		event := fuzzing buildEvent: self.
		event executeOn: fuzzing ].
	fuzzing tearDown ]
		on: Error
		do: [ :e | 
			^ HeapFuzzingError new
				  error: e freeze;
				  fuzzing: fuzzing;
				  yourself ].
	^ HeapFuzzingSuccess new fuzzing: fuzzing
]

{ #category : #fuzzing }
HeapFuzzer >> fuzzEvents: anInteger [

	timeout := HFIterationsTimeout new
		           maxIterations: anInteger;
		           yourself.
	^ self fuzz
]

{ #category : #fuzzing }
HeapFuzzer >> fuzzFor: aDuration [

	timeout := HFTimeTimeout new
		           maxTime: aDuration;
		           yourself.
	^ self fuzz
]

{ #category : #fuzzing }
HeapFuzzer >> initialize [

	super initialize.
	random := Random new.
	timeout := HFIterationsTimeout new
		           maxIterations: 1000;
		           yourself.
	eventsSize := 0.
	startTime := DateAndTime now.
	eventBuilders := OrderedCollection new
]

{ #category : #'as yet unclassified' }
HeapFuzzer >> mutate: aFuzzing [

	"Return a mutated copy of a fuzzing"

	| fuzzing nb |
	fuzzing := aFuzzing copy.
	
	nb := (fuzzing events size min: 5) atRandom: random.
	nb timesRepeat: [ self basicMutate: fuzzing ].
	^ fuzzing
]

{ #category : #'instance creation' }
HeapFuzzer >> newEventFor: aHeapFuzzing [ 
	
	^ (self eventBuilders atRandom: random) buildEventOn: aHeapFuzzing
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
