#!/bin/sh

mkdir -p release
rm -rf release/*.rbxm

for library in libraries/*; do
	rojo build "$library" -o "release/$(basename $library).rbxm"
done