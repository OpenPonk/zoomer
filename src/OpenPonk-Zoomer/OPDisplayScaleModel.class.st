"
Calculates display scale metrics, estimates operating system zoom levels, and computes target base DPI adjustments for the OSSDL2BackendWindow in Pharo.
"
Class {
	#name : 'OPDisplayScaleModel',
	#superclass : 'Object',
	#instVars : [
		'diagonalDPI',
		'horizontalDPI',
		'verticalDPI',
		'activeSource'
	],
	#category : 'OpenPonk-Zoomer-Model',
	#package : 'OpenPonk-Zoomer',
	#tag : 'Model'
}

{ #category : 'accessing' }
OPDisplayScaleModel >> activeSource [
	^ activeSource
]

{ #category : 'accessing' }
OPDisplayScaleModel >> activeSource: aSymbol [
	activeSource := aSymbol
]

{ #category : 'actions' }
OPDisplayScaleModel >> applyBaseDPI: aFloat [
	OSSDL2BackendWindow screenScaleFactorBaseDPI: aFloat asFloat
]

{ #category : 'calculating' }
OPDisplayScaleModel >> assumedDPI [

	((horizontalDPI closeTo: verticalDPI) and: [ (horizontalDPI closeTo: self defaultBaseDPI) not ]) ifTrue: [ ^ horizontalDPI ].
	(horizontalDPI closeTo: self defaultBaseDPI) ifFalse: [ ^ horizontalDPI ].
	(verticalDPI closeTo: self defaultBaseDPI) ifFalse: [ ^ verticalDPI ].
	(diagonalDPI closeTo: self defaultBaseDPI) ifFalse: [ ^ diagonalDPI ].
	^ self defaultBaseDPI
]

{ #category : 'calculating' }
OPDisplayScaleModel >> computedBaseDPIForTargetPercentage: aPercentage usingDPI: aDPI [
	^ ((aDPI * 100.0) / aPercentage) asFloat
]

{ #category : 'calculating' }
OPDisplayScaleModel >> computedTargetBaseDPIFor: aPercentage [
	^ self computedBaseDPIForTargetPercentage: aPercentage usingDPI: self selectedDPI
]

{ #category : 'accessing' }
OPDisplayScaleModel >> currentBackendBaseDPI [
	^ OSSDL2BackendWindow screenScaleFactorBaseDPI
]

{ #category : 'constants' }
OPDisplayScaleModel >> defaultBaseDPI [
	^ 96.0
]

{ #category : 'accessing' }
OPDisplayScaleModel >> diagonalDPI [
	^ diagonalDPI
]

{ #category : 'accessing' }
OPDisplayScaleModel >> diagonalDPI: aFloat horizontalDPI: anotherFloat verticalDPI: aThirdFloat [
	diagonalDPI := aFloat asFloat.
	horizontalDPI := anotherFloat asFloat.
	verticalDPI := aThirdFloat asFloat
]

{ #category : 'calculating' }
OPDisplayScaleModel >> estimatedOSZoomFor: aDPI [
	^ ((aDPI / self defaultBaseDPI) * 100) rounded
]

{ #category : 'accessing' }
OPDisplayScaleModel >> horizontalDPI [
	^ horizontalDPI
]

{ #category : 'initialization' }
OPDisplayScaleModel >> initialize [
	super initialize.
	activeSource := #assumed.
	diagonalDPI := self defaultBaseDPI.
	horizontalDPI := self defaultBaseDPI.
	verticalDPI := self defaultBaseDPI
]

{ #category : 'actions' }
OPDisplayScaleModel >> readDisplayDPI [
	ExternalAddress allocateMemoryOfSizes: #( 4 4 4 ) during: [ :ddpi :hdpi :vdpi |
		| returnCode |
		returnCode := SDL2 getDisplay: 0 ddpi: ddpi hdpi: hdpi vdpi: vdpi.
		returnCode isZero
			ifTrue: [
				diagonalDPI := (ddpi floatAt: 1) asFloat.
				horizontalDPI := (hdpi floatAt: 1) asFloat.
				verticalDPI := (vdpi floatAt: 1) asFloat ]
			ifFalse: [
				diagonalDPI := self defaultBaseDPI.
				horizontalDPI := self defaultBaseDPI.
				verticalDPI := self defaultBaseDPI ] ]
]

{ #category : 'actions' }
OPDisplayScaleModel >> resetToDefaultBaseDPI [
	self applyBaseDPI: self defaultBaseDPI
]

{ #category : 'calculating' }
OPDisplayScaleModel >> selectedDPI [
	activeSource = #diagonal ifTrue: [ ^ diagonalDPI ].
	activeSource = #horizontal ifTrue: [ ^ horizontalDPI ].
	activeSource = #vertical ifTrue: [ ^ verticalDPI ].
	^ self assumedDPI
]

{ #category : 'accessing' }
OPDisplayScaleModel >> verticalDPI [
	^ verticalDPI
]
