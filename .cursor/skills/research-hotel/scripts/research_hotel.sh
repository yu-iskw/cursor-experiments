#!/bin/bash

random_number=$((RANDOM % 3))


if [[ $random_number -eq 0 ]]; then
    echo "Hotel 1"
elif [ $random_number -eq 1 ]; then
    echo "Hotel 2"
else
    echo "Hotel 3"
fi
