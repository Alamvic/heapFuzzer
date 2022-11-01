Class {
	#name : #HFMassMutatorEvent,
	#superclass : #HFBinaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #building }
HFMassMutatorEvent class >> buildEventOn: aHeapFuzzer [ 
	
	| object1 object2 |
	
	object1 := aHeapFuzzer randomAllocationEvent.
	object1 ifNil: [ ^ HFNopEvent new ].
	object2 := aHeapFuzzer randomAllocationEvent.
	
	object1 numberOfSlots <= 0 ifTrue: [ ^ HFNopEvent new ].
	
	^ self new
		referer: object1;
		referee: object2;
		yourself
]

{ #category : #executing }
HFMassMutatorEvent >> basicExecuteOn: aHeapFuzzer [

	| oop |

	oop := referer oop.
	(aHeapFuzzer heap memory isForwarded: oop) ifTrue:
		[oop := aHeapFuzzer heap memory followForwarded: oop].
	
	1 to: (aHeapFuzzer heap memory numSlotsOf: oop) do: [ :index |
		aHeapFuzzer heap memory
			storePointer: index - 1
			ofObject: oop
			withValue: referee oop]
]
