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
bus, lag;
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
~threeVoicesFifthAboveNtvls = [-3, 0, 2, 4];
~twoVoicesFifthAboveNtvls = [-3, -1, 0, 2, 4];
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