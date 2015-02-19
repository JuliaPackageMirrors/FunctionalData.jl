println("\n\n\nStarting runtests.jl $(join(ARGS, " ")) ...")
addprocs(4)
@everywhere using FactCheck, FunctionalData, Compat
FactCheck.setstyle(:compact)

shouldtest(f, a) = length(ARGS) == 0 || in(a, ARGS) ? facts(f, a) : nothing
shouldtestcontext(f, a) = length(ARGS) < 2 || a == ARGS[2] ? facts(f, a) : nothing

shouldtest("exports") do
    # Check whether all exported symbols really exist
    for a in names(FunctionalData)
        # @fact eval(a) => eval("FunctionalData.$a")
    end
end

shouldtest("views") do
    a = [1,2,3]
    @fact view(a,1)  =>  row([1])
    @fact view(a,3)  =>  row([3])
    a = [1 2 3]
    @fact view(a,1)  =>  row([1])
    @fact view(a,3)  =>  row([3])
    a = [1 2 3; 4 5 6]
    @fact view(a,1)  =>  col([1,4])
    @fact view(a,3)  =>  col([3,6])
    v = view(a,2) 
    v[2] = 10
    @fact a => [1 2 3; 4 10 6]
    a = UInt8[1 2 3; 4 5 6]
    @fact view(a,1)  =>  col(Uint8[1,4])
    @fact view(a,3)  =>  col(Uint8[3,6])
    @fact view(a,2:3)  => part(a,2:3)
end

shouldtest("lensize") do
    @fact siz(1)      =>  transpose([1 1])
    @fact siz([1])    =>  transpose([1 1])
    @fact siz([1,2])  =>  transpose([2 1])
    @fact siz([1;2])  =>  transpose([2 1])
    @fact siz([1 2])  =>  transpose([1 2])
    @fact siz(transpose([1 2]))  =>  transpose([2 1])

    @fact siz3(rand(1))  => [1 1 1]'
    @fact siz3(rand(1,2))  => [1 2 1]'
    @fact siz3(rand(1,2,3))  => [1 2 3]'

    @fact len(1)        =>  1
    @fact len([1])      =>  1
    @fact len([1,2])    =>  2
    @fact len([1;2])    =>  2
    @fact len([1 2])    =>  2
    @fact len([1,2,3])  =>  3
    @fact len([1 1 1 ;2 2 3])  =>  3
    @fact len("adsf")   =>   4
    @fact len('a')      =>  1
    @fact len(['a',1])  =>  2

end

