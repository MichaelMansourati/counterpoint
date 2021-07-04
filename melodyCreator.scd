(thisProcess.nowExecutingPath.dirname+/+"utilities.scd").load;

(
var beatIntervals = [];

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

~melodyCreator = {
	beatIntervals = [0];
	while( {
		beatIntervals.size < 40 and: { beatIntervals[beatIntervals.size - 1] !== \cadence };
	}, {
		var intervalOptions = getIntervalOptions.value();
		if (beatIntervals.size > 20 and: { intervalOptions.postln.find([2]) !== nil },
			{ beatIntervals = beatIntervals.addAll([2, -1, \cadence]); },
			{ beatIntervals = beatIntervals.add(intervalOptions.choose) }
		);
	});
	beatIntervals;
};

~melodyCreator.value();
)