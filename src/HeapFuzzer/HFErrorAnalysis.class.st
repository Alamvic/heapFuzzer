Class {
	#name : #HFErrorAnalysis,
	#superclass : #Object,
	#instVars : [
		'path'
	],
	#category : #HeapFuzzer
}

{ #category : #classification }
HFErrorAnalysis >> classify: experimentLabel [

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
HFErrorAnalysis >> exceptionsFor: experimentLabel [

	| ston exceptions |
	ston := STON fromStream: path asFileReference readStream.
	exceptions := Dictionary new.
	(ston at: experimentLabel) flattened do: [ :assoc | 
		| heapFuzzzing |
		heapFuzzzing := assoc value.
		[ heapFuzzzing basicExecute ]
			on: Error
			do: [ :ex | exceptions at: assoc value put: ex freeze ] ].
	^ exceptions
]

{ #category : #classification }
HFErrorAnalysis >> interestingContextForException: anException [

	| context |
	context := anException signalContext.
	[ context isNotNil ] whileTrue: [ 
		(self isInterestingPackage: context methodClass package name) 
			ifTrue: [ ^ context ].
		context := context sender ].
	^ nil
]

{ #category : #classification }
HFErrorAnalysis >> isInterestingPackage: packageName [

	^ packageName = #VMMaker
]

{ #category : #classification }
HFErrorAnalysis >> labelForContext: context [

	^ { 
		  context selector.
		  context sender selector.
		  context sender sender selector.
		  context sender sender sender selector } joinUsing: '<'
]

{ #category : #accessing }
HFErrorAnalysis >> path [

	^ path
]

{ #category : #accessing }
HFErrorAnalysis >> path: anObject [

	path := anObject
]
