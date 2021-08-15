(
var isPrereqLastNtvlPresent = { |prereqNtvls|
	prereqNtvls.find([
		~beatNtvls[~beatNtvls.size - 1]
	]) !== nil;
},
isLastNtvlsNotMatching = { arg ntvls = [];
	if (ntvls.size <= ~beatNtvls.size,
		{
			ntvls != ~beatNtvls.slice(
				((~beatNtvls.size - (ntvls.size))..(~beatNtvls.size - 1))
			);
		},
		{ true }
	);
};
~getNtvlOpts = {
	arg voiceOrder = 'MHL';
	~ntvlOpts = [];
	~ntvlValidations[voiceOrder].do({ |func| func.value() });
};

//max 47, min 26
~ntvlValidations = (
	'MHL': [
		{
			if (isPrereqLastNtvlPresent.value([ -3, -1, 0 ]) and:
				{ isLastNtvlsNotMatching.value([4, -3]) } and:
				{ isLastNtvlsNotMatching.value([4, 0]) } and:
				{ isLastNtvlsNotMatching.value([2, -3]) } and:
				{ ~netDegrees < 40 },
				{ ~ntvlOpts = ~ntvlOpts.add(4) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ -3, -1, 0, 2, 4 ]) and:
				{ isLastNtvlsNotMatching.value([2, 2]) }and:
				{ ~netDegrees < 42 },
				{ ~ntvlOpts = ~ntvlOpts.add(2)}
			);
		},
		{
			if (isPrereqLastNtvlPresent.value([ 0 ]) !== true,
				{ ~ntvlOpts = ~ntvlOpts.add(0) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ 0, 2, 4 ]) and:
				{ isLastNtvlsNotMatching.value([-3, 4]) } and:
				{ isLastNtvlsNotMatching.value([-3, 0]) } and:
				{ ~netDegrees > 28 },
				{ ~ntvlOpts = ~ntvlOpts.add(-3) }
			);
		}
	],
	'MH': [
		{
			if (isPrereqLastNtvlPresent.value([ -3, -1, 0 ]) and:
				{ ~netDegrees < 40 },
				{ ~ntvlOpts = ~ntvlOpts.add(4) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ -3, -1, 0, 2, 4 ]) and:
				{ isLastNtvlsNotMatching.value([2, 2]) }and:
				{ ~netDegrees < 42 },
				{ ~ntvlOpts = ~ntvlOpts.add(2)}
			);
		},
		{
			if (isPrereqLastNtvlPresent.value([ 0 ]) !== true,
				{ ~ntvlOpts = ~ntvlOpts.add(0) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ -3, -1, 0, 2, 4 ]) and:
				{ ~netDegrees > 26 },
				{ ~ntvlOpts = ~ntvlOpts.add(-1) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ 0, 2, 4 ]) and:
				{ ~netDegrees > 28 },
				{ ~ntvlOpts = ~ntvlOpts.add(-3) }
			);
		}
	],
	'ML': [
		{
			if (isPrereqLastNtvlPresent.value([ 3, 1, 0 ]) and:
				{ ~netDegrees > 33 },
				{ ~ntvlOpts = ~ntvlOpts.add(-4) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ 3, 1, 0, -2, -4 ]) and:
				{ isLastNtvlsNotMatching.value([-2, -2]) }and:
				{ ~netDegrees > 31 },
				{ ~ntvlOpts = ~ntvlOpts.add(-2)}
			);
		},
		{
			if (isPrereqLastNtvlPresent.value([ 0 ]) !== true,
				{ ~ntvlOpts = ~ntvlOpts.add(0) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ 3, 1, 0, -2, -4 ]) and:
				{ ~netDegrees < 47 },
				{ ~ntvlOpts = ~ntvlOpts.add(1) }
			);
		},
		{
			if (
				isPrereqLastNtvlPresent.value([ 0, -2, -4 ]) and:
				{ ~netDegrees < 45 },
				{ ~ntvlOpts = ~ntvlOpts.add(3) }
			);
		}
	]
);
)