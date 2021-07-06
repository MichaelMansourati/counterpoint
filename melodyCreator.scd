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

var degree = (0..5).choose;
var root= (0..6).choose;
var octave = 5;
var note = octave*12 + root+ Scale.major.at(degree);
var trackMidiNumber = {
	arg ntvl;
	ntvl.postln;
	if (ntvl.isKindOf(Number), {
		if (ntvl < 0,
			{note = note - Scale.major.at(ntvl.abs)},
			{note = note + Scale.major.at(ntvl.abs)}
		)
	});
};
var beatCreator = {
	while( {
		beatNtvls.size < 40 and: { beatNtvls[beatNtvls.size - 1] !== \cadence };
	}, {
		var ntvlOpts = getNtvlOpts.value();
		if (beatNtvls.size > 15 and: { ntvlOpts.find([2]) !== nil },
			{ beatNtvls = beatNtvls.addAll([2, -1, \cadence]); },
			{
				var chosenNtvl = ntvlOpts.choose;
				beatNtvls = beatNtvls.add(chosenNtvl);
				trackMidiNumber.value(chosenNtvl);
			}
		);
	});
	beatNtvls.postln;
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
var createVoice, voice1, voice2, voice3,voice1MidiNote; //max number for voice1MidiNote should be 70, min should be 46 (2 octaves)


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

{ SinOsc.ar(52.midicps) * 0.2 }.play;