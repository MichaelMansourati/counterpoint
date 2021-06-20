(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;
(
var leaps,
scale, root,
fsm, fsmLobby, melodyArrayIndex,
getMelodyForState,
cadenceMelody, cadenceMelodyVoice2,
lastDegree, lastDegreeVoice2,
lastStep,
isCadenceStarted, checkCadence;

Synth(\reverb);

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
root = 0;
lastDegree = 0;
lastDegreeVoice2 = lastDegree + 4;
lastStep = 0;
getMelodyForState = { |int|
	var ornamentOptions = leaps[int];
	lastStep = int;
	ornamentOptions;
};

fsm = Pfsm([
	(0..4),
	Pfuncn({ getMelodyForState.value(-3).choose; }), (1..4),
	Pfuncn({ getMelodyForState.value(-1).choose; }), (0..5),
	Pfuncn({ getMelodyForState.value( 0).choose; }), (0..4),
	Pfuncn({ getMelodyForState.value( 2).choose; }), (0..4),
	Pfuncn({ getMelodyForState.value( 4).choose; }), (0..2),
	Pfuncn({ getMelodyForState.value( 3).choose; }), (6..6),
	nil, nil
]).asStream;

fsmLobby = fsm.next;



scale = Scale.major;
scale.tuning = \et12;

melodyArrayIndex = 0;

~voice1 = Pdef(\voice,
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
			((lastDegree % 7) + 1).postln;
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
	[ 0, 1 ], [ -1, 2 ]
], 1);

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
	\pan, 0.5,
	\amp, 1,
	\callback, {|event|
		lastDegreeVoice2 = event[\degree];
	}
).play(quant: Quant(1, timingOffset: 1));

)