using Terp, Base.Test, Error

import 
	Terp.OWL,
	Terp.NumNode,
	Terp.IdNode,
	Terp.AddNode,
	Terp.BinOpNode,
	Terp.UnOpNode,
	Terp.WithNode,
	Terp.If0Node,
	Terp.AndNode,
	Terp.FunDefNode,
	Terp.FunAppNode,
	Terp.MatNode,
	Terp.MatOpNode,
	Terp.MatSaveNode,
	Terp.MatLoadNode,
	Terp.RenderTextNode,

	Terp.parse,
	Terp.interp,
	Terp.analyze,
	Terp.exec,
	Terp.calc,

	Terp.mtEnv,
	Terp.CEnvironment,

    Terp.NumVal,
    Terp.ClosureVal,
    Terp.MatrixVal
# end imports


@testset "Parsing" begin
	@testset "Reserved Words" begin
		@testset "Simple Ids" begin
			@test_throws LispError parse([:simple_load])
			@test_throws LispError parse([:simple_save])
			@test_throws LispError parse([:render_text])
			@test_throws LispError parse([:emboss])
			@test_throws LispError parse([:drop_shadow])
			@test_throws LispError parse([:inner_shadow])
			@test_throws LispError parse([:min])
			@test_throws LispError parse([:max])
		end
		@testset "With Ids" begin
			@test_throws LispError  parse([:with, [[:simple_load, 1]], 1])
			@test_throws LispError  parse([:with, [[:simple_save, 1]], 1])
			@test_throws LispError  parse([:with, [[:render_text, 1]], 1])
			@test_throws LispError  parse([:with, [[:emboss, 1]], 1])
			@test_throws LispError  parse([:with, [[:drop_shadow, 1]], 1])
			@test_throws LispError  parse([:with, [[:inner_shadow, 1]], 1])
			@test_throws LispError  parse([:with, [[:min, 1]], 1])
			@test_throws LispError  parse([:with, [[:max, 1]], 1])
		end
		@testset "Lambda Ids" begin
			@test_throws LispError  parse([[:lambda, [:simple_save], 1], 2])
			@test_throws LispError  parse([[:lambda, [:simple_load], 1], 2])
			@test_throws LispError  parse([[:lambda, [:render_text], 1], 2])
			@test_throws LispError  parse([[:lambda, [:emboss], 1], 2])
			@test_throws LispError  parse([[:lambda, [:drop_shadow], 1], 2])
			@test_throws LispError  parse([[:lambda, [:inner_shadow], 1], 2])
			@test_throws LispError  parse([[:lambda, [:min], 1], 2])
			@test_throws LispError  parse([[:lambda, [:max], 1], 2])
		end

	end 
	@testset "simple_load" begin
		@test_throws LispError parse([:simple_load])
		@test parse([:simple_load, "path_to_file"]) == MatLoadNode("path_to_file")
		@test_throws LispError parse([:simple_load, "path_to_file", "p2"])
		@test_throws LispError parse([:simple_load, 0])
		@test_throws LispError parse([:simple_load, :id])
	end 
	@testset "simple_save" begin
		@test_throws LispError parse([:simple_save])
		@test_throws LispError parse([:simple_save, 0])
		@test_throws LispError parse([:simple_save, :id])
		@test parse([:simple_save, float([[1,2,3],[4,5,6]]), "path_to_file"]) == 0
		@test_throws LispError parse([:simple_save, float([[1,2,3],[4,5,6]]), "path_to_file", "p2"])
		@test_throws LispError parse([:simple_save, float([[1,2,3],[4,5,6]]), 0, "path_to_file"])
		@test_throws LispError parse([:simple_save, float([[1,2,3],[4,5,6]]), :id, "path_to_file"])
	end 
	@testset "render_text" begin
	end 
	@testset "emboss" begin
	end 
	@testset "drop_shadow" begin
	end 
	@testset "inner_shadow" begin
	end 
	@testset "min" begin
	end 
	@testset "max" begin
	end
