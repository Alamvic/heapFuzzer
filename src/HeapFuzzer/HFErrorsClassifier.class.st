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

	| errorsWithExceptions errorsWithInterestingExceptions errorsWithLabels |
	errorsWithExceptions := self exceptionsFor: experimentLabel.

	errorsWithInterestingExceptions := errorsWithExceptions collect: [ 
		                                   :ex | 
		                                   self 
			                                   interestingContextForException:
			                                   ex ].

	errorsWithLabels := errorsWithInterestingExceptions collect: [ 
		                    :context | self labelForContext: context ].

	^ errorsWithLabels associations groupedBy: [ :assoc | assoc value ]
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

{ #category : #classification }
HFErrorsClassifier >> interestingContextForException: anException [

	| context |
	context := anException signalContext.
	[ context isNotNil ] whileTrue: [ 
		(self isInterestingPackage: context methodClass package name) 
			ifTrue: [ ^ context ].
		context := context sender ].
	^ nil
]

{ #category : #classification }
HFErrorsClassifier >> isInterestingPackage: packageName [

	^ packageName = #VMMaker
]

{ #category : #classification }
HFErrorsClassifier >> labelForContext: context [

	context ifNil: [ ^ nil ].

	^ { 
		  context selector.
		  context sender selector.
		  context sender sender selector.
		  context sender sender sender selector } joinUsing: '<'
]

{ #category : #accessing }
HFErrorsClassifier >> path [

	^ path
]

{ #category : #accessing }
HFErrorsClassifier >> path: anObject [

	path := anObject
]

{ #category : #'accessing - data' }
HFErrorsClassifier >> resultsFor: experimentLabel [

	| ston |
	ston := STON fromStream: self filePath asFileReference readStream.
	^ ston at: experimentLabel
]
