#!/bin/sh
find "data/favicons" -name "*.ico" -exec file {} \; | egrep "(text|empty)" | sed 's/://' | cut -d' ' -f1 | xargs -n1 rm
