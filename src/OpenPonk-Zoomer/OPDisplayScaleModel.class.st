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
		'activeSource',
		'backendBaseDPI'
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
	backendBaseDPI := aFloat asFloat.
	OSSDL2BackendWindow screenScaleFactorBaseDPI: backendBaseDPI.
	WorldMorph zoomFactor: 1
]

{ #category : 'calculating' }
OPDisplayScaleModel >> assumedDPI [

	(horizontalDPI closeTo: verticalDPI) ifTrue: [ ^ horizontalDPI ].
	(horizontalDPI closeTo: self defaultBaseDPI) ifFalse: [ ^ horizontalDPI ].
	(verticalDPI closeTo: self defaultBaseDPI) ifFalse: [ ^ verticalDPI ].
	(diagonalDPI closeTo: self defaultBaseDPI) ifFalse: [ ^ diagonalDPI ].
	^ self defaultBaseDPI
]

{ #category : 'calculating' }
OPDisplayScaleModel >> availableTargetZoomPercentages [
	| options currentEffective defaultZoom |
	options := Set withAll: #( 100 200 300 ).
	currentEffective := self currentEffectiveZoomPercentage.
	currentEffective > 0 ifTrue: [ options add: currentEffective ].
	defaultZoom := self defaultZoomPercentage.
	defaultZoom > 0 ifTrue: [ options add: defaultZoom ].
	^ options asSortedCollection asArray
]

{ #category : 'accessing' }
OPDisplayScaleModel >> backendBaseDPI [
	^ backendBaseDPI
]

{ #category : 'accessing' }
OPDisplayScaleModel >> backendBaseDPI: aFloat [
	backendBaseDPI := aFloat ifNotNil: [ :value | value asFloat ]
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
	^ backendBaseDPI ifNil: [ OSSDL2BackendWindow screenScaleFactorBaseDPI ]
]

{ #category : 'calculating' }
OPDisplayScaleModel >> currentEffectiveZoomPercentage [
	| base |
	base := self currentBackendBaseDPI.
	(base isNil or: [ base isZero ]) ifTrue: [ ^ 100 ].
	^ ((self selectedDPI / base) * 100) rounded
]

{ #category : 'constants' }
OPDisplayScaleModel >> defaultBaseDPI [

	^ OSPlatform current osWindowScreenScaleFactorBaseDPI
]

{ #category : 'calculating' }
OPDisplayScaleModel >> defaultZoomPercentage [
	^ self estimatedOSZoomFor: self selectedDPI
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
	[
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
	] on: Error do: [
		diagonalDPI := self defaultBaseDPI.
		horizontalDPI := self defaultBaseDPI.
		verticalDPI := self defaultBaseDPI ]
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
