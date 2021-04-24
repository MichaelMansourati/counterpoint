(
SynthDef(\simple, {
	arg freq;
	// var env = EnvGen.ar(Env.new([0,1,0], [0.1,1], releaseNode:1), doneAction:Done.freeSelf);
	Out.ar(0, SinOsc.ar(Lag.kr(freq, 0.2)!2));
}).add;
)


(
var fifthBelowOptions, fifthAboveOptions, scale, startNote, voice1, voice2, getStepData, fifthAboveDict;
TempoClock.default.tempo = 1;

fifthAboveDict = (
	-3: [
		[ [ -3 ], [ 1 ] ],
		[ [ 0, -1, -1, -1 ], [ 0.5, 0.25, 0.25 ] ],
		[ [ 0, 1, -1, -1 ], 0.25!4 ],
		[ [ 0, -1, -1, 1 ], 0.25!4 ]
	],
	-1: [
		[ [ -1 ], [ 1 ] ],
		[ [ 0, -1, -1, 1 ], [ 0.5, 0.25, 0.25 ] ]
	],
	0: [
		[ [ 0 ], [ 1 ] ]
	],
	2: [
		[ [ 2 ], [ 1 ] ]
	],
	4: [
		[ [ 4 ], [ 1 ] ]
	]
);
scale = Scale.major;
startNote = 0;

getStepData = {
	arg e;
	var interval = fifthAboveOptions.choose;


};

voice1 = Pdef(\voice,
	Pmono(
		\simple,
		\stepData, Pfunc({fifthAboveDict.choose.choose.flop }).flatten(0),
		\degree, Pseries(0, Pkey(\stepData).collect({|e| e[0]}), inf),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\sustain, Pkey(\stepData).collect({|e| e[1]}),
		\scale, scale,
		\octave, 4,
		\root, 0
	)
).collect({ |e|
	~lastVoiceEvent = e;
	// e.asStream[\degree].postln;
}).play(quant: Quant(1));
voice2 = Pbindf(
	Pdef(\voice),
	\degree, Pfunc { ~lastVoiceEvent.asStream[\degree] + 4},
	\dur, Pfunc { ~lastVoiceEvent.asStream[\dur] },
	\sustain, Pfunc { ~lastVoiceEvent.asStream[\sustain] },
).play(quant: Quant(1, timingOffset: 1));
)


var fifthAboveDict = (
	-3: [
		[[-3], [1]],
		[[0, -1, -1, -1], [0.5, 0.25, 0.25]],
		[[0, 1, -1, -1],0.25!4],
		[[0, -1, -1, 1],0.25!4]
	],
	-1: [
		[[-1], [1]],
		[[0, -1, -1, 1], [0.5,0.25, 0.25]]
	],
	0: [
		[[0],[1]]
	],
	2: [
		[[2],[1]]
	],
	4: [
		[[4],[1]]
	]
).choose.choose.flop.postln;



