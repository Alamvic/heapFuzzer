Class {
	#name : #HFMutatorEvent,
	#superclass : #HFBinaryObjectEvent,
	#instVars : [
		'index'
	],
	#category : #HeapFuzzer
}

{ #category : #building }
HFMutatorEvent class >> buildEventOn: aHeapFuzzer [ 
	
	| object1 object2 |
	
	object1 := aHeapFuzzer randomAllocationEvent.
	object1 ifNil: [ ^ HFNopEvent new ].
	object2 := aHeapFuzzer randomAllocationEvent.
	
	object1 numberOfSlots <= 0 ifTrue: [ ^ HFNopEvent new ].
	
	^ self new
		referer: object1;
		referee: object2;
		index: object1 numberOfSlots atRandom;
		yourself
]

{ #category : #executing }
HFMutatorEvent >> basicExecuteOn: aHeapFuzzer [

	| oop |

	oop := referer oop.
	(aHeapFuzzer heap memory isForwarded: oop) ifTrue:
		[oop := aHeapFuzzer heap memory followForwarded: oop].
	
	((aHeapFuzzer heap memory numSlotsOf: oop) < (index)) ifTrue: [ ^self ].
	
	aHeapFuzzer heap memory
		storePointer: index - 1
		ofObject: oop
		withValue: referee oop
]

{ #category : #executing }
HFMutatorEvent >> executeOn: aHeapFuzzer [

	"If either was already collected, this event does nothing..."
	| oop |
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

	oop := referer oop.
	(aHeapFuzzer heap memory isForwarded: oop) ifTrue:
		[oop := aHeapFuzzer heap memory followForwarded: oop].
	
	((aHeapFuzzer heap memory numSlotsOf: oop) < (index)) ifTrue: [ ^self ].
	
	aHeapFuzzer heap memory
		storePointer: index - 1
		ofObject: oop
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
