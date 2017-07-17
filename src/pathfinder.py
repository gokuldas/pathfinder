#!/usr/bin/env python3
# Script to set bash PATH environment variable

import os, sys, toml

if 'XDG_CONFIG_HOME' in os.environ:
    xdgch = os.environ['XDG_CONFIG_HOME']
else:
    xdgch = ''

if xdgch == '':
    filepath = '$HOME/.config/pathfinder/pathfinder.toml'
else:
    filepath = xdgch + '/pathfinder/pathfinder.toml'

config = toml.load(os.path.expandvars(filepath))
# TODO: Handle absence of pathfinder.toml
cfg_paths = [os.path.expandvars(i['path']) for i in config['Paths']]
aspects = [set(i['aspects'] + ['all']) for i in config['Paths']]

# Invariant: operation valid, path_list valid, targets not empty
operation = sys.argv[1]
targets = set(sys.argv[2:])
path_list = sys.stdin.read().strip().split(':')
while '' in path_list:
    path_list.remove('')

candidates = [p for p, a in zip(cfg_paths, aspects) if targets & a != set()]

if False: # True for debug
    print('Operation  : ', operation, '\n')
    print('Targets    : ', targets, '\n')
    print('Path list  : ', path_list, '\n')
    print('CfgPaths   : ', cfg_paths, '\n')
    print('Aspects    : ', aspects, '\n')
    print('Candidates : ', candidates, '\n')

if operation == 'add':
    path_list = [p for p in candidates if p not in path_list] + path_list

elif operation == 'remove':
    path_list = [p for p in path_list if p not in candidates]

final_path = ':'.join(path_list)
sys.stdout.write(final_path)

