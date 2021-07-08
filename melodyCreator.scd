(thisProcess.nowExecutingPath.dirname+/+"melodyCreatorUtilities.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var beatNtvls = [[-3, 0, 2, 4].choose];
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
var netDegrees = octave*7 + beatNtvls[0] + degree;

var getNtvlOpts = {
	var ntvlOpts = [];
	// fourth down
	if (
		isPrereqLastNtvlPresent.value([ 2, 0, 4 ]) and:
		{ isLastNtvlsNotMatching.value([-3, 4]) } and:
		{ isLastNtvlsNotMatching.value([-3, 0]) } and:
		{ netDegrees > 28 },
		{ ntvlOpts = ntvlOpts.add(-3) }
	);
	// sustain
	if (isLastNtvlsNotMatching.value([0, 0]) /*and:
		{ isPrereqLastNtvlPresent.value([-1]) !== true }*/,
		{ ntvlOpts = ntvlOpts.add(0) });
	// third up
	if (
		isPrereqLastNtvlPresent.value([ -3, 0, 2, 4 ]) and:
		{ isLastNtvlsNotMatching.value([2, 2]) }and:
		{ netDegrees < 42 },
		{ ntvlOpts = ntvlOpts.add(2) }
	);
	// fifth up
	if (isPrereqLastNtvlPresent.value([ -3, 0, 2 ])and:
		{ isLastNtvlsNotMatching.value([4, -3]) } and:
		{ isLastNtvlsNotMatching.value([4, 0]) } and:
		{ isLastNtvlsNotMatching.value([2, -3]) } and:
		{ netDegrees < 40 },
		{ ntvlOpts = ntvlOpts.add(4) }
	);
	ntvlOpts;
};

var beatCreator = {
	while({
		beatNtvls.size < 40 and:
		{ [\cadence, \cadenceRaised ].find([beatNtvls[beatNtvls.size - 1]]) === nil };
	}, {
		var ntvlOpts = getNtvlOpts.value();
		var fictaDegree = (netDegrees + 3) % 7;
		if (beatNtvls.size > 15 and: { ntvlOpts.find([2]) !== nil } and: { [1, 5].find([fictaDegree]) === nil },
			{
				var leadingTone;
				beatNtvls = beatNtvls.add(2);
				beatNtvls = beatNtvls.add(-1);
				fictaDegree.postln;
				if ([4,3,0].find([fictaDegree]) !== nil, //no cadencing on 5
					{ beatNtvls = beatNtvls.add(\cadenceRaised) },
					{ beatNtvls = beatNtvls.add(\cadence) }
				);
			},
			{
				var chosenNtvl = ntvlOpts.choose;
				beatNtvls = beatNtvls.add(chosenNtvl);
				netDegrees = netDegrees + chosenNtvl;
				netDegrees.postln;
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
	Pmono(\simple,
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