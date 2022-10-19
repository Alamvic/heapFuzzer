Class {
	#name : #HFTimeTimeout,
	#superclass : #Object,
	#instVars : [
		'maxTime'
	],
	#category : #HeapFuzzer
}

{ #category : #accessing }
HFTimeTimeout >> atEnd: aFuzzer [

	^ DateAndTime now >= (aFuzzer startTime + maxTime)
]

{ #category : #accessing }
HFTimeTimeout >> maxTime [

	^ maxTime
]

{ #category : #accessing }
HFTimeTimeout >> maxTime: anObject [

	maxTime := anObject
]
