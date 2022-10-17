"
HFScalabilityBenchmark new
	fuzzerBuilder: [ HeapFuzzer forEphemerons ];
	maxEvents: 1;
	run
"
Class {
	#name : #HFScalabilityBenchmark,
	#superclass : #Object,
	#instVars : [
		'fuzzerBuilder',
		'maxEvents',
		'initialIteration',
		'finalIteration'
	],
	#category : #HeapFuzzer
}

{ #category : #accessing }
HFScalabilityBenchmark >> finalIteration: anObject [

	finalIteration := anObject
]

{ #category : #adding }
HFScalabilityBenchmark >> fuzzerBuilder: aBuilder [
	
	fuzzerBuilder := aBuilder
]

{ #category : #executing }
HFScalabilityBenchmark >> initialIteration: aNumber [

	initialIteration := aNumber 
]

{ #category : #adding }
HFScalabilityBenchmark >> initialize [
	super initialize.
	maxEvents := (2 raisedTo: 8) + 1 "to allow 2^8".
	initialIteration := 0.
	finalIteration := 8
]

{ #category : #accessing }
HFScalabilityBenchmark >> maxEvents: anInteger [ 
	maxEvents := anInteger
]

{ #category : #executing }
HFScalabilityBenchmark >> run [

	| results |
	results := Dictionary new.
	(initialIteration to: finalIteration)
		do: [ :exp | 
			| numberOfEvents benchReport |
			"Test 1, 2, 4, 8 ... 2^n events"
			numberOfEvents := 2 raisedTo: exp.
			numberOfEvents > maxEvents ifTrue: [ ^ results ].

			benchReport := HFBenchmark new
				               fuzzerBuilder: [ 
					               fuzzerBuilder value
						               numberOfEvents: numberOfEvents;
						               yourself ];
				               run.
			results at: numberOfEvents put: benchReport ]
		displayingProgress: [ :exp | 
		'For events ' , (2 raisedTo: exp) asString ].
	^ results
]
