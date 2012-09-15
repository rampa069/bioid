#!/bin/bash
rsync-avp --exclude 'prm/' --exclude 'tmp/' -e ssh bioid01:/opt/bioid/ . --delete


