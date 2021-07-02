(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var fsm, fsmLobby, melodyArrayIndex;
~setup.value;

Synth(\reverb);

fsm = Pfsm([
	[ 0, 2, 3, 4 ],
	// [ 3 ], //cadence testing
	Pfuncn({ ~getMelodyForState.value(-3).choose; }), [ 2, 3, 4 ],
	Pfuncn({ ~getMelodyForState.value(-1).choose; }), [ 5 ],
	Pfuncn({ ~getMelodyForState.value( 0).choose; }), [ 0, 3, 4 ],
	// Pfuncn({ ~getMelodyForState.value( 2).choose; }), [ 0, 1, 2, 3, 4 ],
	Pfuncn({ ~getMelodyForState.value( 2).choose; }), [ 1 ], //cadence testing
	Pfuncn({ ~getMelodyForState.value( 4).choose; }), [ 0, 2 ],
	Pfuncn({ ~getMelodyForState.value( 3).choose; }), [ 6 ],
	nil, nil
]).asStream;

fsmLobby = fsm.next;

melodyArrayIndex = 0;
~voice1 = Pdef(\voice,
	Pmono(\simple,
		\stepData, Pfunc({ fsmLobby[melodyArrayIndex] }),
		\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
		\degree, Pfunc({|event|
			x = event[\stepVelocity] + topEnvironment[\lastDegreeVoice1];
			"voice1: ".post;
			x.postln;
		}),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\scale, ~scale,
		\octave, 4,
		\root, ~root,
		\pan, -0.5,
		\gate, 1,
		\amp, 1,
		\callback, {|event|
			topEnvironment[\lastDegreeVoice1] = event[\degree];
			((topEnvironment[\lastDegreeVoice1] % 7) + 1);
			melodyArrayIndex = melodyArrayIndex + 1;
			if(
				(fsmLobby.size - melodyArrayIndex <= 2),
				{fsmLobby = fsmLobby ++ fsm.next}, {}
			);
		}
	)
).collect({ |e|
	~lastVoiceEvent = e;
}).play(quant: ~quantVoice1);

~voice2 = Pbindf(
	Pdef(\voice),
	\stepData, Pif(
		Pfunc(topEnvironment[\checkCadence]),
		Pfunc({ topEnvironment[\cadenceMelodyVoice2].next }),
		Pfunc({topEnvironment[\lastVoiceEvent].asStream[\stepData]})
	),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e| e[0] + topEnvironment[\lastDegreeVoice2]}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0,
	\amp, 1,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice2] = event[\degree];
	}
).play(quant: ~quantVoice2);

~voice3 = Pbindf(
	Pdef(\voice),
	\stepData, Pif(
		Pfunc(topEnvironment[\checkCadence]),
		Pfunc({ topEnvironment[\cadenceMelodyVoice3].next }),
		Pfunc({ topEnvironment[\lastVoiceEvent].asStream[\stepData] })
	),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e|
		x = e[0] + topEnvironment[\lastDegreeVoice3];
		"voice3: ".post;
		x.postln;
	}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\timingOffset, Pif(
		Pfunc(topEnvironment[\checkCadence]),
		Pfunc({ 0 }),
		Pfunc({ 2 })
	),
	\amp, 1,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice3] = event[\degree];
	}
).play(quant: ~quantVoice3);
)