namespace TURBU.RubyMarshal

import System

static class DefaultFilters:
"""Holds the default value for filters.txt.
I really should use a Resource for this, but unfortunately resources are broken in the #Develop build process"""
	public Value = `
Filter 'Add Item':
	Code 126
	Value 0 = Target
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