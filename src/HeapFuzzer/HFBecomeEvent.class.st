Class {
	#name : #HFBecomeEvent,
	#superclass : #HFEvent,
	#instVars : [
		'referee',
		'referer',
		'copyHash',
		'twoWay'
	],
	#category : #HeapFuzzer
}

{ #category : #building }
HFBecomeEvent class >> buildEventOn: aHeapFuzzer [ 
	
	| object1 object2 |
	
	object1 := aHeapFuzzer randomAllocationEvent.
	object1 ifNil: [ ^ HFNopEvent new ].
	object2 := aHeapFuzzer randomAllocationEvent.
	
	^ self new
		referer: object1;
		referee: object2;
		twoWay: ({ true. false } atRandom);
		copyHash: ({ true. false } atRandom);
		yourself
]

{ #category : #accessing }
HFBecomeEvent >> copyHash [

	^ copyHash
]

{ #category : #accessing }
HFBecomeEvent >> copyHash: anObject [

	copyHash := anObject
]

{ #category : #executing }
HFBecomeEvent >> executeOn: aFuzzing [

	| array1 array2 |
	
	"If either was already collected, this event does nothing..."
	referer oop ifNil: [ ^ self ].
	referee oop ifNil: [ ^ self ].

	(aFuzzing heap memory addressCouldBeOop: referer oop)
		ifFalse: [ ^ self ].
	(aFuzzing heap memory addressCouldBeOop: referee oop)
		ifFalse: [ ^ self ].


	((aFuzzing heap memory hashBitsOf: referer oop)
		= referer objectHash) ifFalse: [ ^ self ].

	((aFuzzing heap memory hashBitsOf: referee oop)
		= referee objectHash) ifFalse: [ ^ self ].

	array1 := aFuzzing heap newArrayWithSlots: 1.
	array2 := aFuzzing heap newArrayWithSlots: 1.
	aFuzzing heap memory storePointer: 0 ofObject: array1 withValue: referer oop.
	aFuzzing heap memory storePointer: 0 ofObject: array2 withValue: referee oop.
	
	aFuzzing heap memory become: array1 with: array2 twoWay: twoWay copyHash: copyHash.
]

{ #category : #printing }
HFBecomeEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: referer id;
		nextPutAll: '-->';
		print: referee id;
		nextPutAll: ' twoWay:';
		print: twoWay;
		nextPutAll: ' copyHash:';
		print: copyHash;
		nextPut: $)
]

{ #category : #accessing }
HFBecomeEvent >> referee [

	^ referee
]

{ #category : #accessing }
HFBecomeEvent >> referee: anObject [

	referee := anObject
]

{ #category : #accessing }
HFBecomeEvent >> referer [

	^ referer
]

{ #category : #accessing }
HFBecomeEvent >> referer: anObject [

	referer := anObject
]

{ #category : #initialization }
HFBecomeEvent >> reset [

	referer reset.
	referee reset.
]

{ #category : #accessing }
HFBecomeEvent >> twoWay [

	^ twoWay
]

{ #category : #accessing }
HFBecomeEvent >> twoWay: anObject [

	twoWay := anObject
]
