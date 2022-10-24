Class {
	#name : #HFMockEvent,
	#superclass : #HFEvent,
	#instVars : [
		'onExecute'
	],
	#category : #HeapFuzzer
}

{ #category : #'instance creation' }
HFMockEvent class >> newExecuting: aBlock [

	^ self new
		  onExecute: aBlock;
		  yourself
]

{ #category : #executing }
HFMockEvent >> executeOn: aHeapFuzzer [

	onExecute value: aHeapFuzzer
]

{ #category : #testing }
HFMockEvent >> isAllocation [
	
	^ false
]

{ #category : #accessing }
HFMockEvent >> onExecute: anObject [

	onExecute := anObject
]
