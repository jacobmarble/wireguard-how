build:
	rm -rf public/ resources/
	hugo --minify=true --verbose=true --verboseLog=true
