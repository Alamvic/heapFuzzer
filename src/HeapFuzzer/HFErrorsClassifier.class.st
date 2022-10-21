Class {
	#name : #HFErrorsClassifier,
	#superclass : #Object,
	#instVars : [
		'path'
	],
	#category : #HeapFuzzer
}

{ #category : #classification }
HFErrorsClassifier >> classify: experimentLabel [

	| fuzzingsWithResults fuzzingsWithLabels |
	fuzzingsWithResults := self resultsFor: experimentLabel.
	fuzzingsWithLabels := fuzzingsWithResults asDictionary collect: [ :result | result label ].
	^ fuzzingsWithLabels associations groupedBy: [ :assoc | assoc value ]
]

{ #category : #classification }
HFErrorsClassifier >> exceptionsFor: experimentLabel [

	| results exceptions |
	results := self resultsFor: experimentLabel.
	exceptions := Dictionary new.
	(self fuzzingsIn: results) do: [ :heapFuzzing | 
		[ heapFuzzing basicExecute ]
			on: Error
			do: [ :ex | exceptions at: heapFuzzing put: ex freeze ] ].
	^ exceptions
]

{ #category : #classification }
HFErrorsClassifier >> experimentAt: experimentLabel [

	| ston |
	ston := STON fromStream: self filePath asFileReference readStream.
	^ ston at: experimentLabel
]

{ #category : #classification }
HFErrorsClassifier >> fileName [

	^ self subclassResponsibility
]

{ #category : #'accessing - data' }
HFErrorsClassifier >> filePath [

	^ path , '/' , self fileName
]

{ #category : #classification }
HFErrorsClassifier >> fuzzingsIn: results [

	^ self subclassResponsibility
]

{ #category : #accessing }
HFErrorsClassifier >> path [

	^ path
]

{ #category : #accessing }
HFErrorsClassifier >> path: anObject [

	path := anObject
]

{ #category : #classification }
HFErrorsClassifier >> resultsFor: experimentLabel [

	| experiment exceptions |
	experiment := self experimentAt: experimentLabel.
	^ (self fuzzingsIn: experiment) collect: [ :heapFuzzing | heapFuzzing -> heapFuzzing execute ]
]
