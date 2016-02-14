namespace TURBU.RubyMarshal.Reader

import System
import System.Collections.Generic
import System.Linq.Enumerable
import Boo.Lang.Compiler.Ast

macro Filter(name as string):
	macro Any:
		ValidateMacro(Any)
		var expr = ExpressionChain(FragmentsFor(Any), BinaryOperatorType.Or)
		ParentFragments(Any).Add(expr)
	
	macro All:
		ValidateMacro(All)
		var expr = ExpressionChain(FragmentsFor(All), BinaryOperatorType.And)
		ParentFragments(All).Add(expr)
	
	macro Code(id as int):
		var fragments = ParentFragments(Code)
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
		var fragments = ParentFragments(Value)
		fragments.Add(data)
	
	ValidateMacro(Filter)
	fragments as List[of Expression] = Filter['fragments']
	raise "A filter must contain at least one filter expression" if fragments.Count == 0
	expr as Expression = fragments[0]
	for sub in fragments.Skip(1):
		expr = [|$expr and $sub|]
	return ExpressionStatement([|AddFilter($name, {c as TURBU.RubyMarshal.XPEventCommand, Target as int | return $expr} )|])

internal def ExpressionChain(fragments as Expression*, operator as BinaryOperatorType) as Expression:
	result as Expression = null
	for expr in fragments:
		result = (expr if result is null else BinaryExpression(operator, result, expr))
	return result

internal def FragmentsFor(node as MacroStatement) as List of Expression:
	fragments as List[of Expression] = node['fragments']
	if fragments is null:
		fragments = List[of Expression]()
		node['fragments'] = fragments
	return fragments

internal def ParentFragments(node as MacroStatement) as List of Expression:
	return FragmentsFor(node.GetAncestor[of MacroStatement]())

internal def ValidateMacro(node as MacroStatement):
	raise "Only Code, Value, Any and All expressions are allowed in a filter" unless node.Body.Statements.Count == 0