Allows selecting zoom level that should not cause blurry Pharo when OS has non-integer scaling/zoom applied (like 150 %).

## Installation

```Smalltalk
Metacello new
     baseline: 'OpenPonkZoomer';
     repository: 'github://OpenPonk/zoomer:main';
     load.
```

Also part of OpenPonk platform.

## Usage

Open with
```Smalltalk
OPZoomer open
```