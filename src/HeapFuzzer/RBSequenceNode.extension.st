Extension { #name : #RBSequenceNode }

{ #category : #'*HeapFuzzer' }
RBSequenceNode >> printOn: aStream [

"Ad hoc entension as printOn is se sloooowwwww to print and freeze the ui with a lot of such nodes"

	aStream
		nextPutAll: self class name;
		print: self children size.
]
