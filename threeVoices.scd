(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var leaps,
scale, root,
fsm, fsmLobby, melodyArrayIndex,
getMelodyForState,
lastDegreeVoice1, lastDegreeVoice2, lastDegreeVoice3,
lastStep,
isCadenceStarted, checkCadence,
cadenceMelodyVoice2 = Pseq([ [ 0, 1 ], [ -1, 2 ] ], 1),
cadenceMelodyVoice3 = Pseq([ [ 0, 1 ], [ -3, 1 ], [ 3, 2 ] ], 1),
quantVoice1 =  Quant(1, timingOffset: 0),
quantVoice2 = Quant(1, timingOffset: 1),
quantVoice3 = Quant(1, timingOffset: 2);
~fourthDownOptions = [
	[ [ 0, 1 ], [-3, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],

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

TempoClock.default.tempo = 0.75;
s.latency = 0.2;

leaps = (
	-3: ~fourthDownOptions,
	-1: ~secondDownOptions,
	0: ~sustainOptions,
	2: ~thirdUpOptions,
	4: ~fifthUpOptions,
	3: ~cadenceOptions
);
root = (0..6).choose;
lastDegreeVoice1 = (0..6).choose;
lastDegreeVoice2 = lastDegreeVoice1 - 7;
lastDegreeVoice3 = lastDegreeVoice1 - 3;
lastStep = 0;
getMelodyForState = { |int|
	var ornamentOptions = leaps[int];
	lastStep = int;
	ornamentOptions;
};

Synth(\reverb);

fsm = Pfsm([
	[ 0, 2, 3, 4 ],
	// [ 3 ], //cadence testing
	Pfuncn({ getMelodyForState.value(-3).choose; }), [ 2, 3, 4 ],
	Pfuncn({ getMelodyForState.value(-1).choose; }), [ 5 ],
	Pfuncn({ getMelodyForState.value( 0).choose; }), [ 0, 2, 3, 4 ],
	Pfuncn({ getMelodyForState.value( 2).choose; }), [ 0, 2, 3, 4 ],
	// Pfuncn({ getMelodyForState.value( 2).choose; }), [ 1 ], //cadence testing
	Pfuncn({ getMelodyForState.value( 4).choose; }), [ 0, 2 ],
	// Pfuncn({ getMelodyForState.value( 3).choose; }), [ 6 ],
	nil, nil
]).asStream;

fsmLobby = fsm.next;


scale = Scale.major;

melodyArrayIndex = 0;
~voice1 = Pdef(\voice,
	Pmono(\simple,
		\stepData, Pfunc({
			fsmLobby[melodyArrayIndex];
		}),
		\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
		\degree, Pfunc({|event| event[\stepVelocity] + lastDegreeVoice1}),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\scale, scale,
		\octave, 5,
		\root, root,
		\pan, -0.5,
		\gate, 1,
		\amp, 1,
		\callback, {|event|
			lastDegreeVoice1 = event[\degree];
			((lastDegreeVoice1 % 7) + 1);
			melodyArrayIndex = melodyArrayIndex + 1;
			if(
				(fsmLobby.size - melodyArrayIndex <= 2),
				{fsmLobby = fsmLobby ++ fsm.next}, {}
			);

		}
	)
).collect({ |e|
	~lastVoiceEvent = e;
}).play(quant: quantVoice1);

isCadenceStarted = false;
checkCadence = {
	if (isCadenceStarted,
		{},
		{ isCadenceStarted = ~lastVoiceEvent.asStream[\stepData] == [ 0, 0.01 ]; }
	);
	isCadenceStarted;
};
~voice2 = Pbindf(
	Pdef(\voice),
	\stepData, Pif(
		Pfunc(checkCadence),
		cadenceMelodyVoice2,
		Pfunc({~lastVoiceEvent.asStream[\stepData]})
	),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e| e[0] + lastDegreeVoice2}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0,
	\amp, 1,
	\callback, {|event|
		lastDegreeVoice2 = event[\degree];
	}
).play(quant: quantVoice2);

~voice3 = Pbindf(
	Pdef(\voice),
	\stepData, Pif(
		Pfunc(checkCadence),
		Pfunc({ quantVoice3.timingOffset = 0; cadenceMelodyVoice3 }),
		Pfunc({~lastVoiceEvent.asStream[\stepData]})
	),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e| e[0] + lastDegreeVoice3}).trace,
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\amp, 1,
	\callback, {|event|
		lastDegreeVoice3 = event[\degree];
	}
).play(quant: quantVoice3);
)

~busses;