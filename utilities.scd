(
var lastStep, isCadenceStarted, lag, bus,
fourthDownOptions = [
	[ [ 0, 1 ], [-3, 0 ] ],
	[ [ 0, 0.75 ], [ -1, 0.125 ], [ -1, 0.125 ], [ -1,  0] ],
],
secondDownOptions = [
	[ [ 0, 1 ], [ -1, 0 ] ],
	// [ [ 0, 0.5 ], [ -1, 0.25 ], [ -1, 0.25 ], [ 1, 0 ] ]
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
cadenceOptions = [
	[ [ 0, 0.01 ], [ 0, 0.49 ], [ 3, 1 ], [ -1, 0.5 ], [ 1, 2 ] ]
],
leaps = (
	-3: fourthDownOptions,
	-1: secondDownOptions,
	0: sustainOptions,
	2: thirdUpOptions,
	4: fifthUpOptions,
	3: cadenceOptions
);

~scale = Scale.major;
~setup = {
	~root = (0..6).choose;
	~lastDegreeVoice1 = (0..6).choose;
	~lastDegreeVoice2 = ~lastDegreeVoice1 + 4;
	~lastDegreeVoice3 = ~lastDegreeVoice1 - 3;
	~cadenceMelodyVoice2 = Pseq([ [ 0, 1 ], [ -1, 2 ] ], 1).asStream;
	~cadenceMelodyVoice3 = Pseq([ [ 0, 1 ], [ -3, 1 ], [ 3, 2 ] ], 1).asStream;
	~quantVoice1 =  Quant(1, timingOffset: 0);
	~quantVoice2 = Quant(1, timingOffset: 1);
	~quantVoice3 = Quant(1, timingOffset: 2);
	isCadenceStarted = false;
	lastStep = 0;
};

~setup.value;


~getMelodyForState = { |int|
	var ornamentOptions = leaps[int];
	lastStep = int;
	ornamentOptions;
};

~checkCadence = {
	if (isCadenceStarted,
		{},
		{ isCadenceStarted = ~lastVoiceEvent.asStream[\stepData] == [ 0, 0.01 ]; }
	);
	isCadenceStarted;
};

TempoClock.default.tempo = 0.75;
s.latency = 0.2;

bus.free;
bus = Bus.audio(s, 2);
lag = 0.1;
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