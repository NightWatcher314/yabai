.PHONY: clean build run all osax-patterns

all: clean build run osax-patterns

clean:
	rm -rf ./bin

build:
	mkdir -p ./bin
	clang ./src/tests.m -o ./bin/tests -DTESTS -DPROFILE=1 -F/System/Library/PrivateFrameworks -framework Carbon -framework Cocoa -framework CoreServices -framework CoreVideo -framework SkyLight

run:
	./bin/tests

osax-patterns:
	mkdir -p ./bin
	xcrun clang ./osax_macos27.m -framework Foundation -o ./bin/osax_macos27
	./bin/osax_macos27
