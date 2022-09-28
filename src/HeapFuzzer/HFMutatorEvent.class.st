Class {
	#name : #HFMutatorEvent,
	#superclass : #Object,
	#instVars : [
		'referer',
		'referee',
		'index'
	],
	#category : #'HeapFuzzer-Core'
}

{ #category : #building }
HFMutatorEvent class >> buildEventOn: aHeapFuzzer [ 
	
	| object1 object2 |
	aHeapFuzzer allocations ifEmpty: [ ^ HFNopEvent new ].
	
	object1 := aHeapFuzzer allocations atRandom.
	object2 := aHeapFuzzer allocations atRandom.
	
	^ self new
		referer: object1;
		referee: object2;
		index: object1 numberOfSlots atRandom;
		yourself
]

{ #category : #executing }
HFMutatorEvent >> executeOn: aHeapFuzzer [

	"If either was already collected, this event does nothing..."
	referer oop ifNil: [ ^ self ].
	referee oop ifNil: [ ^ self ].

	(aHeapFuzzer heap memory addressCouldBeOop: referer oop)
		ifFalse: [ ^ self ].
	(aHeapFuzzer heap memory addressCouldBeOop: referee oop)
		ifFalse: [ ^ self ].


	((aHeapFuzzer heap memory hashBitsOf: referer oop)
		= referer objectHash) ifFalse: [ ^ self ].

	((aHeapFuzzer heap memory hashBitsOf: referee oop)
		= referee objectHash) ifFalse: [ ^ self ].
	
	aHeapFuzzer heap memory
		storePointer: index - 1
		ofObject: referer oop
		withValue: referee oop
]

{ #category : #accessing }
HFMutatorEvent >> index [

	^ index
]

{ #category : #accessing }
HFMutatorEvent >> index: anObject [

	index := anObject
]

{ #category : #testing }
HFMutatorEvent >> isAllocation [
	
	^ false
]

{ #category : #printing }
HFMutatorEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: referer id;
		nextPutAll: '--';
		print: index;
		nextPutAll: '-->';
		print: referee id;
		nextPut: $)
]

{ #category : #accessing }
HFMutatorEvent >> referee [

	^ referee
]

{ #category : #accessing }
HFMutatorEvent >> referee: anObject [

	referee := anObject
]

{ #category : #accessing }
HFMutatorEvent >> referer [

	^ referer
]

{ #category : #accessing }
HFMutatorEvent >> referer: anObject [

	referer := anObject
]

{ #category : #resetting }
HFMutatorEvent >> reset [
	
	referer reset.
	referee reset.
]