shouldtest("basics") do
    shouldtestcontext("ones") do
        @fact onessiz([2 3 4]') => ones(2,3,4)
        @fact zerossiz([2 3 4]') => zeros(2,3,4)
        @fact size(randsiz([2 3 4]')) => (2,3,4)
        @fact size(randnsiz([2 3 4]')) => (2,3,4)
    end
    shouldtestcontext("shones") do
        @fact shonessiz([2 3 4]') => ones(2,3,4)
        @fact shzerossiz([2 3 4]') => zeros(2,3,4)
        @fact size(randsiz([2 3 4]')) => (2,3,4)
        @fact size(randnsiz([2 3 4]')) => (2,3,4)
    end
    shouldtestcontext("repeat") do
        @fact repeat('a',0) => ""
        @fact repeat('a',1) => "a"
        @fact repeat('a',3) => "aaa"
        @fact repeat("a",0) => ""
        @fact repeat("a",1) => "a"
        @fact repeat("a",3) => "aaa"
        @fact repeat(1,3)  => [1 1 1]
        @fact repeat([1],3) => [1 1 1]
        @fact repeat([1;2],3) => [1 1 1; 2 2 2]
    end
end

shouldtest("accessors") do
    shouldtestcontext("at") do
        @fact at([1,2,3],1) => 1
        @fact at([1 2 3],1) => col([1])
        @fact at([1;2;3],1) => 1
        @fact at((1,2,3),1) => 1
        @fact at([1 2 3; 4 5 6],1) => col([1 4])
        @fact at(cat(3,[1 1],[2 2],[3 3]),1) => [1 1]

        @fact at("asdf",1) => 'a'
        @fact at(Any["aa",1],1) => "aa"
        @fact at(['a','b'],2) => 'b'
        @fact at(['a','b'],1) => 'a'

        @fact size(at(rand(2,3,4),(1,))) => ()
        @fact size(at(rand(2,3,4),(1:2,))) => (2,)
        @fact size(at(rand(2,3,4),([1,2],1:2))) => (2,2)
    end

    shouldtestcontext("setat") do
        a = [1,2,3]
        setat!(a, 1, 10)
        @fact at(a,1) => 10
        a = [1 2 3]
        setat!(a, 1, 10)
        @fact at(a,1) => col([10])
        setat!(a, 1, col([10]))
        @fact at(a,1) => col([10])
        a = [1 2 3; 4 5 6]
        setat!(a, 1, col([10,11]))
        @fact at(a,1) => col([10,11])
        a = cat(3,[1 1],[2 2],[3 3])
        setat!(a,1,[10 11])
        @fact at(a,1) => [10 11]

        a = Any["aa",1]
        setat!(a, 1, "bb")
        @fact at(a,1) => "bb"
    end

    # shouldtestcontext("at!") do
    #     @fact at!([1,2,3],1)   1
    #     @fact at!([1 2 3],1)    slicedim([1 2 3],2,1)
    #     @fact at!([1;2;3],1)    1
    #     @fact at!([1 2 3; 4 5 6],1)    slicedim([1 2 3; 4 5 6],2,1)
    #     @fact at!("asdf",1)    'a'
    #     @fact at!(['a','b'],1)    'a'
    #     @fact at!([1,[2 3],'a'],2)    [2 3]

    #     D = [1 2 3; 4 5 6]
    #     b = at!(D,2)
    #     b[2] = 1000
    #     @fact D    [1 2 3; 4 100 6]
    # end

    shouldtestcontext("part") do
        @fact part([1,2,3],[1])  => [1]
        @fact part([1,2,3],1:2) => [1,2]
        @fact part([1,2,3],[1,2]) => [1,2]
        @fact part([1 2 3],[1,3]) => [1 3]
        @fact part([1 2 3],[1,3]) => slicedim([1 2 3],2,[1,3])
        @fact part([1;2;3],[1,3]) => [1;3]
        @fact part([1 2 3; 4 5 6],[1,3]) => [1 3;4 6]
        @fact part([1 2 3; 4 5 6],[1 2; 3 2]) => [3 5]
    end

    shouldtestcontext("trimmedpart") do
        @fact trimmedpart([1:10], -1:3) => [1,2,3]
        @fact trimmedpart([1:10], 1:3) => [1,2,3]
        @fact trimmedpart([1:10], 8:13) => [8,9,10]
        @fact trimmedpart([1:10], 13:15) => []
    end

    shouldtestcontext("fst") do
        @fact fst([1 2 3]) => col([1])
        @fact fst(1:3) => 1
        @fact fst([1 2 3; 4 5 6]) => col([1,4])
        @fact fst('a') => 'a'
        @fact fst("asdf") => 'a'
    end

    shouldtestcontext("last") do
        @fact last([1 2 3]) => col([3])
        @fact last(1:3) => 3
        @fact last([1 2 3; 4 5 6]) => col([3,6])
        @fact last('a') => 'a'
        @fact last("asdf") => 'f'
    end

    shouldtestcontext("drop") do
        @fact drop([1,2,3],1) => [2,3]
        @fact drop(Any["test",2,"asdf"],1) => Any[2,"asdf"]
        @fact drop(Any["test",2,"asdf"],2) => ["asdf"]

        @fact drop(1:3,1) => 2:3
        @fact drop([1 2 3],1) => [2 3]
        @fact drop([1 2 3; 4 5 6],1) => [2 3; 5 6]
        @fact drop([1 2 3; 4 5 6],2) => col([3; 6])
    end

    shouldtestcontext("take") do
        @fact take(1:3,1) => 1:1
        @fact take([1 2 3],1) => col([1])
        @fact take([1 2 3; 4 5 6],1) => col([1; 4])
        @fact take([1 2 3; 4 5 6],2) => [1 2; 4 5]
        @fact take("asdf",1) => "a"
        @fact take("asdf",2) => "as"

        @fact last(1:3,1) => 3:3
        @fact last([1 2 3],1) => col([3])
        @fact last([1 2 3; 4 5 6],1) => col([3; 6])
        @fact last([1 2 3; 4 5 6],2) => [2 3; 5 6]
        @fact last("asdf",1) => "f"
        @fact last("asdf",2) => "df"
    end

    shouldtestcontext("takelast") do
        @fact takelast("asdf",1) => "f"
        @fact takelast("asdf",2) => "df"
        @fact takelast("asdf",10) => "asdf"
    end

    shouldtestcontext("droplast") do
        @fact droplast(1:3,1) => 1:2
        @fact droplast([1 2 3],1) => [1 2]
        @fact droplast([1 2 3; 4 5 6],1) => [1 2 ; 4 5 ]
        @fact droplast([1 2 3; 4 5 6],2) => col([1; 4])
    end

    shouldtestcontext("partition") do
        @fact partition(1:3,2)  => Any[1:2, 3:3]
        @fact partition(1:10,9) => Any[1:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:10]
        @fact partition([1:3], 5) => Any[[1],[2],[3],Any[],Any[]]
    end
    shouldtestcontext("partsoflen") do

    end
end

type _somedummytype
  a
  b
end

shouldtest("getfield") do
    @fact extract([_somedummytype(1,2)],:a) => [1]
    @fact extract([_somedummytype(1,2)],:b) => [2]
    a = _somedummytype(1,2)
    @fact (@getfield(a,a)) => 1
    @fact (@getfield(a,b)) => 2
end


shouldtest("arraylike") do
    @fact size(FunctionalData.arraylike([1],2)) => (1,2)
    @fact size(FunctionalData.arraylike([1 2],2)) => (1,2,2)
    @fact size(FunctionalData.arraylike(1,2)) => (1,2)
end


shouldtest("computing") do
    shouldtestcontext("sort") do
        @fact FunctionalData.sort([1,2,3], id) => [1,2,3]
        @fact FunctionalData.sort([1 2 3], id) => [1 2 3]
        @fact FunctionalData.sort([1,2,3], x->-x) => [3,2,1]
        @fact FunctionalData.sort([1 2 3], x->-x) => [3 2 1]
        @fact FunctionalData.sort("dcba", int) => "abcd"
        @fact FunctionalData.sort("dcba", int; rev = true) => "dcba"
        @fact FunctionalData.sortrev("dcba", int) => "dcba"
    end
    shouldtestcontext("unique") do
        @fact sort(unique([1 2 3], id),id)  =>  [1 2 3]
        @fact sort(unique([1 2 1], id),id)  =>  [1 2]
        @fact sort(unique([-1 2 1], abs),id)  =>  [-1 2]
    end
    shouldtestcontext("map") do
        @fact map([1 2 3; 4 5 6], x->[size(x,1)]) =>   [2 2 2]
        @fact map([1 2 3; 4 5 6], x->[size(x,1);size(x,1)]) => [2 2 2; 2 2 2]
        @fact map([1 2 3; 4 5 6], x->[size(x,1),size(x,1)]) => [2 2 2; 2 2 2]
        @fact map([1 2 3; 4 5 6], x->[size(x,1) size(x,1)]) => cat(3,[2 2],[2 2],[2 2])
        d = @compat Dict("a" => 1, :b => 2)
        @fact map(d, x -> x*10) => @compat Dict("a" => 10, :b => 20)
    end
    shouldtestcontext("mapmap") do
        @fact mapmap([[1 2], [3 4]], x -> x+1)  =>  [[2 3], [4 5]]
    end
    shouldtestcontext("map!") do
        f(x) = x*2
        f!(x) = x[:] = f(x)
        f!r(x) = f(x)
        f2!(r,x) = r[:] = vcat(f(x),f(x))
        a = [1 2 3; 4 5 6]
        @fact map(a,f) => [2 4 6; 8 10 12]
        a = [1 2 3; 4 5 6]
        map!(a,f!)
        @fact a => [2 4 6; 8 10 12]
        a = [1 2 3; 4 5 6]
        map!r(a,f)
        @fact a => [2 4 6; 8 10 12]
        a = [1 2 3; 4 5 6]
        r = zeros(Int, 4, 3)
        map2!(a, r, f2!)
        @fact r => 2*vcat(a,a)
        r = zeros(Int, 4, 3)
        r = map2!(a, x->vcat(x,x)*2, f2!)
        @fact r => 2*vcat(a,a)
    end
    shouldtestcontext("shmap") do
        a = row([1:3])
        r = shmap(a, x->x+1)
        @fact r => a + 1
        a = rand(10,int(1e6))
        r = shmap(a, x->x+1)
        @fact r => a+1
    end
    shouldtestcontext("shmap!") do
        a = share(row([1:3]))
        orig = copy(a)
        shmap!(a, x->x[:] = x+1)
        @fact a => orig + 1
        a = share(rand(10,int(1e6)))
        orig = copy(a)
        shmap!(a, x->x[:] = x+1)
        @fact a => orig + 1
    end
    shouldtestcontext("shmap!r") do
        a = share(row([1:3]))
        orig = copy(a)
        shmap!r(a, x-> x+1)
        @fact a => orig + 1
        # a = share(rand(10,int(1e6)))
        # orig = copy(a)
        # shmap!r(a, x-> x+1)
        # @fact a => orig + 1
    end
    shouldtestcontext("shmap2!") do
        a = row([1:3])
        r = shmap2!(a, x->x+1, (r,x)->r[:] = x+1)
        @fact r => a + 1
        r = shzerossiz(siz(a))
        shmap2!(a, r, (r,x)->r[:] = x+1)
        @fact r => a + 1
        a = rand(10,int(1e6))
        r = shmap2!(a, x->x+1, (r,x)->r[:] = x+1)
        @fact r => a + 1
    end
    shouldtestcontext("pmap") do
        a = row([1:3])
        r = pmap(a, x->x+1)
        @fact r => a + 1
        a = rand(2,10)
        r = pmap(a, x->x+1)
        @fact r => a+1
    end
    shouldtestcontext("lmap") do
        a = row([1:3])
        r = lmap(a, x->x+1)
        @fact r => a + 1
        a = rand(2,10)
        r = lmap(a, x->x+1)
        @fact r => a+1
    end
    shouldtestcontext("table") do
        adder(x,y) = x+y
        pass(x,y) = [x,y]
        @fact table(id,[1,2,3])  =>  [1,2,3]
        @fact table(pass,[1,2],1:3)  =>  cat(3, [1 2; 1 1], [1 2; 2 2], [1 2; 3 3])
        @fact ltable(id,[1,2,3])  =>  [1,2,3]
        @fact ltable(pass,[1,2],1:3)  =>  cat(3, [1 2; 1 1], [1 2; 2 2], [1 2; 3 3])
        @fact ptable(id,[1,2,3])  =>  [1,2,3]
        @fact ptable(pass,[1,2],1:3)  =>  cat(3, [1 2; 1 1], [1 2; 2 2], [1 2; 3 3])
        @fact tableany(id,[1,2,3])  =>  Any[1,2,3]
        @fact tableany(pass,[1,2],1:3)  =>  reshape(Any[[1,1], [2,1], [1,2], [2,2], [1,3], [2,3]], 2,3)
    end
end

shouldtest("dataflow") do
    shouldtestcontext("reshape") do
        @fact size(reshape(rand(9)))  =>  (3,3)
    end
    context("rowcol") do
        @fact row(1)  =>  ones(Int, 1, 1)
        @fact row([1,2,3])  =>  [1 2 3]
        @fact row(1,2,3)    =>  [1 2 3]
        @fact col(1)  =>  ones(Int, 1, 1)
        @fact col([1,2,3])  =>  [1 2 3]'
        @fact col(1,2,3)    =>  [1 2 3]'
    end
    context("stack") do
        @fact stack(Any[1,2]) => [1 2]
        @fact stack(Any[[1 2],[3 4]]) => cat(3,[1 2], [3 4])
        @fact stack(Any[zeros(2,3,4),ones(2,3,4)]) => cat(4,zeros(2,3,4),ones(2,3,4))
    end
    shouldtestcontext("flatten") do
        @fact flatten(Any[[1],[2]]) => [1,2]
        @fact flatten(Any[row([1]),col([2])]) => [1 2]
        @fact flatten(Any[[1 2],[2 3]]) => [1 2 2 3]
        @fact flatten(Any[[1 2]',[2 3]']) => [1 2; 2 3]
        @fact flatten(Any[[1, 2],[2, 3]]) => [1,2,2,3]
        @fact flatten(Any[[1; 2],[2; 3]]) => [1,2,2,3]
        @fact flatten(Any[Any[[1; 2],[2; 3]]]) => Any[[1; 2],[2; 3]]
        @fact flatten(Char['a','b','c']) => "abc"
        @fact flatten(Char['a' 'b' 'c']) => "abc"
        @fact flatten(["a","b","c"]) => "abc"
        @fact flatten(["a" "b" "c"]) => "abc"
        @fact flatten(Any["a","b","c"]) => "abc"
        @fact flatten(Any["a" "b" "c"]) => "abc"
    end
    context("unstack") do
        @fact unstack(cat(3,[1 2],[2 3])) => Any[[1 2],[2 3]]
        @fact unstack(stack(Any[[1 2],[2 3]])) => Any[[1 2],[2 3]]
        @fact unstack(stack(Any[zeros(2,3,4),ones(2,3,4)])) => Any[zeros(2,3,4),ones(2,3,4)]
        @fact unstack([1 2 3; 4 5 6]) => Any[col([1,4]), col([2,5]), col([3,6])]
        @fact unstack((1,2,3)) => Any[1,2,3]
    end
    context("riffle") do
        @fact riffle([1:3],0) => [1,0,2,0,3]
        @fact riffle(1,0) => 1
        @fact riffle([1 2 3; 4 5 6],zeros(2,1)) => [1 0 2 0 3; 4 0 5 0 6]
        @fact riffle([1 2 3; 4 5 6],[8;9]) => [1 8 2 8 3; 4 9 5 9 6]
        @fact riffle("abc",'_') => "a_b_c"
        @fact riffle("abc","_") => "a_b_c"
        @fact riffle("abc",", ") => "a, b, c"
        @fact riffle([1,2,3],0) => [1,0,2,0,3]
    end
    shouldtestcontext("matrix") do
        a = Any[ones(2,3), zeros(2,3)]
        @fact size(matrix(a))  =>  6,2
        @fact unmatrix(matrix(a),a)  =>  a
    end
    context("lines") do
        @fact lines("line1\nline2\r\nline3") => ["line1","line2","line3"]
        @fact unlines(lines("line1\nline2\r\nline3")) => "line1\nline2\nline3"
    end
    context("findsub") do
        a = [0 1 -1; 1 0 0]
        @fact findsub(a)  =>  [2 1 1; 1 2 3]
    end
    shouldtestcontext("subtoind") do
        @fact subtoind([1 1]', rand(2,3)) => 1
    end
    shouldtestcontext("randsample") do
        @fact size(randsample(1:10,5))  =>  (5,)
        @fact size(randsample(rand(2,10),20))  =>  (2,20)
        @fact randsample("aaa",5)  =>  "aaaaa"
    end
end

shouldtest("unzip") do
    @fact unzip([]) => []
    @fact unzip([]) => []
    @fact unzip([1]) => Any[row(1)]
    @fact unzip(Any[[1 2]])  =>  Any[row([1]),row([2])]
    @fact unzip(Any[[1, 2]]) => Any[row([1]),row([2])]
    @fact unzip(Any[[1, 11], [2, 22]]) => Any[[1 2], [11 22]]
end


shouldtest("pipeline") do
    add(x,y) = x.+y
    minus(x,y) = x.-y

    x = @p add 1 2
    @fact x => 3

    @fact (@p add 1 2) => 3
    @fact (@p add 1 2 | minus 2) => 1
    @fact (@p add 1 2 | minus _ 2) => 1
    @fact (@p add 1 2 | minus 3 _) => 0

    @fact (@p map [1 2 3] add 1)  =>  [2 3 4]
    @fact (@p map [1 2 3] minus 1)  =>  [0 1 2]

    x = @p linspace 1 5 5 | map add 1
    @fact x  =>  [2 3 4 5 6]

    x = @p add (1:5) 1 | map add 1 | map minus 1
    @fact x  =>  [2 3 4 5 6]

    x = @p map (1:5) add 1 
    @fact x  =>  [2 3 4 5 6]

    x = @p id [1] | map _ (x->x+_+_+_)
    @fact x  =>  row([4])
end

shouldtest("io") do
    shouldtestcontext("readwrite") do
        filename = tempname()
        write("line1\nline2\nline3",filename)
        @fact read(filename)  =>  "line1\nline2\nline3"
        @fact lines(read(filename))  =>  lines("line1\nline2\nline3")

        @p read filename | lines 
        @fact (@p read filename | lines | unlines | lines | unlines)  =>  "line1\nline2\nline3"
    end

    # matname = string(tempname(),".mat")
    # data = ["a"=>1:3,"b"=>1,"c"=>[1:3],"d"=>"test"]
    # #FIXME writemat(matname, data)

    shouldtestcontext("filenames") do
        d = mktempdir()
        mk(a) = mkpath(joinpath(d,a))
        t(a...) = touch(joinpath(d,a...))
        mk("adir")
        mk("bdir")
        t("a")
        t("b")
        t("adir","a")
        t("adir","b")
        @fact filenames(d)  =>  ["a","b"]
        @fact  dirnames(d)  =>  ["adir","bdir"]
        rm(d, recursive = true)
    end
end

s = getstats()
if s["nNonSuccessful"] == 0
    print("   PASSED!")
else
    print("   FAILED: $(s["nFailures"]) failures and $(s["nErrors"]) errors") 
end
println("   ( $(s["nNonSuccessful"]+s["nSuccesses"]) tests for runtests.jl $(join(ARGS, " ")))")
exit(s["nNonSuccessful"])








