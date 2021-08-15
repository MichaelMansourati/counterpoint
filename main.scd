(
(thisProcess.nowExecutingPath.dirname+/+"leaps.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"intervalValidations.scd").load;
)
(
var bus, lag,
// returns the degree number that will act as
// the leading tone of the cadence
getLeadingToneDegree = {
	arg voiceOrder = 'MHL';
	(
		'MHL': { (~netDegrees + 3) % 7 },
		'MH': { (~netDegrees + 1) % 7 },
		'ML': { (~netDegrees + 2) % 7 }
	)[voiceOrder].value();
},

addPrecadentialBeats = {
	arg voiceOrder = 'MHL';
	var beatsToAdd;
	(
		'MHL': { beatsToAdd = [ 2, -1 ] },
		'MH': { beatsToAdd = [ -1 ] },
		'ML': { beatsToAdd = [ 1 ] },
	)[voiceOrder].value();
	~beatNtvls = ~beatNtvls.addAll(beatsToAdd);

},

getIsTimeToCadence = {
	arg voiceOrder = 'MHL', leadingToneDegree = 0;
	var prereq = (
		~beatNtvls.size > 6 ).and(
		[1, 5].find([leadingToneDegree]) === nil
	);
	(
		'MHL': (
			~beatNtvls.size > 32 ).and(
			~ntvlOpts.find([2]) !== nil ).and(
			[1, 5].find([leadingToneDegree]) === nil
		),
		'MH': prereq,
		'ML': prereq
	)[voiceOrder].value();
},

beatCreator = {
	arg voiceOrder = 'MHL';
	while({
		~beatNtvls.size < 40 and:
		{ [\cadence, \cadenceRaised ].find([~beatNtvls[~beatNtvls.size - 1]]) === nil };
	}, {
		var leadingToneDegree = getLeadingToneDegree.value(voiceOrder);
		~getNtvlOpts.value(voiceOrder);
		if (
			getIsTimeToCadence.value(voiceOrder, leadingToneDegree),
			{
				addPrecadentialBeats.value(voiceOrder);

				if ([4,3,0].find([leadingToneDegree]) !== nil,
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
},
getLastDegreeDict = {
	arg degree = 0, voiceOrder = 'MHL';
	(
		'MHL': (
			1: degree,
			2: degree + 4,
			3: degree - 3
		),
		'MH': (
			1: degree,
			2: degree + 4
		),
		'ML': (
			1: degree,
			2: degree - 4
		)
	)[voiceOrder];
};


~beatNtvls = [];
~netDegrees = 0;
~ntvlSets = (
	'MH': [-3, -1, 0, 2, 4],
	'MHL': [-3, 0, 2, 4],
	'ML': [3, 1, 0, -2, -4],
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
	arg melody = [], voiceNum = 1, voiceOrder = 'MHL';
	var cadenceString,
	cadenceType = melody[melody.size - 1];

	if (voiceNum === 3, { 2.do({ melody.pop; }) });
	melody.pop;

	cadenceString = 'cadence'++voiceNum++voiceOrder;

	if (voiceNum === 1 && cadenceType === \cadenceRaised,
		{ cadenceString = cadenceString++'Raised' }, {}
	);

	melody = melody.add(~leaps[(cadenceString).asSymbol].choose);
	melody.flatten;
};

~canonAndPause = {
	arg voiceOrder = 'MHL';
	var melody, createVoice, lastDegreeDict;
	var root = 0;
	var degree = (0..5).choose;
	var octave = 4;
	~beatNtvls = [~ntvlSets[voiceOrder].choose];
	~netDegrees = octave*7 + ~beatNtvls[0] + degree;
	beatCreator.value(voiceOrder);
	melody = ~melodyCreator.value(~beatNtvls);
	lastDegreeDict = getLastDegreeDict.value(degree, voiceOrder);
	createVoice = {
		arg voiceNum = 1;
		var stepData, pan;
		stepData = Pseq(~tailorMelody.value(melody, voiceNum, voiceOrder), 1);
		pan = (voiceNum - 1)/(voiceOrder.asString.size - 1) - 0.5;

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
	voiceOrder.asString.size.do({ |i| createVoice.value(i + 1) });
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
Task({ {
	// ~canonAndPause.value('MH');
	// ~canonAndPause.value('MHL');
	~canonAndPause.value('ML');

}.loop; }).start;
)