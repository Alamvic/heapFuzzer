Class {
	#name : #HFMutatorEventBuilder,
	#superclass : #Object,
	#instVars : [
		'indexes'
	],
	#category : #'HeapFuzzer-Builders'
}

{ #category : #accessing }
HFMutatorEventBuilder class >> default [

	^ self new
]

{ #category : #building }
HFMutatorEventBuilder >> buildEventOn: aHeapFuzzer [ 
	
	| object1 object2 desiredIndex |
	
	object1 := aHeapFuzzer randomAllocationEvent.
	object1 ifNil: [ ^ HFNopEvent new ].
	object2 := aHeapFuzzer randomAllocationEvent.
		
	desiredIndex := (indexes ifNil: [ object1 objectSize ]) atRandom.
	desiredIndex > object1 objectSize ifTrue: [ ^ HFNopEvent new ].
	
	^ HFMutatorEvent new
		referer: object1;
		referee: object2;
		index: desiredIndex;
		yourself
]

{ #category : #accessing }
HFMutatorEventBuilder >> indexes [

	^ indexes
]

{ #category : #accessing }
HFMutatorEventBuilder >> indexes: anObject [

	indexes := anObject
]
