namespace TURBU.RubyMarshal

import System

static class DefaultFilters:
"""Holds the default value for filters.txt.
I really should use a Resource for this, but unfortunately resources are broken in the #Develop build process"""
	public Value = `
Filter 'Add Item':
	Any:
		All:
			Code 126
			Value 0 = Target
		All:
			Any:
				Code 302
				Code 605
			Value 0 = 0
			Value 1 = Target
Filter 'Add Weapon':
	Any:
		All:
			Code 127
			Value 0 = Target
		All:
			Any:
				Code 302
				Code 605
			Value 0 = 1
			Value 1 = Target
Filter 'Add Armor':
	Any:
		All:
			Code 128
			Value 0 = Target
		All:
			Any:
				Code 302
				Code 605
			Value 0 = 2
			Value 1 = Target
Filter 'Set Switch':
	Code 121
	Value 0 <= Target
	Value 1 >= Target
Filter 'Set Variable':
	Code 122 
	Value 0 <= Target
	Value 1 >= Target
Filter 'Teleport To Map':
	Code 201 
	Value 1 = Target
`