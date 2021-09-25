(
var invertOptions = {
	arg opts = [ [ [ 0, 0 ] ] ];
	opts.collectCopy({
		arg opt = [ [ 0, 0 ] ];
		opt.collectCopy({
			arg note = [ 0, 0 ];
			note[0] = note[0] * -1;
		});
	});
	opts;
},
deepCloneArray = {
	arg options = [ [ [ 0, 0 ] ] ];
	options.collectCopy({ |i| i.collectCopy({ |i| i.collectCopy({ |i| i }) }) });
};

~leaps = ();
~leaps[-3] = [
	[ [ 0, 1 ], [ -3, 0 ] ],
	[ [ 0, 0.5 ], [ -1, 0.5 ], [ -2, 0 ] ],
	[ [ 0, 0.5 ], [ -1, 0.25 ], [ -1, 0.25 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.25 ], [ -2, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
];
~leaps[-1] = [
	[ [ 0, 1 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ 1, 0 ] ],
];
~leaps[0] = [
	[ [ 0, 1 ], [ 0, 0] ]
];
~leaps[2] = [
	[ [ 0, 1 ], [ 2, 0 ] ],
	[ [ 0, 0.5 ], [ 1, 0.5 ], [ 1, 0 ]  ],
	[ [ 0, 0.75 ], [ 1, 0.25 ], [ 1, 0 ] ],
	[ [ 0, 0.25 ], [ -1, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0 ] ]
];
~leaps[4] = [
	[ [ 0, 1 ], [ 4 , 0 ] ],
	[ [ 0, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0 ] ],
];

~leaps[3] = invertOptions.value(deepCloneArray.value(~leaps[-3]));
~leaps[3][1] = [ [ 0, 0.5 ], [ 2, 0.5 ], [ 1, 0 ] ];
~leaps[1] = invertOptions.value(deepCloneArray.value(~leaps[-1]));
~leaps[-2] = invertOptions.value(deepCloneArray.value(~leaps[2]));
~leaps[-4] = invertOptions.value(deepCloneArray.value(~leaps[4]));

// VOICE 1
~leaps[\cadence1MH] = [ [ [ 0, 0.5 ], [ 3, 1 ], [ -1, 0.5 ], [ 1, 2 ] ] ];

~leaps[\cadence1MHL] = ~leaps[\cadence1MH];

~leaps[\cadence1HLM] = ~leaps[\cadence1MH];


~leaps[\cadence1MHRaised] = deepCloneArray.value(~leaps[\cadence1MH]);
~leaps[\cadence1MHRaised][0][2][0].postln;
~leaps[\cadence1MHRaised][0][2][0] = -0.9;
~leaps[\cadence1MHRaised][0][3][0] = 0.9;


~leaps[\cadence1MHLRaised] = ~leaps[\cadence1MHRaised];

~leaps[\cadence1HLMRaised] = ~leaps[\cadence1MHRaised];


~leaps[\cadence1ML] = deepCloneArray.value(~leaps[\cadence1MH]);
~leaps[\cadence1ML][0][1][0] = 2;

~leaps[\cadence1MLH] = ~leaps[\cadence1ML];

~leaps[\cadence1LHM] = ~leaps[\cadence1ML];


~leaps[\cadence1MLRaised] = deepCloneArray.value(~leaps[\cadence1ML]);
~leaps[\cadence1MLRaised][0][2][0] = -0.9;
~leaps[\cadence1MLRaised][0][3][0] = 0.9;

~leaps[\cadence1MLHRaised] = ~leaps[\cadence1MLRaised];

~leaps[\cadence1LHMRaised] = ~leaps[\cadence1MLRaised];

// VOICE 2
~leaps[\cadence2MH] = [ [ [ 0, 1 ], [ -1, 2 ] ] ];

~leaps[\cadence2MHL] = ~leaps[\cadence2MH];

~leaps[\cadence2HLM] = deepCloneArray.value(~leaps[\cadence2MH]);
~leaps[\cadence2HLM][0][1][0] = 3;


~leaps[\cadence2ML] = ~leaps[\cadence2MH];

~leaps[\cadence2MLH] = ~leaps[\cadence2MH];

~leaps[\cadence2LHM] = "?????"; //this might break current implementation of cadencing

// VOICE 3
~leaps[\cadence3MHL] = [ [ [ 0, 1 ], [ -3, 1 ], [ 3, 4 ] ] ];
~leaps[\cadence3MLH] = [ [ [ 0, 1 ], [ 1, 1 ], [ -1, 4 ] ] ];
~leaps[\cadence3HLM] = [ [ [ 0, 1 ], [ -1, 1 ], [ -1, 4 ] ] ];
~leaps[\cadence3LHM] = "?????"; //LHM is a special case

~leaps[\cadence] = [\cadence];
~leaps[\cadenceRaised] = [\cadenceRaised];
)