namespace TURBU.RubyMarshal

import System.IO

def Tone(sr as BinaryReader) as object:
	r = sr.ReadDouble()
	g = sr.ReadDouble()
	b = sr.ReadDouble()
	sat = sr.ReadDouble()
	assert sr.BaseStream.Position == sr.BaseStream.Length
	return [r, g, b, sat]
