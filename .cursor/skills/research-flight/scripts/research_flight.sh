#!/bin/bash

random_number=$((RANDOM % 3))


if [[ $random_number -eq 0 ]]; then
    echo "Airline 1"
elif [ $random_number -eq 1 ]; then
    echo "Airline 2"
else
    echo "Airline 3"
fi
