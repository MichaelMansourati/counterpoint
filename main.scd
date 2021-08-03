(
var fourthDownOptions = [
	[ [ 0, 1 ], [ -3, 0 ] ],
	[ [ 0, 0.5 ], [ -1, 0.5 ], [ -2, 0 ] ],
	[ [ 0, 0.5 ], [ -1, 0.25 ], [ -1, 0.25 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.25 ], [ -2, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
],
secondDownOptions = [
	[ [ 0, 1 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ 1, 0.125 ], [ -1, 0.125 ], [ -1, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ 1, 0 ] ],
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
],
cadence1Options = [
	[ [ 0, 0.5 ], [ 3, 1 ], [ -1, 0.5 ], [ 1, 2 ] ]
],
cadenceRaised1Options = [
	[ [ 0, 0.5 ], [ 3, 1 ], [ -0.9, 0.5 ], [ 0.9, 2 ] ]
],
cadence2Options = [
	[ [ 0, 1 ], [ -1, 2 ] ]
],
cadence3Options = [
	[ [ 0, 1 ], [ -3, 1 ], [ 3, 4 ] ]
],
isPrereqLastNtvlPresent = { |prereqNtvls|
	prereqNtvls.find([
		~beatNtvls[~beatNtvls.size - 1]
	]) !== nil;
},
isLastNtvlsNotMatching = { arg ntvls = [];
	if (ntvls.size <= ~beatNtvls.size,
		{
			ntvls != ~beatNtvls.slice(
				((~beatNtvls.size - (ntvls.size))..(~beatNtvls.size - 1))
			);
		},
		{ true }
	);
},
bus, lag,
getFicta = {
	arg voiceCount = 3;
	if (
		voiceCount === 3,
		{ (~netDegrees + 3) % 7 },
		{ (~netDegrees + 1) % 7 }
	);
},

addPrecadentialBeats = {
	arg voiceCount = 3;
	var beatsToAdd;
	if (
		voiceCount === 3,
		{ beatsToAdd = [ 2, -1 ] },
		{ beatsToAdd = [ -1 ] }
	);
	~beatNtvls = ~beatNtvls.addAll(beatsToAdd);
},

getIsTimeToCadence = {
	arg voiceCount = 3, fictaDegree = 0;
	if (
		voiceCount === 3,
		{
			~beatNtvls.size > 32 &&
			~ntvlOpts.find[2] !== nil &&
			[1, 5].find([fictaDegree]) === nil;
		},
		{
			~beatNtvls.size > 32 &&
			[1, 5].find([fictaDegree]) === nil;
		}
	);
},

beatCreator = {
	arg voiceCount = 3;
	while({
		~beatNtvls.size < 40 and:
		{ [\cadence, \cadenceRaised ].find([~beatNtvls[~beatNtvls.size - 1]]) === nil };
	}, {
		var fictaDegree = getFicta.value(voiceCount);
		~getNtvlOpts.value(~threeVoicesFifthAboveNtvls);
		if (
			~beatNtvls.size > 32 and:
			{ ~ntvlOpts.find([2]) !== nil } and:
			{ [1, 5].find([fictaDegree]) === nil },
			{
				addPrecadentialBeats.value(voiceCount);

				if ([4,3,0].find([fictaDegree]) !== nil,
					{ ~beatNtvls = ~beatNtvls.add(\cadenceRaised) },
					{ ~beatNtvls = ~beatNtvls.add(\cadence) }
				);
			},
			{
				var chosenNtvl = ~ntvlOpts.choose;
				~beatNtvls = ~beatNtvls.add(chosenNtvl);
				~netDegrees = ~netDegrees + chosenNtvl;
			}
		);
	});
};
~leaps = (
	-3: fourthDownOptions,
	-1: secondDownOptions,
	0: sustainOptions,
	2: thirdUpOptions,
	4: fifthUpOptions,
	\cadence: [\cadence],
	\cadenceRaised: [\cadenceRaised],
	\cadence1: cadence1Options,
	\cadenceRaised1: cadenceRaised1Options,
	\cadence2: cadence2Options,
	\cadence3: cadence3Options,
);
~beatNtvls = [];
~netDegrees = 0;
~ntvlSets = (
	2: [-3, -1, 0, 2, 4],
	3: [-3, 0, 2, 4]
);
~ntvlOpts = [];
~ntvlValidations = (
	4: {
		if (isPrereqLastNtvlPresent.value([ -3, -1, 0 ]) and:
			{ isLastNtvlsNotMatching.value([4, -3]) } and:
			{ isLastNtvlsNotMatching.value([4, 0]) } and:
			{ isLastNtvlsNotMatching.value([2, -3]) } and:
			{ ~netDegrees < 40 },
			{ ~ntvlOpts = ~ntvlOpts.add(4) }
		);
	},
	2: {
		if (
			isPrereqLastNtvlPresent.value([ -3, -1, 0, 2, 4 ]) and:
			{ isLastNtvlsNotMatching.value([2, 2]) }and:
			{ ~netDegrees < 42 },
			{ ~ntvlOpts = ~ntvlOpts.add(2)}
		);
	},
	0: {
		if (isPrereqLastNtvlPresent.value([ 0 ]) !== true,
			{ ~ntvlOpts = ~ntvlOpts.add(0) }
		);
	},
	-1: {
		if (
			isPrereqLastNtvlPresent.value([ -3, -1, 0, -2, 4 ]) and:
			{ ~netDegrees > 26 },
			{ ~ntvlOpts = ~ntvlOpts.add(-1) }
		);
	},
	-3: {
		if (
			isPrereqLastNtvlPresent.value([ 0, 2, 4 ]) and:
			{ isLastNtvlsNotMatching.value([-3, 4]) } and:
			{ isLastNtvlsNotMatching.value([-3, 0]) } and:
			{ ~netDegrees > 28 },
			{ ~ntvlOpts = ~ntvlOpts.add(-3) }
		);
	}
);
~getNtvlOpts = {
	arg potentialNtvls = [];
	~ntvlOpts = [];
	potentialNtvls.do({ |ntvl|
		~ntvlValidations[ntvl].value();
	});
};
~melodyCreator = {
	arg beats = [];
	var melody = [];
	beats.do({ |beat|
		melody = melody.add(~leaps[beat].choose);
	});
	melody;
};
~tailorMelody = {
	arg melody = [], voiceNum = 1;
	if (voiceNum === 3, { 2.do({ melody.pop; }) });
	if (voiceNum === 1 && melody[melody.size - 1] === \cadenceRaised,
		{
			melody.pop;
			melody = melody.add(~leaps[('cadenceRaised'++voiceNum).asSymbol].choose);
		},
		{
			melody.pop;
			melody = melody.add(~leaps[('cadence'++voiceNum).asSymbol].choose);
		}
	);
	melody.flatten;
};

~canonAndPause = {
	arg voices = 3;
	var melody, createVoice, lastDegreeDict;
	var root = 0;
	var degree = (0..5).choose;
	var octave = 4;
	~beatNtvls = [~ntvlSets[voices].choose];
	~netDegrees = octave*7 + ~beatNtvls[0] + degree;

	beatCreator.value;
	melody = ~melodyCreator.value(~beatNtvls);

	lastDegreeDict = (
		1: degree,
		2: degree + 4,
		3: degree - 3
	);

	createVoice = {
		arg voiceNum = 1, totalVoices = 3;
		var stepData = Pseq(~tailorMelody.value(melody, voiceNum), 1);
		var pan = (voiceNum - 1)/(totalVoices - 1) - 0.5;
		Pmono(\simple,
			\stepData, stepData,
			\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
			\degree, Pfunc({|event| event[\stepVelocity] + lastDegreeDict[voiceNum] }),
			\dur, Pkey(\stepData).collect({|e| e[1]}),
			\scale, Scale.major,
			\octave, octave,
			\root, root,
			\pan, pan,
			\gate, 1,
			\amp, 1,
			\callback, { |event| lastDegreeDict[voiceNum] = event[\degree] }
		).play(quant: Quant(1, 0, voiceNum - 1));
	};
	voices.do({ |i| createVoice.value(i + 1) });
	((~beatNtvls.size + 1) * (1/TempoClock.default.tempo)).yield;
};

TempoClock.default.tempo = 0.8;
s.latency = 0.2;

bus.free;
bus = Bus.audio(s, 2);
lag = 0.05;
SynthDef(\simple, {
	arg freq = 100, i_pan = 0, gate = 1, amp = 1;
	var sig, env;
	env = EnvGen.ar(Env([0, 0.5, 0], [0.2, 1], releaseNode: 1), gate: gate, doneAction: Done.freeSelf);
	sig = Lag.kr(freq, lag);
	sig = Mix.new(Array.fill(3, {|i| var num = (i+1); SinOsc.ar(sig * num) * 1/(num**3) }));
	sig = Pan2.ar(sig, i_pan, 1) * env;
	sig = sig * amp;
	Out.ar(bus, sig);
}).add;

SynthDef(\reverb, {
	var sig = In.ar(bus, 2);
	sig = FreeVerb.ar(sig, 0.2, 0.9);
	Out.ar(0, sig);
}).add;
)

(
Synth(\reverb);
// pass 2 or 3 as the argument to get a canon of that number of voices
Task({ { ~canonAndPause.value(2) }.loop; }).start;
)