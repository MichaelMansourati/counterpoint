(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var fsm, fsmLobby, melodyArrayIndex;
~setup.value;
~quantVoice2.timingOffset = 1;
~quantVoice3.timingOffset = 2;

Synth(\reverb);

fsm = Pfsm([
	// [ 0, 2, 3, 4 ],
	[ 3 ], //cadence testing
	Pfuncn({ ~getMelodyForState.value(-3).choose; }), [ 2, 3, 4 ],
	Pfuncn({ ~getMelodyForState.value(-1).choose; }), [ 5 ],
	Pfuncn({ ~getMelodyForState.value( 0).choose; }), [ 0, 3, 4 ],
	// Pfuncn({ ~getMelodyForState.value( 2).choose; }), [ 0, 2, 3, 4 ],
	Pfuncn({ ~getMelodyForState.value( 2).choose; }), [ 1 ], //cadence testing
	Pfuncn({ ~getMelodyForState.value( 4).choose; }), [ 0, 2 ],
	Pfuncn({ ~getMelodyForState.value( 3).choose; }), [ 6 ],
	nil, nil
]).asStream;

fsmLobby = fsm.next;

melodyArrayIndex = 0;



~voice1Create = Pdef(\voiceCreate,
	Pbind(
		\type, \on,
		\instrument, Pseq([\simple], 1),
		\id, ~voice1NodeID = s.nextNodeID
	)
);

~voice1Set = Pdef(\voiceSet,
	Pbind(
		\type, \set,
		\id, ~voice1NodeID,
		\stepData, Pfunc({ fsmLobby[melodyArrayIndex] }),
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
			((topEnvironment[\lastDegreeVoice1] % 7) + 1);
			melodyArrayIndex = melodyArrayIndex + 1;
			if(
				(fsmLobby.size - melodyArrayIndex <= 2),
				{fsmLobby = fsmLobby ++ fsm.next}, {}
			);
		}
	)
);
~voice1Off = Pdef(\voiceOff, Pbind(\type, \off, \id, ~voice1NodeID));
~voice1 = Pseq([
	Ppar([~voice1Create, ~voice1Set], 1),
	~voice1Off
]);

~voice1.collect({ |e|
	~lastVoiceEvent = e;
}).play(quant: ~quantVoice1);


~voice2Create = Pbindf(
	Pdef(\voiceCreate),
	\id, ~voice2NodeID = s.nextNodeID
);
~voice2Set = Pbindf(
	Pdef(\voiceSet),
	\id, ~voice2NodeID,
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
);
~voice2Off = Pbindf(Pdef(\voiceOff), \id, ~voice2NodeID);
~voice2 = Pseq([
	Ppar([~voice2Create, ~voice2Set], 1),
	~voice2Off
]).play(quant: ~quantVoice2);


~voice3Create = Pbindf(Pdef(\voiceCreate), \id, ~voice3NodeID = s.nextNodeID);
~voice3Set = Pbindf(
	Pdef(\voiceSet),
	\id, ~voice3NodeID,
	\stepData, Pif(
		Pfunc(topEnvironment[\checkCadence]),
		Pfunc({ topEnvironment[\cadenceMelodyVoice3].next }),
		Pfunc({ topEnvironment[\lastVoiceEvent].asStream[\stepData] })
	),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pkey(\stepData).collect({|e| e[0] + topEnvironment[\lastDegreeVoice3]}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\amp, 1,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice3] = event[\degree];
	}
);
~voice3Off = Pbindf(Pdef(\voiceOff), \id, ~voice3NodeID);
~voice3 = Pseq([
	Ppar([~voice3Create, ~voice3Set], 1),
	~voice3Off
]).play(quant: ~quantVoice3);
)

~quantVoice3.phase = -1;