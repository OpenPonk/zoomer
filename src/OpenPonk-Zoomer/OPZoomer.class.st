"
Provides an interactive Spec 2 interface to inspect display metrics and apply target base DPI compensations for SDL2 backend windows.
"
Class {
	#name : 'OPZoomer',
	#superclass : 'SpPresenter',
	#instVars : [
		'scaleModel',
		'assumedRadio',
		'diagonalRadio',
		'horizontalRadio',
		'verticalRadio',
		'assumedDpiLabel',
		'diagonalDpiLabel',
		'horizontalDpiLabel',
		'verticalDpiLabel',
		'assumedZoomLabel',
		'diagonalZoomLabel',
		'horizontalZoomLabel',
		'verticalZoomLabel',
		'targetZoomDropList',
		'computedBaseDPILabel',
		'currentBaseDPILabel',
		'applyButton',
		'refreshButton'
	],
	#category : 'OpenPonk-Zoomer-UI',
	#package : 'OpenPonk-Zoomer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
OPZoomer class >> open [
	^ self new open
]

{ #category : 'settings' }
OPZoomer class >> settingsOn: aBuilder [
	<systemsettings>

	(aBuilder button: #open)
		parent: #appearance;
		order: 25;
		target: self;
		isTransient: true;
		label: 'Display zoom / scaling tool';
		description: 'Open utility to adjust SDL2 display scaling factor and DPI.';
		buttonLabel: 'Open scaling tool'
]

{ #category : 'accessing' }
OPZoomer >> applyButton [
	^ applyButton
]

{ #category : 'actions' }
OPZoomer >> applyZoom [
	| targetPercentage computedBase |
	targetPercentage := targetZoomDropList selectedItem ifNil: [ 100 ].
	computedBase := scaleModel computedTargetBaseDPIFor: targetPercentage.
	scaleModel applyBaseDPI: computedBase.
	self prefillTargetZoomDropList.
	self updateComputedValues
]

{ #category : 'initialization' }
OPZoomer >> connectPresenters [
	super connectPresenters.

	assumedRadio whenActivatedDo: [
		scaleModel activeSource: #assumed.
		self prefillTargetZoomDropList.
		self updateComputedValues ].
	diagonalRadio whenActivatedDo: [
		scaleModel activeSource: #diagonal.
		self prefillTargetZoomDropList.
		self updateComputedValues ].
	horizontalRadio whenActivatedDo: [
		scaleModel activeSource: #horizontal.
		self prefillTargetZoomDropList.
		self updateComputedValues ].
	verticalRadio whenActivatedDo: [
		scaleModel activeSource: #vertical.
		self prefillTargetZoomDropList.
		self updateComputedValues ].

	targetZoomDropList whenSelectedItemChangedDo: [ :item |
		self updateComputedValues ].

	refreshButton action: [ self refresh ].
	applyButton action: [ self applyZoom ]
]

{ #category : 'layout' }
OPZoomer >> defaultLayout [
	| metricsGrid targetConfigGrid buttonsLayout |
	metricsGrid := SpGridLayout new
		columnSpacing: 0;
		rowSpacing: 2;
		column: 1 expand: false;
		column: 2 expand: false;
		column: 3 expand: false;
		column: 4 expand: true;
		yourself.

	metricsGrid add: (self newLabel label: ('Source' asText allBold)) atPoint: 1 @ 1.
	metricsGrid add: (self newLabel label: ('DPI' asText allBold)) atPoint: 2 @ 1.
	metricsGrid add: (self newLabel label: ('Est. OS Zoom' asText allBold)) atPoint: 3 @ 1.
	metricsGrid add: (self newLabel label: ('Selected' asText allBold)) atPoint: 4 @ 1.

	metricsGrid add: (self newLabel label: 'Assumed:') atPoint: 1 @ 2.
	metricsGrid add: assumedDpiLabel atPoint: 2 @ 2.
	metricsGrid add: assumedZoomLabel atPoint: 3 @ 2.
	metricsGrid add: assumedRadio atPoint: 4 @ 2.

	metricsGrid add: (self newLabel label: 'Diagonal:') atPoint: 1 @ 3.
	metricsGrid add: diagonalDpiLabel atPoint: 2 @ 3.
	metricsGrid add: diagonalZoomLabel atPoint: 3 @ 3.
	metricsGrid add: diagonalRadio atPoint: 4 @ 3.

	metricsGrid add: (self newLabel label: 'Horizontal:') atPoint: 1 @ 4.
	metricsGrid add: horizontalDpiLabel atPoint: 2 @ 4.
	metricsGrid add: horizontalZoomLabel atPoint: 3 @ 4.
	metricsGrid add: horizontalRadio atPoint: 4 @ 4.

	metricsGrid add: (self newLabel label: 'Vertical:') atPoint: 1 @ 5.
	metricsGrid add: verticalDpiLabel atPoint: 2 @ 5.
	metricsGrid add: verticalZoomLabel atPoint: 3 @ 5.
	metricsGrid add: verticalRadio atPoint: 4 @ 5.

	targetConfigGrid := SpGridLayout new
		columnSpacing: 2;
		rowSpacing: 8;
		column: 1 expand: false;
		column: 2 expand: true;
		yourself.

	targetConfigGrid add: (self newLabel label: 'Target Zoom:') atPoint: 1 @ 1.
	targetConfigGrid add: targetZoomDropList atPoint: 2 @ 1.
	targetConfigGrid add: (self newLabel label: 'Current backend base DPI:') atPoint: 1 @ 2.
	targetConfigGrid add: currentBaseDPILabel atPoint: 2 @ 2.
	targetConfigGrid add: (self newLabel label: 'Base DPI to apply:') atPoint: 1 @ 3.
	targetConfigGrid add: computedBaseDPILabel atPoint: 2 @ 3.

	buttonsLayout := SpBoxLayout newLeftToRight
		spacing: 8;
		add: refreshButton;
		add: applyButton;
		yourself.

	^ SpBoxLayout newTopToBottom
		spacing: 2;
		borderWidth: 10;
		add: (self newLabel label: ('Detected Display Metrics:' asText allBold)) expand: false;
		add: metricsGrid height: 160;
		add: (self newLabel label: ('Target Configuration:' asText allBold)) expand: false;
		add: targetConfigGrid height: 120;
		addLast: buttonsLayout expand: false;
		yourself
]

{ #category : 'updating' }
OPZoomer >> displayStringForZoomPercentage: aPercentage [
	| currentZoom defaultZoom |
	currentZoom := scaleModel currentEffectiveZoomPercentage.
	defaultZoom := scaleModel defaultZoomPercentage.
	^ String streamContents: [ :stream |
		stream nextPutAll: aPercentage asString; nextPutAll: ' %'.
		aPercentage = currentZoom ifTrue: [ stream nextPutAll: ' [current]' ].
		aPercentage = defaultZoom ifTrue: [ stream nextPutAll: ' [default]' ] ]
]

{ #category : 'initialization' }
OPZoomer >> initializePresenters [
	| radioGroup |
	super initializePresenters.
	scaleModel := OPDisplayScaleModel new.
	scaleModel readDisplayDPI.

	assumedRadio := self newRadioButton.
	diagonalRadio := self newRadioButton.
	horizontalRadio := self newRadioButton.
	verticalRadio := self newRadioButton.

	radioGroup := { assumedRadio . diagonalRadio . horizontalRadio . verticalRadio }.
	radioGroup do: [ :each |
		each associatedRadioButtons: (radioGroup copyWithout: each) ].
	assumedRadio state: true.

	assumedDpiLabel := self newLabel.
	diagonalDpiLabel := self newLabel.
	horizontalDpiLabel := self newLabel.
	verticalDpiLabel := self newLabel.

	assumedZoomLabel := self newLabel.
	diagonalZoomLabel := self newLabel.
	horizontalZoomLabel := self newLabel.
	verticalZoomLabel := self newLabel.

	targetZoomDropList := self newDropList.
	targetZoomDropList display: [ :percentage | self displayStringForZoomPercentage: percentage ].

	computedBaseDPILabel := self newLabel.
	currentBaseDPILabel := self newLabel.

	refreshButton := self newButton.
	refreshButton label: 'Refresh'.
	refreshButton icon: (self iconNamed: #smallUpdate).

	applyButton := self newButton.
	applyButton label: 'Apply Zoom'.
	applyButton icon: (self iconNamed: #smallOk).

	self updateDpiDisplays.
	self prefillTargetZoomDropList.
	self updateComputedValues
]

{ #category : 'initialization' }
OPZoomer >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: 400 @ 400
]

{ #category : 'updating' }
OPZoomer >> prefillTargetZoomDropList [
	| availableZooms currentEffectiveZoom |
	availableZooms := scaleModel availableTargetZoomPercentages.
	currentEffectiveZoom := scaleModel currentEffectiveZoomPercentage.
	targetZoomDropList items: availableZooms.
	(availableZooms includes: currentEffectiveZoom)
		ifTrue: [ targetZoomDropList selectItem: currentEffectiveZoom ]
		ifFalse: [ targetZoomDropList selectIndex: 1 ]
]

{ #category : 'actions' }
OPZoomer >> refresh [
	scaleModel readDisplayDPI.
	self updateDpiDisplays.
	self prefillTargetZoomDropList.
	self updateComputedValues
]

{ #category : 'accessing' }
OPZoomer >> refreshButton [
	^ refreshButton
]

{ #category : 'accessing' }
OPZoomer >> scaleModel [
	^ scaleModel
]

{ #category : 'accessing' }
OPZoomer >> scaleModel: aDisplayScaleModel [
	scaleModel := aDisplayScaleModel.
	self updateDpiDisplays.
	self prefillTargetZoomDropList.
	self updateComputedValues
]

{ #category : 'accessing' }
OPZoomer >> targetZoomDropList [
	^ targetZoomDropList
]

{ #category : 'updating' }
OPZoomer >> updateComputedValues [
	| targetPercentage computedBase currentBase |
	targetPercentage := targetZoomDropList selectedItem ifNil: [ 100 ].
	computedBase := scaleModel computedTargetBaseDPIFor: targetPercentage.
	currentBase := scaleModel currentBackendBaseDPI.
	computedBaseDPILabel label: (computedBase printShowingDecimalPlaces: 2) , ' DPI'.
	currentBaseDPILabel label: (currentBase printShowingDecimalPlaces: 2) , ' DPI'.
	applyButton enabled: (computedBase closeTo: currentBase) not
]

{ #category : 'updating' }
OPZoomer >> updateDpiDisplays [

	| assumedDpi diagDpi horizDpi vertDpi |
	assumedDpi := scaleModel assumedDPI.
	diagDpi := scaleModel diagonalDPI.
	horizDpi := scaleModel horizontalDPI.
	vertDpi := scaleModel verticalDPI.

	assumedDpiLabel label: (assumedDpi printShowingDecimalPlaces: 1).
	diagonalDpiLabel label: (diagDpi printShowingDecimalPlaces: 1).
	horizontalDpiLabel label: (horizDpi printShowingDecimalPlaces: 1).
	verticalDpiLabel label: (vertDpi printShowingDecimalPlaces: 1).

	assumedZoomLabel label: (scaleModel estimatedOSZoomFor: assumedDpi) asString , ' %'.
	diagonalZoomLabel label: (scaleModel estimatedOSZoomFor: diagDpi) asString , ' %'.
	horizontalZoomLabel label: (scaleModel estimatedOSZoomFor: horizDpi) asString , ' %'.
	verticalZoomLabel label: (scaleModel estimatedOSZoomFor: vertDpi) asString , ' %'
]

{ #category : 'accessing' }
OPZoomer >> windowTitle [
	^ 'Zoomer: Display Scaling'
]
