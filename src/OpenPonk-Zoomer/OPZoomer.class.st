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
		'resetButton',
		'refreshButton'
	],
	#category : 'OpenPonk-Zoomer-UI',
	#package : 'OpenPonk-Zoomer',
	#tag : 'UI'
}

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
	self updateComputedValues
]

{ #category : 'initialization' }
OPZoomer >> connectPresenters [
	super connectPresenters.

	assumedRadio whenActivatedDo: [
		scaleModel activeSource: #assumed.
		self updateComputedValues ].
	diagonalRadio whenActivatedDo: [
		scaleModel activeSource: #diagonal.
		self updateComputedValues ].
	horizontalRadio whenActivatedDo: [
		scaleModel activeSource: #horizontal.
		self updateComputedValues ].
	verticalRadio whenActivatedDo: [
		scaleModel activeSource: #vertical.
		self updateComputedValues ].

	targetZoomDropList whenSelectedItemChangedDo: [ :item |
		self updateComputedValues ].

	refreshButton action: [ self refresh ].
	resetButton action: [ self resetZoom ].
	applyButton action: [ self applyZoom ]
]

{ #category : 'layout' }
OPZoomer >> defaultLayout [
	| metricsLayout targetConfigLayout buttonsLayout |
	metricsLayout := SpBoxLayout newTopToBottom
		spacing: 4;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: ('Source' asText allBold)) width: 80;
			add: (self newLabel label: ('Selected' asText allBold)) width: 30;
			add: (self newLabel label: ('DPI' asText allBold)) width: 90;
			add: (self newLabel label: ('Estimated OS Zoom' asText allBold)) width: 140;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Assumed:') width: 80;
			add: assumedRadio width: 30;
			add: assumedDpiLabel width: 90;
			add: assumedZoomLabel width: 140;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Diagonal:') width: 80;
			add: diagonalRadio width: 30;
			add: diagonalDpiLabel width: 90;
			add: diagonalZoomLabel width: 140;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Horizontal:') width: 80;
			add: horizontalRadio width: 30;
			add: horizontalDpiLabel width: 90;
			add: horizontalZoomLabel width: 140;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Vertical:') width: 80;
			add: verticalRadio width: 30;
			add: verticalDpiLabel width: 90;
			add: verticalZoomLabel width: 140;
			yourself) expand: false;
		yourself.

	targetConfigLayout := SpBoxLayout newTopToBottom
		spacing: 4;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Target Zoom:') width: 180;
			add: targetZoomDropList width: 90;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Base DPI to apply:') width: 180;
			add: computedBaseDPILabel width: 90;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (self newLabel label: 'Current backend base DPI:') width: 180;
			add: currentBaseDPILabel width: 90;
			yourself) expand: false;
		yourself.

	buttonsLayout := SpBoxLayout newLeftToRight
		spacing: 8;
		add: refreshButton;
		add: resetButton;
		add: applyButton;
		yourself.

	^ SpBoxLayout newTopToBottom
		spacing: 8;
		borderWidth: 10;
		add: (self newLabel label: ('Detected Display Metrics:' asText allBold)) expand: false;
		add: metricsLayout expand: false;
		add: (self newLabel label: ('Target Configuration:' asText allBold)) expand: false;
		add: targetConfigLayout expand: false;
		addLast: buttonsLayout expand: false;
		yourself
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

	radioGroup := {
		              assumedRadio.
		              diagonalRadio.
		              horizontalRadio.
		              verticalRadio }.
	radioGroup do: [ :each | each associatedRadioButtons: (radioGroup copyWithout: each) ].
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
	targetZoomDropList items: #( 100 200 300 ).
	targetZoomDropList display: [ :percentage | percentage asString , ' %' ].
	targetZoomDropList selectIndex: 1.

	computedBaseDPILabel := self newLabel.
	currentBaseDPILabel := self newLabel.

	refreshButton := self newButton.
	refreshButton label: 'Refresh'.
	refreshButton icon: (self iconNamed: #smallUpdate).

	resetButton := self newButton.
	resetButton label: 'Reset to Default'.
	resetButton icon: (self iconNamed: #smallUndo).

	applyButton := self newButton.
	applyButton label: 'Apply Zoom'.
	applyButton icon: (self iconNamed: #smallOk).

	self updateDpiDisplays.
	self updateComputedValues
]

{ #category : 'initialization' }
OPZoomer >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: self class defaultExtent
]

{ #category : 'actions' }
OPZoomer >> refresh [
	scaleModel readDisplayDPI.
	self updateDpiDisplays.
	self updateComputedValues
]

{ #category : 'accessing' }
OPZoomer >> refreshButton [
	^ refreshButton
]

{ #category : 'accessing' }
OPZoomer >> resetButton [
	^ resetButton
]

{ #category : 'actions' }
OPZoomer >> resetZoom [
	scaleModel resetToDefaultBaseDPI.
	self updateComputedValues
]

{ #category : 'accessing' }
OPZoomer >> scaleModel [
	^ scaleModel
]

{ #category : 'accessing' }
OPZoomer >> scaleModel: aDisplayScaleModel [
	scaleModel := aDisplayScaleModel.
	self updateDpiDisplays.
	self updateComputedValues
]

{ #category : 'updating' }
OPZoomer >> updateComputedValues [
	| targetPercentage computedBase |
	targetPercentage := targetZoomDropList selectedItem ifNil: [ 100 ].
	computedBase := scaleModel computedTargetBaseDPIFor: targetPercentage.
	computedBaseDPILabel label: (computedBase printShowingDecimalPlaces: 2) , ' DPI'.
	currentBaseDPILabel label: (scaleModel currentBackendBaseDPI printShowingDecimalPlaces: 2) , ' DPI'
]

{ #category : 'updating' }
OPZoomer >> updateDpiDisplays [
	| assumedDpi diagDpi horizDpi vertDpi |
	assumedDpi := scaleModel assumedDPI.
	diagDpi := scaleModel diagonalDPI.
	horizDpi := scaleModel horizontalDPI.
	vertDpi := scaleModel verticalDPI.

	assumedDpiLabel label: (assumedDpi printShowingDecimalPlaces: 1) , ' DPI'.
	diagonalDpiLabel label: (diagDpi printShowingDecimalPlaces: 1) , ' DPI'.
	horizontalDpiLabel label: (horizDpi printShowingDecimalPlaces: 1) , ' DPI'.
	verticalDpiLabel label: (vertDpi printShowingDecimalPlaces: 1) , ' DPI'.

	assumedZoomLabel label: (scaleModel estimatedOSZoomFor: assumedDpi) asString , ' %'.
	diagonalZoomLabel label: (scaleModel estimatedOSZoomFor: diagDpi) asString , ' %'.
	horizontalZoomLabel label: (scaleModel estimatedOSZoomFor: horizDpi) asString , ' %'.
	verticalZoomLabel label: (scaleModel estimatedOSZoomFor: vertDpi) asString , ' %'
]

{ #category : 'accessing' }
OPZoomer >> windowTitle [
	^ 'OpenPonk Display Scaler'
]
