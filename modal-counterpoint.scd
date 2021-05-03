(
~lag = 0.2;
SynthDef(\simple, {
	arg freq, phase = 0;
	phase.postln;
	Out.ar(0, SinOsc.ar(Lag.kr(freq, 0.2)!2, phase) * 0.2);
}).add;
)


(
var dict,
leaps,
fsm,
voice1, voice2, voice3,
downbeatStep,
lastDegree,
fourthDownOptions = [
	[ [ 0, 1 ], [-3, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
	// [ [ 0, 0.25 ], [ 1, 0.25 ], [ -1, 0.25 ], [ -1, 0.25 ], [ -1, 0 ] ],
],
secondDownOptions =[
	[ [ 0, 1], [ -1, 0 ] ],
	// [ [ 0, 0.5 ], [ -1, 0.25 ], [ -1, 0.25 ], [ 1, 0 ] ]
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
	// [ [ 0, 0.5 ], [ 2, 0.5 ], [ 2, 0 ] ]
];
TempoClock.default.tempo = 0.75;
s.latency = 0.2;
downbeatStep = 0;

dict = [
	fourthDownOptions,
	secondDownOptions,
	sustainOptions,
	thirdUpOptions,
	fifthUpOptions
];
leaps = (
	-3: 0,
	-1: 1,
	0: 2,
	2: 3,
	4: 4
);
fsm = Pfsm([
	#[1],
	Prand(dict[leaps[-3]], 1).flatten(0),
	(1..4),
	Prand(dict[leaps[-1]], 1).flatten(0),
	(0..4),
	Prand(dict[leaps[0]], 1).flatten(0),
	(0..4),
	Prand(dict[leaps[2]], 1).flatten(0),
	(0..4),
	Prand(dict[leaps[4]], 1).flatten(0),
	(0..2)
]);

lastDegree = 0;
voice1 = Pdef(\voice,
	Pmono(
		\simple,
		\stepData, fsm,
		\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
		\degree, Pfunc({|event| event[\stepVelocity] + lastDegree}),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\sustain, Pkey(\stepData).collect({|e| e[1]}),
		\scale, Scale.major,
		\octave, 5,
		\root, 0,
		\phase, 0,
		\callback, {|event| lastDegree = event[\degree] }
	)
).collect({ |e|
	~lastVoiceEvent = e;
}).play(quant: Quant(1));

voice2 = Pbindf(
	Pdef(\voice),
	\degree, Pfunc({ ~lastVoiceEvent.asStream[\degree] + 4}),
	\dur, Pfunc { ~lastVoiceEvent.asStream[\dur] },
	\sustain, Pfunc { ~lastVoiceEvent.asStream[\sustain] },
	\phase, 1pi,
	\callback, {}
).play(quant: Quant(1, timingOffset: 1));
)