(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;
(
var fsm, fsmLobby, melodyArrayIndex;
~setup.value;

Synth(\reverb);

fsm = Pfsm([
	(0..4),
	Pfuncn({ ~getMelodyForState.value(-3).choose; }), (1..4),
	Pfuncn({ ~getMelodyForState.value(-1).choose; }), (0..5),
	Pfuncn({ ~getMelodyForState.value( 0).choose; }), [ 0, 1, 3, 4 ],
	Pfuncn({ ~getMelodyForState.value( 2).choose; }), (0..4),
	Pfuncn({ ~getMelodyForState.value( 4).choose; }), (0..2),
	Pfuncn({ ~getMelodyForState.value( 3).choose; }), (6..6),
	nil, nil
]).asStream;

fsmLobby = fsm.next;

melodyArrayIndex = 0;

~voice1 = Pdef(\voice,
	Pmono(\simple,
		\stepData, Pfunc({
			fsmLobby[melodyArrayIndex];
		}),
		\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
		\degree, Pfunc({|event| event[\stepVelocity] + topEnvironment[\lastDegreeVoice1]}),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\scale, ~scale,
		\octave, 4,
		\root, ~root,
		\pan, -0.5,
		\gate, 1,
		\amp, 1,
		\callback, {|event|
			topEnvironment[\lastDegreeVoice1] = event[\degree];
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
		topEnvironment[\cadenceMelodyVoice2],
		Pfunc({~lastVoiceEvent.asStream[\stepData]})
	),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e| e[0] + topEnvironment[\lastDegreeVoice2Duet]}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\amp, 1,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice2Duet] = event[\degree];
	}
).play(quant: ~quantVoice2);

)