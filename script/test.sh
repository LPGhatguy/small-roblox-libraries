#!/bin/sh

set -e

for library in libraries/*; do
	testez run "$library" --target lemur
done