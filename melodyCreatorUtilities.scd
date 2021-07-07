(
var fourthDownOptions = [
	[ [ 0, 1 ], [ -3, 0 ] ],
	[ [ 0, 0.5 ], [ -1, 0.5 ], [ -2, 0 ] ],
	[ [ 0, 0.5 ], [ -1, 0.25 ], [ -1, 0.25 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.25 ], [ -2, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
],
secondDownOptions = [
	[ [ 0, 1 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ 1, 0.125 ], [ -1, 0.125 ], [ -1, 0 ] ]
],
sustainOptions = [
	[ [ 0, 1 ], [ 0, 0] ]
],
thirdUpOptions = [
	[ [ 0, 1 ], [ 2, 0 ] ],
	[ [ 0, 0.5 ], [ 1, 0.5 ], [ 1, 0 ]  ],
	[ [ 0, 0.75 ], [ 1, 0.25 ], [ 1, 0 ] ],
	[ [ 0, 0.25 ], [ -1, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0 ] ]
],
fifthUpOptions = [
	[ [ 0, 1 ], [ 4 , 0 ] ],
	[ [ 0, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0 ] ],
],
cadence1Options = [
	[ [ 0, 0.5 ], [ 3, 1 ], [ -1, 0.5 ], [ 1, 2 ] ]
],
cadenceRaised1Options = [
	[ [ 0, 0.5 ], [ 3, 1 ], [ -0.9, 0.5 ], [ 0.9, 2 ] ]
],
cadence2Options = [
	[ [ 0, 1 ], [ -1, 2 ] ]
],
cadence3Options = [
	[ [ 0, 1 ], [ -3, 1 ], [ 3, 4 ] ]
];
~leaps = (
	-3: fourthDownOptions,
	-1: secondDownOptions,
	0: sustainOptions,
	2: thirdUpOptions,
	4: fifthUpOptions,
	\cadence: [\cadence],
	\cadenceRaised: [\cadenceRaised],
	\cadence1: cadence1Options,
	\cadenceRaised1: cadenceRaised1Options,
	\cadence2: cadence2Options,
	\cadence3: cadence3Options,
);
)