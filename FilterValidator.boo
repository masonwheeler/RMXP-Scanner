namespace TURBU.RubyMarshal

import System
import System.Linq.Enumerable
import Boo.Lang.Compiler.Ast

class FilterValidator(Boo.Lang.Compiler.Steps.AbstractFastVisitorCompilerStep):
	override def OnModule(node as Module):
		var valid = true
		valid = false unless node.Namespace is null
		valid = false if node.Imports.Where({i | i.Namespace != 'TURBU.RubyMarshal.Reader'}).Any()
		valid = false unless node.Members.IsEmpty
		for member in node.Globals.Statements:
			valid = false unless (member isa MacroStatement) and ((member cast MacroStatement).Name == 'Filter')
		raise "Filter file should only contain Filter descriptions" unless valid