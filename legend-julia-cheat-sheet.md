# Legend Julia Cheat Sheet 
This is a cheat sheet to help you with your coding projects in Julia. 

## In the Julia REPL (read-eval-print loop —> command window) one can enter different modes:
* `?`  → help mode  
* `]`  → package manager 
* `;`  → terminal/shell mode

## VSCode (Editor)  shortcuts:
* `⌘+shift+P`  (Mac) open command palette → from there open Julia REPL

## Useful Julia commands:
* `typeof(x)`  returns variable type of x
* `size(array)` , `length(array)` similar to size and numel in matlab
* `readdir()`  similar to "ls" in shell
* `replace(string,"pattern"=>"new_pattern")` 
* `isequal(x,y)`  returns bool
* `ifelse(condition, value_if_true, value_if_false)` function that chooses between two values based on a condition

### Anonymous functions:
* define function without giving it a name
* example: x->x*2
* can be used in other functions, example: map(x->x*2,[1,2,3])

### Map: `map()`
* Apply function to each element of array/vector/...
* example see anonymous function. 

### Pipe operator: `|>`
* passes result of the expression on its left-hand side of `|>` and passes it as the first argument to the function on its right-hand side
* example: `[3,1,2] |> x-> sort(x)` returns 3-element `Vector{Int64}: 1, 2,  3` 

### Macros: `@` 
* symbol is used to denote macros, e.g. build-in macros like @time begin a = 5 end to measure the execution time
* macros are different from functions (compile time vs. runtime)?

### PropertyFunctions `@pf` 
* Macro (Doc) to broadcast (element-wise) operation to properties of an object
* Faster (reads only relevant entries, less data traffic) than other methods 
```
Using StructArrays
xs = StructArrays.StructArray((
        a = [1,2,3,4,5],
        b = [6,7,8,9,10],
        c = [11,12,13,14,15] ))
out    = xs.b + xs.a.^2 # standard wat to do some elementwise operation 
out_pf = @pf($b + $a.^2)(xs)  # same result as out, but faster
```

### Base.Fix1
* Function `fun1` with mutltiple argument `arg1, arg2` 
* Create a new function `fun2` that is identical to `fun1` except that one of the arguments is fixed to a certain value
```
fun1 = (arg1, arg2) -> print("$arg1 $arg2")
fun2 = Base.Fix1(fun1,"Hallo") #fix first arg1 in fun1
fun2("Duda") # returns: "Hallo Duda"
```
* also possible to fix 2nd, 3rd,..argument. Using the same example as above:
```
fun3 = Base.Fix2(fun1,"Hallo") #fix first arg2 in fun1
fun3("Duda") # returns: "Duda Hallo"
```
### Regular expressions (regex):
* standard julia package
* define a regex via r"hallo" 
* `match("pattern","string", startindex (opt))` search for pattern in string, pattern has to be regex
* pattern examples:
	+ `r"\d+"` one or more digits,  `r"\D"` any non-digit
	+ `r"l.*"` the character "l" and everything that comes after
	+ `r"(?=)"`

### Let block:  
* let blocks create a new scope and (optionally) introduce new local variables
```
let var1 = value1, var2, var3 = value3
    code
end
```
* in this examble `var1`, `var2`, `var3` are new variables that are only accessible within let block
* the values `value1` and `value3` are either actual values or variables defined before the let block

## Julia package manager: 
* `import Pkg` load package manager (alternatively enter package manager in REPL with `]`)
* `Pkg.activate("Environmentpath")`   create a new or activate existing environment ---> can also be defined in settings.json (see "Environments:") 
* `Pkg.add("LegendDataManagement")`   add to package to project environment. clones package from git/main brain. Only for registered package
* `Pkg.update("Packagename")`  update from git 
* `Pkg.instantiate()`  download/precompile correct version of packages that are listed in Manifest.toml
* `Pkg.resolve()`   check that the Manifest.toml is consistent with Project.tomls. then does instantiate() 

### Package development:
* `pathof(PackageName)` → location of package source code  (package has to be used in environment)
* Development of a package: 
	1. Clone (fork of) package, e.g. LegendSpecFits  in `path/LegendSpecFits.jl`
	2. In package manager: `dev path/LegendSpecFits.jl` , `using LegendSpecFits`
	   note that packages can be developed "live", that means changed in functions are seen immediately 
	3. To go back to the "official" package version: `add LegendSpecFits.jl` , `using LegendSpecFits`
* Test packet changes with julia benchmark tools --> Google 

### Environments (package versions): 
* In each folder with Julia code, there is a hidden directory called .vscode 
* Inside .vscode there is a file called `settings.json` that configures settings for this directory 
* example: 
```
{
    "julia.environmentPath": "/home/iwsatlas1/schluete/.julia/environments/legend-dev",
    "git.ignoreLimitWarning": true  // Ignores the warning when there are too many changes in a repository
}
```
* The path in julia.environmentPath  points to a Project.toml  and Manifest.toml 
* → they define the package environment for all subfolder inside the main folder. 