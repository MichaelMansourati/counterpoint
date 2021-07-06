(thisProcess.nowExecutingPath.dirname+/+"melodyCreatorUtilities.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var beatNtvls = [0];
var isPrereqLastNtvlPresent = { |prereqNtvls|
	prereqNtvls.find([
		beatNtvls[beatNtvls.size - 1]
	]) !== nil;
};
var isLastNtvlsMatching = { arg ntvls = [];
	if (ntvls.size <= beatNtvls.size,
		{
			ntvls == beatNtvls.slice(
				((beatNtvls.size - (ntvls.size))..(beatNtvls.size - 1))
			);
		},
		{ false }
	);
};



var getNtvlOpts = {
	var ntvlOpts = [];
	// fourth down
	if (
		isPrereqLastNtvlPresent.value([ 2, 0, 4 ]) and:
		{ isLastNtvlsMatching.value([4, -3, 4]) !== true },
		{ ntvlOpts = ntvlOpts.add(-3) }
	);
	// second down
	if (isPrereqLastNtvlPresent.value([ 2 ]), {
		ntvlOpts = ntvlOpts.add(-1)
	});
	// sustain
	if (isPrereqLastNtvlPresent.value([ -3, 2, 4 ]), {
		ntvlOpts = ntvlOpts.add(0)
	});
	// third up
	if (
		isPrereqLastNtvlPresent.value([ -3, 2, 4 ]) and:
		{ isLastNtvlsMatching.value([2, 2]) !== true },
		{ ntvlOpts = ntvlOpts.add(2) }
	);
	// fifth up
	if (isPrereqLastNtvlPresent.value([ -3, 0, 2 ])and:
		{ isLastNtvlsMatching.value([-3, 4, -3]) !== true }, {
		ntvlOpts = ntvlOpts.add(4)
	});
	//cadence
	if (isPrereqLastNtvlPresent.value([-1]), {
		ntvlOpts = ntvlOpts.add(\cadence)
	});
	ntvlOpts;
};

var beatCreator = {
	while( {
		beatNtvls.size < 40 and: { beatNtvls[beatNtvls.size - 1] !== \cadence };
	}, {
		var ntvlOpts = getNtvlOpts.value();
		if (beatNtvls.size > 15 and: { ntvlOpts.find([2]) !== nil },
			{ beatNtvls = beatNtvls.addAll([2, -1, \cadence]); },
			{ beatNtvls = beatNtvls.add(ntvlOpts.choose) }
		);
	});
	beatNtvls;
};

var melodyCreator = { arg beats = [];
	var melody = [];
	beats.do({ |beat|
		melody = melody.add(~leaps[beat].choose);
	});
	melody;
};

var melodyAdjuster = { arg melody = [], voiceNum = 1;
	melody.pop;
	if (voiceNum === 3,
		{ 2.do({ melody.pop; }) }
	);
	melody = melody.add(~leaps[('cadence'++voiceNum).asSymbol].choose);
	melody.flatten;
};
var melody = melodyCreator.value(beatCreator.value.postln);
var melodyVoice1 = melodyAdjuster.value(melody, 1);
var melodyVoice2 = melodyAdjuster.value(melody, 2);
var melodyVoice3 = melodyAdjuster.value(melody, 3);
var voice1, voice2, voice3;
Synth(\reverb);
~root = (0..6).choose;
~lastDegreeVoice1 = (0..6).choose;
~lastDegreeVoice2 = ~lastDegreeVoice1 + 4;
~lastDegreeVoice3 = ~lastDegreeVoice1 - 3;
~quantVoice1 =  Quant(1, 0, 0);
~quantVoice2 = Quant(1, 0, 1);
~quantVoice3 = Quant(1, 0, 2);
Pdef(\voice,
	Pmono(
		\simple,
		\stepData, Pseq(melodyVoice1, 1),
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
		}
	)
);

voice1 = Pbindf(Pdef(\voice)).play(quant: ~quantVoice1);

voice2 = Pbindf(
	Pdef(\voice),
	\stepData, Pseq(melodyVoice2, 1),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pfunc({|event| event[\stepVelocity] + topEnvironment[\lastDegreeVoice2]}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice2] = event[\degree];
	}
).play(quant: ~quantVoice2);

voice3 = Pbindf(
	Pdef(\voice),
	\stepData, Pseq(melodyVoice3, 1),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pfunc({|event| event[\stepVelocity] + topEnvironment[\lastDegreeVoice3]}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice3] = event[\degree];
	}
).play(quant: ~quantVoice3);
)