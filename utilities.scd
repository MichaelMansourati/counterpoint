(
~bus.free;
~bus = Bus.audio(s, 2);
~lag = 0.1;
SynthDef(\simple, {
	arg freq = 100, i_pan = 0, gate = 1, amp = 1;
	var sig, env;
	env = EnvGen.ar(Env([0, 0.5, 0], [0.2, 1], releaseNode: 1), gate: gate, doneAction: Done.freeSelf);
	sig = Lag.kr(freq, ~lag);
	sig = Mix.new(Array.fill(3, {|i| var num = (i+1); SinOsc.ar(sig * num) * 1/(num**3) }));
	sig = Pan2.ar(sig, i_pan, 1) * env;
	sig = sig * amp;
	Out.ar(~bus, sig);
}).add;

SynthDef(\reverb, {
	var sig = In.ar(~bus, 2);
	sig = FreeVerb.ar(sig, 0.2, 0.9);
	Out.ar(0, sig);
}).add;



~fourthDownOptions = [
	[ [ 0, 1 ], [-3, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
	// [ [ 0, 0.25 ], [ 1, 0.25 ], [ -1, 0.25 ], [ -1, 0.25 ], [ -1, 0 ] ],
];
~secondDownOptions = [
	[ [ 0, 1 ], [ -1, 0 ] ],
	// [ [ 0, 0.5 ], [ -1, 0.25 ], [ -1, 0.25 ], [ 1, 0 ] ]
];
~sustainOptions = [
	[ [ 0, 1 ], [ 0, 0] ]
];
~thirdUpOptions = [
	[ [ 0, 1 ], [ 2, 0 ] ],
	[ [ 0, 0.5 ], [ 1, 0.5 ], [ 1, 0 ]  ],
	[ [ 0, 0.75 ], [ 1, 0.25 ], [ 1, 0 ] ],
	[ [ 0, 0.25 ], [ -1, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0 ] ]
];
~fifthUpOptions = [
	[ [ 0, 1 ], [ 4 , 0 ] ],
	[ [ 0, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0.25 ], [ 1, 0 ] ],
];
~cadenceOptions = [
	[ [ 0, 0.01 ], [ 0, 0.49 ], [ 3, 1 ], [ -1, 0.5 ], [ 1, 2 ] ]
];
)