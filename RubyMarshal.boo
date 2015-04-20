namespace TURBU.RubyMarshal

import System.IO
import System.Text
import TURBU.Meta

callable UserDefMarshal(sr as BinaryReader) as object

class RubyMarshal():
	private _symbols = List[of Hash]()
	private _userDefines = System.Collections.Generic.Dictionary[of string, UserDefMarshal]()

	def AddUnique(name as string, reader as UserDefMarshal):
		_userDefines.Add(name, reader)

	def Read(filename as string) as Object:
		_symbols.Clear()
		using fs = FileStream(filename, FileMode.Open), sr = BinaryReader(fs):
			versionMajor = sr.Read()
			versionMinor = sr.Read()
			assert versionMajor == 4
			assert versionMinor == 8
			result = ReadElement(sr)
		return result
	
	private def ReadElement(sr as BinaryReader):
		elem = sr.ReadByte()
		caseOf elem:
			case 0x22: return ReadAsciiString(sr)
			case 0x30: return null
			case 0x3a: return ReadSymbol(sr)
			case 0x3b: return ReadSymlink(sr)
			case 0x40: return ReadObjLink(sr)
			case 0x46: return false
			case 0x49: return ReadIVAR(sr)
			case 0x54: return true
			case 0x5b: return ReadArray(sr)
			case 0x63: return ReadClass(sr)
			case 0x69: return ReadInteger(sr)
			case 0x6d: return ReadModule(sr)
			case 0x6f: return ReadObject(sr)
			case 0x7b: return ReadHash(sr)
			case 0x75: return ReadUnique(sr)
			default: raise "Unknown element type ($(elem.ToString('X')))"
	
	private def ReadInteger(sr as BinaryReader) as int:
		value as int = sr.ReadSByte()
		return 0 if value == 0
		if value < 0:
			sign = -1
			value *= sign
		else: sign = 1
		return (value - 5) * sign if value > 5 and value < 0xFA
		if value < 5:
			result = 0
			for i in range(value):
				result |= sr.ReadByte() << (8 * i)
			return result * sign
		else: assert false, "Unknown integer size"
	
	private def ReadAsciiString(sr as BinaryReader) as string:
		buffer = sr.ReadBytes(ReadInteger(sr))
		return Encoding.UTF8.GetString(buffer)
	
	private def ReadStringHash(sr as BinaryReader, name as string) as Hash:
		return {'Type': name, 'Name': ReadAsciiString(sr)}
		
	private def ReadSymbol(sr as BinaryReader) as Hash:
		result = ReadStringHash(sr, 'Symbol')
		_symbols.Add(result)
		return result
	
	private def ReadSymlink(sr as BinaryReader) as Hash:
		return _symbols[ReadInteger(sr)]
	
	private def ReadObjLink(sr as BinaryReader) as Hash:
		return {'Type': 'ObjLink', 'ID': ReadInteger(sr)}
	
	private def ReadIVAR(sr as BinaryReader) as Hash:
		assert sr.ReadByte() == 0x22
		value = ReadAsciiString(sr)
		count = ReadInteger(sr)
		encoding1 = ReadElement(sr)
		encoding2 = ReadElement(sr)
		properties = []
		for i in range(1, count):
			properties.Add(ReadElement(sr))
		return {'Type': 'IVAR', 'Object': value, 'Encoding': {encoding1: encoding2}, 'Props': properties}
	
	private def ReadArray(sr as BinaryReader) as List:
		result = []
		count = ReadInteger(sr)
		for i in range(count):
			result.Add(ReadElement(sr))
		return result
	
	private def ReadHash(sr as BinaryReader) as Hash:
		values = {}
		result = {'Type': 'Hash', 'Values': values}
		count = ReadInteger(sr)
		for i in range(count):
			key = ReadElement(sr)
			value = ReadElement(sr)
			values.Add(key, value)
		return result
	
	private def ReadClass(sr as BinaryReader) as Hash:
		return ReadStringHash(sr, 'Class')
	
	private def ReadModule(sr as BinaryReader) as Hash:
		return ReadStringHash(sr, 'Module')
	
	private def ReadObject(sr as BinaryReader) as Hash:
		symbol as object
		elem = sr.ReadByte()
		caseOf elem:
			case 0x3a: symbol = ReadSymbol(sr)['Name']
			case 0x3b: symbol = ReadSymlink(sr)['Name']
			default: raise "Unknown Object name type ($(elem.ToString('X')))"
		values = {}
		result = {'Type': 'Object', 'Class': symbol, 'Values': values}
		count = ReadInteger(sr)
		for i in range(count):
			key = ReadElement(sr)
			assert key isa int or key isa Hash
			if key isa Hash:
				kHash = key cast Hash
				assert kHash["Type"] == "Symbol"
				key = kHash["Name"]
			value = ReadElement(sr)
			values.Add(key, value)
		return result
	
	private def ReadUnique(sr as BinaryReader):
		elem = sr.ReadByte()
		caseOf elem:
			case 0x3a: symbol = ReadSymbol(sr)
			case 0x3b: symbol = ReadSymlink(sr)
			default: raise "Unknown UserDef symbol type ($(elem.ToString('X')))"
		userDef = symbol['Name']
		reader = _userDefines[userDef]
		buffer = sr.ReadBytes(ReadInteger(sr))
		using ms = MemoryStream(buffer), subReader = BinaryReader(ms):
			return reader(subReader)
		