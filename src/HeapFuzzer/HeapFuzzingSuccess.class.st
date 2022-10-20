Class {
	#name : #HeapFuzzingSuccess,
	#superclass : #HeapFuzzingResult,
	#category : #HeapFuzzer
}

{ #category : #control }
HeapFuzzingSuccess >> ifError: aFullBlockClosure [ 
	
	^ self
]

{ #category : #testing }
HeapFuzzingSuccess >> isError [
	
	^ false
]

{ #category : #testing }
HeapFuzzingSuccess >> isReducible [
	
	^ false
]
