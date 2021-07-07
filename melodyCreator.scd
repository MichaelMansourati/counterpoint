(thisProcess.nowExecutingPath.dirname+/+"melodyCreatorUtilities.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var beatNtvls = [0];
var isPrereqLastNtvlPresent = { |prereqNtvls|
	prereqNtvls.find([
		beatNtvls[beatNtvls.size - 1]
	]) !== nil;
};
var isLastNtvlsNotMatching = { arg ntvls = [];
	if (ntvls.size <= beatNtvls.size,
		{
			ntvls != beatNtvls.slice(
				((beatNtvls.size - (ntvls.size))..(beatNtvls.size - 1))
			);
		},
		{ true }
	);
};

var root = 0;
var degree = (0..5).choose;
var octave = 4;

var midiNumberVoice1 = (octave*12 + root+ Scale.major.at(degree));

var midiNumberToDegree = {
	arg midiNumber = 0.0;
	var semitoneCount = midiNumber % 12;
	var degree = Scale.major.semitones.find([semitoneCount]);
	degree;
};

var trackMidiNumber = {
	arg ntvl;
	ntvl;
	if (ntvl.isKindOf(Number), {
		if (ntvl < 0,
			{midiNumberVoice1 = midiNumberVoice1 - Scale.major.at(ntvl.abs)},
			{midiNumberVoice1 = midiNumberVoice1 + Scale.major.at(ntvl.abs)}
		)
	});
	midiNumberVoice1;
};

var getNtvlOpts = {
	var ntvlOpts = [];
	// fourth down
	if (
		isPrereqLastNtvlPresent.value([ 2, 0, 4 ]) and:
		{ isLastNtvlsNotMatching.value([-3, 4]) } and:
		{ isLastNtvlsNotMatching.value([-3, 0]) } and:
		{ midiNumberVoice1 > 46 },
		{ ntvlOpts = ntvlOpts.add(-3) }
	);
	// second down
/*	if (isPrereqLastNtvlPresent.value([ 2 ]) and:
		{ midiNumberVoice1 > 46 },
		{ ntvlOpts = ntvlOpts.add(-1) }
	);*/
	// sustain
	if (isLastNtvlsNotMatching.value([0, 0]) and:
		{ isPrereqLastNtvlPresent.value([-1]) !== true }, {
		ntvlOpts = ntvlOpts.add(0)
	});
	// third up
	if (
		isPrereqLastNtvlPresent.value([ -3, 0, 2, 4 ]) and:
		{ isLastNtvlsNotMatching.value([2, 2]) }and:
		{ midiNumberVoice1 < 70 },
		{ ntvlOpts = ntvlOpts.add(2) }
	);
	// fifth up
	if (isPrereqLastNtvlPresent.value([ -3, 0, 2 ])and:
		{ isLastNtvlsNotMatching.value([4, -3]) } and:
		{ isLastNtvlsNotMatching.value([4, 0]) } and:
		// { isLastNtvlsNotMatching.value([2, -3]) } and: this might be necessary
		{ midiNumberVoice1 < 70 },
		{ ntvlOpts = ntvlOpts.add(4) }
	);
	//cadence
/*	if (isPrereqLastNtvlPresent.value([-1]), {
		ntvlOpts = ntvlOpts.add(\cadence)
	});*/
	ntvlOpts;
};

var beatCreator = {
	while({
		beatNtvls.size < 40 and:
		{ [\cadence, \cadenceRaised ].find([beatNtvls[beatNtvls.size - 1]]) === nil };
	}, {
		var ntvlOpts = getNtvlOpts.value();
		if (beatNtvls.size > 6 and: { ntvlOpts.find([2]) !== nil },
			{
				var toneToFind;
				beatNtvls = beatNtvls.add(2);
				trackMidiNumber.value(2);
				beatNtvls = beatNtvls.add(-1);
				trackMidiNumber.value(-1);
				"midiNumberVoice1 ".post;
				midiNumberVoice1.postln;
				"midiToDegree ".post;
				midiNumberToDegree.value(midiNumberVoice1).postln;
				toneToFind = midiNumberToDegree.value(midiNumberVoice1);
				toneToFind.postln;
				if ([3,6,7,2].find([toneToFind]) !== nil,
					{ beatNtvls = beatNtvls.add(\cadenceRaised) },
					{ beatNtvls = beatNtvls.add(\cadence) }
				);
			},
			{
				var chosenNtvl = ntvlOpts.choose;
				beatNtvls = beatNtvls.add(chosenNtvl);
				trackMidiNumber.value(chosenNtvl);
			}
		);
	});
	beatNtvls.postln;
};

var melodyCreator = {
	arg beats = [];
	var melody = [];
	beats.do({ |beat|
		melody = melody.add(~leaps[beat].choose);
	});
	melody;
};

var melodyAdjuster = {
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
var melody = melodyCreator.value(beatCreator.value);
var createVoice, voice1, voice2, voice3;


~lastDegreeVoice1 = degree;
~lastDegreeVoice2 = ~lastDegreeVoice1 + 4;
~lastDegreeVoice3 = ~lastDegreeVoice1 - 3;
Synth(\reverb);

createVoice = {
	arg voiceNum = 1, totalVoices = 3;
	var stepData = Pseq(melodyAdjuster.value(melody, voiceNum), 1);
	var pan = (voiceNum - 1)/(totalVoices - 1) - 0.5;
	Pmono(
		\simple,
		\stepData, stepData,
		\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
		\degree, Pfunc({|event| event[\stepVelocity] + topEnvironment[('lastDegreeVoice'++voiceNum).asSymbol]}),
		\dur, Pkey(\stepData).collect({|e| e[1]}),
		\scale, Scale.major,
		\octave, octave,
		\root, root,
		\pan, pan,
		\gate, 1,
		\amp, 1,
		\callback, {|event|
			topEnvironment[('lastDegreeVoice'++voiceNum).asSymbol] = event[\degree];
		}
	).play(quant: Quant(1, 0, voiceNum - 1));
};

voice1 = createVoice.value(1);
voice2 = createVoice.value(2);
voice3 = createVoice.value(3);
)