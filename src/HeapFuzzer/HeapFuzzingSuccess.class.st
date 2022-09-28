Class {
	#name : #HeapFuzzingSuccess,
	#superclass : #Object,
	#category : #'HeapFuzzer-Core'
}

{ #category : #control }
HeapFuzzingSuccess >> ifError: aFullBlockClosure [ 
	
	^ self
]

{ #category : #testing }
HeapFuzzingSuccess >> isReducible [
	
	^ false
]