end
@testset "Analyze" begin
	@testset "Numbers" begin
		@test analyze(NumNode(5)) == NumNode(5)
	end 
	@testset "Plus" begin
		@test analyze(AddNode([NumNode(1), NumNode(2)])) == BinOpNode(+, NumNode(1), NumNode(2))
		@test analyze(AddNode([NumNode(1), NumNode(2), NumNode(3)])) ==  BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), NumNode(3)))
		@test analyze(AddNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])) == BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), BinOpNode(+, NumNode(3), NumNode(4))))
	end 
	@testset "Minus" begin
		@test analyze(UnOpNode(-, NumNode(1))) == UnOpNode(-, NumNode(1))
		@test analyze(BinOpNode(-, NumNode(1), NumNode(2))) == BinOpNode(-, NumNode(1), NumNode(2))
	end 
	@testset "Multiply" begin
		@test analyze(BinOpNode(*, NumNode(1), NumNode(2))) == BinOpNode(*, NumNode(1), NumNode(2))
	end 
	@testset "Divide" begin
		@test analyze(BinOpNode(/, NumNode(1), NumNode(2))) == BinOpNode(/, NumNode(1), NumNode(2))
	end 
	@testset "Mod" begin
		@test analyze(BinOpNode(mod, NumNode(1), NumNode(2))) == BinOpNode(mod, NumNode(1), NumNode(2))
	end 
	@testset "If0" begin
		@test analyze(If0Node(NumNode(1), NumNode(2), NumNode(3))) == If0Node(NumNode(1), NumNode(2), NumNode(3))
	end 
	@testset "And" begin
		@test analyze(AndNode([NumNode(1), NumNode(2)])) == If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), NumNode(1)))
		@test analyze(AndNode([NumNode(1), NumNode(2), NumNode(3)])) == If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), NumNode(1))))
		@test analyze(AndNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])) == If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), If0Node(NumNode(4), NumNode(0), NumNode(1)))))
	end 
	@testset "With" begin
		@test analyze(WithNode(Dict{Symbol,OWL}(), NumNode(1))) == FunAppNode(FunDefNode(Symbol[],NumNode(1)),OWL[])
		@test analyze(WithNode(Dict(:a => NumNode(2)),NumNode(1))) == FunAppNode(FunDefNode(Symbol[:a],NumNode(1)),OWL[NumNode(2)])
		@test analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),NumNode(1))) == FunAppNode(FunDefNode(Symbol[:a, :b],NumNode(1)),OWL[NumNode(2), NumNode(3)])
		@test analyze(WithNode(Dict(:a => NumNode(2)),IdNode(:a))) == FunAppNode(FunDefNode(Symbol[:a],IdNode(:a)),OWL[NumNode(2)])
		@test analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),IdNode(:b))) == FunAppNode(FunDefNode(Symbol[:a, :b],IdNode(:b)),OWL[NumNode(2), NumNode(3)])
	end 
	@testset "Lambda Def" begin
		@test analyze(FunDefNode(Symbol[], NumNode(1))) == FunDefNode(Symbol[], NumNode(1))
		@test analyze(FunDefNode([:a], NumNode(1))) == FunDefNode([:a], NumNode(1))
		@test analyze(FunDefNode([:a, :b], NumNode(1))) == FunDefNode([:a, :b], NumNode(1))
		@test analyze(FunDefNode([:a], IdNode(:a))) == FunDefNode([:a], IdNode(:a))
		@test analyze(FunDefNode([:a, :b], IdNode(:b))) == FunDefNode([:a, :b], IdNode(:b))
	end 
	@testset "Lambda Call" begin
		@test analyze(FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[])) == FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[])
		@test analyze(FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
		@test analyze(FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])) == FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])
		@test analyze(FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])) == FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])
		@test analyze(FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])) == FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])
	end
