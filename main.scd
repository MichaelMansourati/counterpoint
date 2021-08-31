(
(thisProcess.nowExecutingPath.dirname+/+"leaps.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"intervalValidations.scd").load;
)
(
var bus1, bus2, lag,
// returns the degree number that would act as
// the leading tone of the cadence were the cadence
// to occur at the time of calling
getLeadingToneDegree = {
	var leadingToneDistance = (
		'MH': 1,
		'ML': 2,
		'MHL': 3,
		'MLH': 0
	)[~voiceOrder];
	(~netDegrees + leadingToneDistance) % 7;

},

// these are the required movements for each voice
// in order to set up the respective cadence for
// each voice order permutation
addPrecadentialBeats = {
	var beatsToAdd =
	(
		'MH': [ -1 ],
		'ML': [ 1 ],
		'MHL': [ 2, -1 ],
		'MLH': [ -2, 1 ]
	)[~voiceOrder];
	~beatNtvls = ~beatNtvls.addAll(beatsToAdd);

},


// check if the minimum required number of beats
// have been selected, the leading tone does not
// fall on invalid, and whatever other requirements
// are necessary for a proper cadence
getIsTimeToCadence = {
	arg leadingToneDegree = 0;
	var prereq = (
		~beatNtvls.size > 32 ).and(
		[1, 5].find([leadingToneDegree]) === nil
	);

	(
		'MH': prereq,
		'ML': prereq,
		'MHL': prereq.and(~ntvlOpts.find([ [ 2, 1 ] ]) !== nil ),
		'MLH': prereq.and(~ntvlOpts.find([ [ -2, 1 ] ]) !== nil )
	)[~voiceOrder].value();
},

// adds beats one by one, ending when a cadence symbol
// has been pushed into the array of beats
createBeats = {
	while({
		~beatNtvls.size < 40 and:
		{ [\cadence, \cadenceRaised ].find([~beatNtvls[~beatNtvls.size - 1]]) === nil };
	}, {
		var leadingToneDegree = getLeadingToneDegree.value;
		~getNtvlOpts.value(~voiceOrder);
		if (
			getIsTimeToCadence.value(leadingToneDegree),
			{
				addPrecadentialBeats.value;

				if ([4,3,0].find([leadingToneDegree]) !== nil,
					{ ~beatNtvls = ~beatNtvls.add(\cadenceRaised) },
					{ ~beatNtvls = ~beatNtvls.add(\cadence) }
				);
			},
			{
				var chosenNtvl = ~ntvlOpts.flop[0].wchoose(~ntvlOpts.flop[1].normalizeSum);
				~ntvlOpts.flop[0]; ~ntvlOpts.flop[1].normalizeSum;
				~beatNtvls = ~beatNtvls.add(chosenNtvl);
				~netDegrees = ~netDegrees + chosenNtvl;
			}
		);
	});
},
// gets the relative starting pitches for each voice
// in its respective permutation
getLastDegreeDict = {
	arg degree = 0;
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
		),
		'MLH': (
			1: degree,
			2: degree - 4,
			3: degree + 3
		)
	)[~voiceOrder];
};


~beatNtvls = [ ];
~netDegrees = 0;
~ntvlSets = (
	'MH': [ -3, -1, 0, 2, 4 ],
	'MHL': [ -3, 0, 2, 4 ],
	'ML': [ 3, 1, 0, -2, -4 ],
	'MLH': [ 3, 0, -2, -4 ]
);
~ntvlOpts = [ ];

~melodyCreator = {
	var melody = [ ];
	~beatNtvls.do({ |beat|
		melody = melody.add(~leaps[beat].choose);
	});
	melody;
};

// picks an ornamentation for each interval,
// and replaces the cadence symbol with the cadence phrase
~tailorMelody = {
	arg melody = [], voiceNum = 1;
	var cadenceString,
	cadenceType = melody[melody.size - 1];

	if (voiceNum === 3, { 2.do({ melody.pop; }) });
	melody.pop;

	cadenceString = 'cadence'++voiceNum++~voiceOrder;

	if (voiceNum === 1 && cadenceType === \cadenceRaised,
		{ cadenceString = cadenceString++'Raised' }, {}
	);

	melody = melody.add(~leaps[(cadenceString).asSymbol].choose);
	melody.flatten;
};


// runs a canon and pauses for a few beats
~canonAndPause = {
	arg voiceOrder = 'MHL';
	var melody, createVoice, lastDegreeDict;
	var root = 0;
	var octave, degree;
	~voiceOrder = voiceOrder.postln;
	if (['MLH','ML'].includes(~voiceOrder),
		{
			octave = 5;
			degree = (-3..2).choose;
		},
		{
			octave = 4;
			degree = (0..5).choose;
		}
	);
	~beatNtvls = [~ntvlSets[~voiceOrder].choose];
	~netDegrees = octave*7 + ~beatNtvls[0] + degree;

	createBeats.value;

	melody = ~melodyCreator.value;

	lastDegreeDict = getLastDegreeDict.value(degree);

	createVoice = {
		arg voiceNum = 1;

		var stepData = Pseq(~tailorMelody.value(melody, voiceNum), 1);
		var pan = (voiceNum - 1)/(~voiceOrder.asString.size - 1) - 0.5;

		Pmono(\simple,
			\stepData, stepData,
			\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
			\degree, Pfunc({|event| event[\stepVelocity] + lastDegreeDict[voiceNum] }),
			\dur, Pkey(\stepData).collect({|e| e[1]}),
			\scale, Scale.major(Tuning.mean5),
			\octave, octave,
			\root, root,
			\pan, pan,
			\gate, 1,
			\amp, 1,
			\callback, { |event| lastDegreeDict[voiceNum] = event[\degree] }
		).play(quant: Quant(1, 0, voiceNum - 1));
	};

	~voiceOrder.asString.size.do({ |i| createVoice.value(i + 1) });
	((~beatNtvls.size + 1) * (1/TempoClock.default.tempo)).yield;
};

TempoClock.default.tempo = 0.8;
s.latency = 0.2;

bus1.free;
bus2.free;
bus1 = Bus.audio(s, 1);
bus2 = Bus.audio(s, 1);
lag = 0.05;
SynthDef(\simple, {
	arg freq = 100, i_pan = 0, gate = 1, amp = 1;
	var sig, env;
	env = EnvGen.ar(Env([0, 0.5, 0], [0.2, 1], releaseNode: 1), gate: gate, doneAction: Done.freeSelf);
	sig = Lag.kr(freq, lag);
	sig = Mix.new(Array.fill(3, {|i| var num = (i+1); FSinOsc.ar(sig * num, 0, 0.75) * 1/(num**3) }));
	sig = Pan2.ar(sig, i_pan, 1) * env;
	sig = sig * amp;
	Out.ar(bus1, sig);
}).add;

SynthDef(\reverb, {
	var sig, sig1, sig2;
	bus1.postln;
	sig1 = In.ar(bus1, 1);
	sig2 = In.ar(bus2, 1);
	sig = FreeVerb2.ar(sig1, sig2, 0.1, 0.9, 0.9);
	Out.ar(0, sig);
}).add;
)

(
Synth(\reverb);
Task({ {
	~canonAndPause.value('MH');
	~canonAndPause.value('MHL');
	~canonAndPause.value('ML');
	~canonAndPause.value('MLH');
}.loop; }).start;
)