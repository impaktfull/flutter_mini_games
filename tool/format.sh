#!/bin/bash

flutter format . --line-length=180

cd example
flutter format . --line-length=180
cd ..