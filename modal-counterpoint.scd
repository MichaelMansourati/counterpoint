(
~lag = 0.2;
SynthDef(\simple, {
	arg freq = 100, i_pan = 0, gate = 1, amp = 1;
	var sig, env;
	env = EnvGen.ar(Env([0, 0.5, 0], [0.2, 1], releaseNode: 1), gate: gate, doneAction: Done.freeSelf);
	sig = Lag.kr(freq, 0.2);
	sig = SinOsc.ar(sig) * 0.5;
	sig = Pan2.ar(sig, i_pan, 1) * env;
	sig = sig * amp;
	Out.ar(0, sig);
}).add;
)


(
var leaps,
scale, root,
fsm, fsmLobby, melodyArrayIndex,
voice1, voice2, voice3,
getMelodyForState,
cadenceMelody, cadenceMelodyVoice2,
lastDegree, lastDegreeVoice2,
lastStep,
isCadenceStarted, checkCadence,
fourthDownOptions = [
	[ [ 0, 1 ], [-3, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
	// [ [ 0, 0.25 ], [ 1, 0.25 ], [ -1, 0.25 ], [ -1, 0.25 ], [ -1, 0 ] ],
],
secondDownOptions = [
	[ [ 0, 1 ], [ -1, 0 ] ],
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
],
cadenceOptions = [
	[ [ 0, 0.01 ], [ 0, 0.49 ], [ 3, 1 ], [ -1, 0.5 ], [ 1, 2 ] ]
];

TempoClock.default.tempo = 0.75;
s.latency = 0.2;

leaps = (
	-3: fourthDownOptions,
	-1: secondDownOptions,
	0: sustainOptions,
	2: thirdUpOptions,
	4: fifthUpOptions,
	3: cadenceOptions
);
root = 0;
lastDegree = 0;
lastDegreeVoice2 = lastDegree + 4;
lastStep = 0;
getMelodyForState = { |int|
	var ornamentOptions = leaps[int];
	lastStep = int;
	ornamentOptions.choose;
};

fsm = Pfsm([
	(0..4),
	Pfuncn(getMelodyForState.value(-3)), (1..4),
	Pfuncn(getMelodyForState.value(-1)), (0..5),
	Pfuncn(getMelodyForState.value( 0)), (0..4),
	Pfuncn(getMelodyForState.value( 2)), (0..4),
	Pfuncn(getMelodyForState.value( 4)), (0..2),
	Pfuncn(getMelodyForState.value( 3)), (6..6),
	nil, nil
]).asStream;

fsmLobby = fsm.next;


scale = Scale.major;
scale.tuning = \et12;

melodyArrayIndex = 0;

voice1 = Pdef(\voice,
	Pmono(\simple,
		\stepData, Pfunc({
			fsmLobby[melodyArrayIndex];
		}),
		\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
		\degree, Pfunc({|event| event[\stepVelocity] + lastDegree}),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\scale, scale,
		\octave, 4,
		\root, root,
		\pan, -0.5,
		\gate, 1,
		\amp, 1,
		\callback, {|event|
			lastDegree = event[\degree];
			melodyArrayIndex = melodyArrayIndex + 1;
			if(
				(fsmLobby.size - melodyArrayIndex <= 2),
				{fsmLobby = fsmLobby ++ fsm.next}, {}
			);
		}
	)
).collect({ |e|
	~lastVoiceEvent = e;
}).play(quant: Quant(1));

isCadenceStarted = false;
checkCadence = {
	if (isCadenceStarted,
		{},
		{ isCadenceStarted = ~lastVoiceEvent.asStream[\stepData] == [ 0, 0.01 ]; }
	);
	isCadenceStarted;
};
cadenceMelodyVoice2 = Pseq([
	[ 0, 1 ], [ -1, 2 ], [ 0, 0 ], [ 0, 0 ], [ 0, 0 ], [ 0, 0 ]
], 1);

voice2 = Pbindf(
	Pdef(\voice),
	\stepData, Pif(
		Pfunc(checkCadence),
		cadenceMelodyVoice2,
		Pfunc({~lastVoiceEvent.asStream[\stepData]})
	).trace,
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e| e[0] + lastDegreeVoice2}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\amp, 1,
	\callback, {|event|
		lastDegreeVoice2 = event[\degree];
	}
).play(quant: Quant(1, timingOffset: 1));
)



[4, 5, 6, 7, 8, 4, 5, 6, 7, 8].maxSize;