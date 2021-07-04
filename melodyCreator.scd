(thisProcess.nowExecutingPath.dirname+/+"melodyCreatorUtilities.scd").load;
(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var beatIntervals = [0];
var isPreqLastIntervalPresent = { |prereqIntervals|
	prereqIntervals.find([
		beatIntervals[beatIntervals.size - 1]
	]) !== nil;
};

var getIntervalOptions = {
	var intervalOptions = [];
	// fourth down
	if (isPreqLastIntervalPresent.value([ 2, 0, 4 ]), {
		intervalOptions = intervalOptions.add(-3)
	});
	// second down
	if (isPreqLastIntervalPresent.value([ 2 ]), {
		intervalOptions = intervalOptions.add(-1)
	});
	// sustain
	if (isPreqLastIntervalPresent.value([ -3, 2, 4 ]), {
		intervalOptions = intervalOptions.add(0)
	});
	// third up
	if (isPreqLastIntervalPresent.value([ -3, 2, 4 ]), {
		intervalOptions = intervalOptions.add(2)
	});
	// fifth up
	if (isPreqLastIntervalPresent.value([ -3, 0, 2 ]), {
		intervalOptions = intervalOptions.add(4)
	});
	//cadence
	if (isPreqLastIntervalPresent.value([-1]), {
		intervalOptions = intervalOptions.add(\cadence)
	});
	intervalOptions;
};

var beatCreator = {
	while( {
		beatIntervals.size < 40 and: { beatIntervals[beatIntervals.size - 1] !== \cadence };
	}, {
		var intervalOptions = getIntervalOptions.value();
		if (beatIntervals.size > 5 and: { intervalOptions.find([2]) !== nil },
			{ beatIntervals = beatIntervals.addAll([2, -1, \cadence]); },
			{ beatIntervals = beatIntervals.add(intervalOptions.choose) }
		);
	});
	beatIntervals;
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
var melody = melodyCreator.value(beatCreator.value);
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
		\stepData, Pseq(melodyVoice1, 2),
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
	\stepData, Pseq(melodyVoice2, 2),
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
	\stepData, Pseq(melodyVoice3, 2),
	\stepVelocity, Pkey(\stepData).collect({|e| e[0]}),
	\degree, Pfunc({|event| event[\stepVelocity] + topEnvironment[\lastDegreeVoice3]}),
	\dur, Pkey(\stepData).collect({|e| e[1]}),
	\pan, 0.5,
	\callback, {|event|
		topEnvironment[\lastDegreeVoice3] = event[\degree];
	}
).play(quant: ~quantVoice3);
)