Class {
	#name : #HFIterationsTimeout,
	#superclass : #Object,
	#instVars : [
		'maxIterations'
	],
	#category : #HeapFuzzer
}

{ #category : #'as yet unclassified' }
HFIterationsTimeout >> atEnd: aFuzzer [

	^ aFuzzer eventsSize >= maxIterations
]

{ #category : #accessing }
HFIterationsTimeout >> maxIterations [

	^ maxIterations
]

{ #category : #accessing }
HFIterationsTimeout >> maxIterations: anObject [

	maxIterations := anObject
]
