(
(thisProcess.nowExecutingPath.dirname+/+"leaps.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"intervalValidations.scd").load;
)
(
var bus, lag,
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
		~getNtvlOpts.value(voiceCount);
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

~beatNtvls = [];
~netDegrees = 0;
~ntvlSets = (
	2: [-3, -1, 0, 2, 4],
	3: [-3, 0, 2, 4]
);
~ntvlOpts = [];

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
	arg voiceCount = 3;
	var melody, createVoice, lastDegreeDict;
	var root = 0;
	var degree = (0..5).choose;
	var octave = 4;
	~beatNtvls = [~ntvlSets[voiceCount].choose];
	~netDegrees = octave*7 + ~beatNtvls[0] + degree;
	beatCreator.value(voiceCount);
	melody = ~melodyCreator.value(~beatNtvls);

	lastDegreeDict = (
		1: degree,
		2: degree + 4,
		3: degree - 3
	);

	createVoice = {
		arg voiceNum = 1;
		var stepData = Pseq(~tailorMelody.value(melody, voiceNum), 1);
		var pan = (voiceNum - 1)/(voiceCount - 1) - 0.5;
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
	voiceCount.do({ |i| createVoice.value(i + 1) });
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
	sig = FreeVerb.ar(sig, 0.2, 0.9, 0.9);
	Out.ar(0, sig);
}).add;
)

(
Synth(\reverb);
// pass 2 or 3 as the argument to get a canon of that number of voices
Task({ { ~canonAndPause.value(2) }.loop; }).start;
)