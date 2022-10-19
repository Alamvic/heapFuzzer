Class {
	#name : #HFReducedErrorsClassifier,
	#superclass : #HFErrorsClassifier,
	#category : #HeapFuzzer
}

{ #category : #accessing }
HFReducedErrorsClassifier >> fileName [

	^ 'reduced.ston'
]

{ #category : #classification }
HFReducedErrorsClassifier >> fuzzingsIn: results [

	^ results flattened collect: [ :assoc | assoc value ]
]
