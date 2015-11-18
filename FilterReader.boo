namespace TURBU.RubyMarshal.Reader

import System
import System.Collections.Generic
import System.Linq.Enumerable
import Boo.Lang.Compiler.Ast

macro Filter(name as string, Body as ExpressionStatement*):
	macro Code(id as int):
		fragments as List[of Expression] = Filter['fragments']
		if fragments is null:
			fragments = List[of Expression]()
			Filter['fragments'] = fragments
		fragments.Add([|c.Code == $id|])
	
	macro Value(data as BinaryExpression):
		raise "Value expression must begin with an integer" unless data.Left isa IntegerLiteralExpression
		data.Operator = BinaryOperatorType.Equality if data.Operator == BinaryOperatorType.Assign
		left as Expression = [|c.Params[$(data.Left)]|]
		if data.Right.Matches([|Target|]) or data.Right isa IntegerLiteralExpression:
			left = [| $left cast int |]
		elif data.Right isa StringLiteralExpression:
			left = [| $left cast string |]
		data = BinaryExpression(data.Operator, left, data.Right)
		fragments as List[of Expression] = Filter['fragments']
		if fragments is null:
			fragments = List[of Expression]()
			Filter['fragments'] = fragments
		fragments.Add(data)
	
	raise "Only Code and Value expressions are allowed in a filter" unless Body.Count == 0
	fragments as List[of Expression] = Filter['fragments']
	raise "A filter must contain at least one filter expression" if fragments.Count == 0
	expr as Expression = fragments[0]
	for sub in fragments.Skip(1):
		expr = [|$expr and $sub|]
	return ExpressionStatement([|AddFilter($name, {c as TURBU.RubyMarshal.XPEventCommand, Target as int | return $expr} )|])