end
@testset "Calc" begin
	@testset "Numbers" begin
		@test analyze(NumNode(5)) == NumNode(5)
	end 
	@testset "Plus" begin
		@test calc(analyze(AddNode([NumNode(1), NumNode(2)]))) == NumVal(3)
		@test calc(BinOpNode(+, NumNode(1), NumNode(2))) == NumVal(3)
		@test calc(analyze(AddNode([NumNode(1), NumNode(2), NumNode(3)]))) == NumVal(6)
		@test calc(BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), NumNode(3)))) == NumVal(6)
		@test calc(analyze(AddNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)]))) == NumVal(10)
		@test calc(BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), BinOpNode(+, NumNode(3), NumNode(4))))) == NumVal(10)
	end 
	@testset "Minus" begin
		@test calc(analyze(UnOpNode(-, NumNode(1)))) == NumVal(-1)
		@test calc(UnOpNode(-, NumNode(1))) == NumVal(-1)
		@test calc(analyze(BinOpNode(-, NumNode(1), NumNode(2)))) == NumVal(-1)
		@test calc(BinOpNode(-, NumNode(1), NumNode(2))) == NumVal(-1)
	end 
	@testset "Multiply" begin
		@test calc(analyze(BinOpNode(*, NumNode(1), NumNode(2)))) == NumVal(2)
		@test calc(BinOpNode(*, NumNode(1), NumNode(2))) == NumVal(2)
	end 
	@testset "Divide" begin
		@test calc(analyze(BinOpNode(/, NumNode(1), NumNode(2)))) == NumVal(1/2)
		@test calc(BinOpNode(/, NumNode(1), NumNode(2))) == NumVal(1/2)
		@test_throws LispError calc(BinOpNode(/, NumNode(1), NumNode(0)))
	end 
	@testset "Mod" begin
		@test calc(analyze(BinOpNode(mod, NumNode(1), NumNode(2)))) == NumVal(1)
		@test calc(BinOpNode(mod, NumNode(1), NumNode(2))) == NumVal(1)
		@test_throws LispError calc(BinOpNode(mod, NumNode(1), NumNode(0)))
	end 
	@testset "If0" begin
		@test calc(analyze(If0Node(NumNode(1), NumNode(2), NumNode(3)))) == NumVal(3)
		@test calc(If0Node(NumNode(1), NumNode(2), NumNode(3))) == NumVal(3)
	end 
	@testset "And" begin
		@test calc(analyze(AndNode([NumNode(1), NumNode(2)]))) == NumVal(1)
		@test calc(If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), NumNode(1)))) == NumVal(1)
		@test calc(analyze(AndNode([NumNode(1), NumNode(2), NumNode(3)]))) == NumVal(1)
		@test calc(If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), NumNode(1))))) == NumVal(1)
		@test calc(analyze(AndNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)]))) == NumVal(1)
		@test calc(If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), If0Node(NumNode(4), NumNode(0), NumNode(1)))))) == NumVal(1)
	end 
	@testset "With" begin
		@test calc(analyze(WithNode(Dict{Symbol,OWL}(), NumNode(1)))) == NumVal(1)
		@test calc(FunAppNode(FunDefNode(Symbol[],NumNode(1)),OWL[])) == NumVal(1)
		@test calc(analyze(WithNode(Dict(:a => NumNode(2)),NumNode(1)))) == NumVal(1)
		@test calc(FunAppNode(FunDefNode(Symbol[:a],NumNode(1)),OWL[NumNode(2)])) == NumVal(1)
		@test calc(analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),NumNode(1)))) == NumVal(1)
		@test calc(FunAppNode(FunDefNode(Symbol[:a, :b],NumNode(1)),OWL[NumNode(2), NumNode(3)])) == NumVal(1)
		@test calc(analyze(WithNode(Dict(:a => NumNode(2)),IdNode(:a)))) == NumVal(2)
		@test calc(FunAppNode(FunDefNode(Symbol[:a],IdNode(:a)),OWL[NumNode(2)])) == NumVal(2)
		@test calc(analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),IdNode(:b)))) == NumVal(3)
		@test calc(FunAppNode(FunDefNode(Symbol[:a, :b],IdNode(:b)),OWL[NumNode(2), NumNode(3)])) == NumVal(3)
	end 
	@testset "Lambda Def" begin
		@test calc(analyze(FunDefNode(Symbol[], NumNode(1)))) == ClosureVal(Symbol[],NumNode(1),mtEnv())
		@test calc(FunDefNode(Symbol[], NumNode(1))) == ClosureVal(Symbol[],NumNode(1),mtEnv())
		@test calc(analyze(FunDefNode([:a], NumNode(1)))) == ClosureVal([:a],NumNode(1),mtEnv())
		@test calc(FunDefNode([:a], NumNode(1))) == ClosureVal([:a],NumNode(1),mtEnv())
		@test calc(analyze(FunDefNode([:a, :b], NumNode(1)))) == ClosureVal([:a, :b],NumNode(1),mtEnv())
		@test calc(FunDefNode([:a, :b], NumNode(1))) == ClosureVal([:a, :b],NumNode(1),mtEnv())
		@test calc(analyze(FunDefNode([:a], IdNode(:a)))) == ClosureVal([:a],IdNode(:a),mtEnv())
		@test calc(FunDefNode([:a], IdNode(:a))) == ClosureVal([:a],IdNode(:a),mtEnv())
		@test calc(analyze(FunDefNode([:a, :b], IdNode(:b)))) == ClosureVal([:a, :b],IdNode(:b),mtEnv())
		@test calc(FunDefNode([:a, :b], IdNode(:b))) == ClosureVal([:a, :b],IdNode(:b),mtEnv())
	end
	@testset "Lambda Call" begin
		@test calc(analyze(FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[]))) == NumVal(1)
		@test calc(FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[])) == NumVal(1)
		@test calc(analyze(FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)]))) == NumVal(1)
		@test calc(FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)]))  == NumVal(1)
		@test calc(analyze(FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)]))) == NumVal(1)
		@test calc(FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])) == NumVal(1)
		@test calc(analyze(FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)]))) == NumVal(2)
		@test calc(FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])) == NumVal(2)
		@test calc(analyze(FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)]))) == NumVal(3)
		@test calc(FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])) == NumVal(3)
	end
end
@testset "Wingate's Tests" begin
	@test exec(
		"(with (
			(base_img (render_text \"Hello\" 25 100))
		    (swirl (simple_load \"/Users/jbarzee/all/byu/cs/330/interpreter/ex/swirl_256.png\"))
		    )
		    (with ((ds (drop_shadow base_img)))
		        (with ((tmp4 (+ (* (+ (min ds base_img) (- 1 base_img)) base_img) (* (- 1 base_img) swirl) )))
		            (with ((tmp5 (- 1 (emboss tmp4)))
		                    (base_img2 (render_text \"world!\" 5 200)))
		                (with ((is (inner_shadow base_img2)))
		                    (with ((tmp6 (max base_img2 (* (- 1 base_img2) is) )))
		                        (with ( (output (min tmp5 tmp6 )) )
		                            (simple_save output \"output.png\")
		                        )
		                    )
		                )
		            )
		        )
		    )
		)"
	)
end
"Finished HPInt"