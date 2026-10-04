"
Verifies DPI selection, target base DPI calculations, active source switching, and OS zoom estimation.
"
Class {
	#name : 'OPDisplayScaleModelTest',
	#superclass : 'TestCase',
	#instVars : [
		'scaleModel',
		'initialBaseDPI',
		'initialZoomFactor'
	],
	#category : 'OpenPonk-Zoomer-Tests',
	#package : 'OpenPonk-Zoomer',
	#tag : 'Tests'
}

{ #category : 'running' }
OPDisplayScaleModelTest >> setUp [
	super setUp.
	initialBaseDPI := OSSDL2BackendWindow screenScaleFactorBaseDPI.
	initialZoomFactor := WorldMorph zoomFactor.
	scaleModel := OPDisplayScaleModel new.
	scaleModel backendBaseDPI: 96.0
]

{ #category : 'running' }
OPDisplayScaleModelTest >> tearDown [
	initialBaseDPI ifNotNil: [ :base |
		OSSDL2BackendWindow screenScaleFactorBaseDPI: base ].
	initialZoomFactor ifNotNil: [ :zoom |
		WorldMorph zoomFactor: zoom ].
	super tearDown
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testApplyBaseDPIResetsWorldMorphZoomFactor [
	WorldMorph zoomFactor: 2.
	scaleModel applyBaseDPI: 96.0.
	self assert: WorldMorph zoomFactor equals: 1
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testAssumedDPIIndependentOfCurrentBackendBaseDPI [
	scaleModel backendBaseDPI: 120.0.
	scaleModel diagonalDPI: 96.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	self assert: scaleModel assumedDPI equals: 120.0
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testAssumedDPIPrefersScaledAxisWhenDiagonalIsBogus [
	scaleModel diagonalDPI: 96.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	self assert: scaleModel assumedDPI equals: 120.0
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testAvailableTargetZoomPercentagesIncludesDefaultZoom [
	scaleModel backendBaseDPI: 120.0.
	scaleModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	"Current effective zoom is 100 %, default uncompensated zoom is 125 %"
	self assert: scaleModel availableTargetZoomPercentages equals: #( 100 125 200 300 )
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testAvailableTargetZoomPercentagesIncludesNonStandardCurrentZoom [
	scaleModel backendBaseDPI: 96.0.
	scaleModel diagonalDPI: 96.0 horizontalDPI: 96.0 verticalDPI: 96.0.
	self assert: scaleModel availableTargetZoomPercentages equals: #( 100 200 300 ).

	scaleModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	self assert: scaleModel availableTargetZoomPercentages equals: #( 100 125 200 300 )
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testComputedBaseDPIForTargetPercentages [
	| measuredDpi |
	measuredDpi := 120.0.
	self assert: (scaleModel computedBaseDPIForTargetPercentage: 100 usingDPI: measuredDpi) equals: 120.0.
	self assert: (scaleModel computedBaseDPIForTargetPercentage: 200 usingDPI: measuredDpi) equals: 60.0.
	self assert: (scaleModel computedBaseDPIForTargetPercentage: 300 usingDPI: measuredDpi) equals: 40.0
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testComputedTargetBaseDPIForSelectedSource [
	scaleModel diagonalDPI: 96.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	scaleModel activeSource: #assumed.
	self assert: (scaleModel computedTargetBaseDPIFor: 100) equals: 120.0.
	self assert: (scaleModel computedTargetBaseDPIFor: 200) equals: 60.0.
	scaleModel activeSource: #diagonal.
	self assert: (scaleModel computedTargetBaseDPIFor: 100) equals: 96.0.
	self assert: (scaleModel computedTargetBaseDPIFor: 200) equals: 48.0
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testCurrentEffectiveZoomPercentage [
	scaleModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	scaleModel backendBaseDPI: 96.0.
	self assert: scaleModel currentEffectiveZoomPercentage equals: 125.

	scaleModel backendBaseDPI: 120.0.
	self assert: scaleModel currentEffectiveZoomPercentage equals: 100
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testDefaultZoomPercentage [
	scaleModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	self assert: scaleModel defaultZoomPercentage equals: 125.

	scaleModel diagonalDPI: 96.0 horizontalDPI: 96.0 verticalDPI: 96.0.
	self assert: scaleModel defaultZoomPercentage equals: 100
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testEstimatedOSZoomPercentage [
	self assert: (scaleModel estimatedOSZoomFor: 96.0) equals: 100.
	self assert: (scaleModel estimatedOSZoomFor: 120.0) equals: 125.
	self assert: (scaleModel estimatedOSZoomFor: 144.0) equals: 150.
	self assert: (scaleModel estimatedOSZoomFor: 192.0) equals: 200
]

{ #category : 'tests' }
OPDisplayScaleModelTest >> testSelectedDPIUsesActiveSource [
	scaleModel diagonalDPI: 96.0 horizontalDPI: 120.0 verticalDPI: 144.0.
	scaleModel activeSource: #assumed.
	self assert: scaleModel selectedDPI equals: 120.0.
	scaleModel activeSource: #diagonal.
	self assert: scaleModel selectedDPI equals: 96.0.
	scaleModel activeSource: #horizontal.
	self assert: scaleModel selectedDPI equals: 120.0.
	scaleModel activeSource: #vertical.
	self assert: scaleModel selectedDPI equals: 144.0
]
