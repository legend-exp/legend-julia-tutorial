# Use
#
# DOCUMENTER_DEBUG=true GKSwstype=100 julia --color=yes make.jl local [linkcheck]
#
# for local builds.

using Pkg
using Weave
using Documenter
using Literate
using SolidStateDetectors

function fix_weave_output(file)
    lines = readlines(file)
    keep = true
    open(file, "w") do ids_file
        for line in lines
            if startswith(line, "#' <h1 style")
                keep = false
            elseif startswith(line, "#' <p>See")
                keep = true
            elseif keep
                if startswith(line, "#'")
                    println(ids_file, replace(line, "#'" => "#", count=1))
                elseif startswith(line, "#+")
                    println(ids_file, replace(line, "#+" => "#", count=1))
                else
                    println(ids_file, line)
                end
            end
        end
    end
end

function fix_literate_output(content)
    content = replace(content, "<unknown>/src/" => "")
    return content
end

gen_content_dir = joinpath(@__DIR__, "src")
tut_src_fn = joinpath(@__DIR__, "..", "legend-julia-software-tutorial.jmd")
tut_out_fn = joinpath(gen_content_dir, "legend-julia-software-tutorial.jl")
convert_doc(tut_src_fn, tut_out_fn)
fix_weave_output(tut_out_fn)

tut_basename = "legend-julia-software-tutorial"
Literate.markdown(tut_out_fn, gen_content_dir, name = tut_basename, documenter = true, credit = true, postprocess = fix_literate_output)

makedocs(
    sitename = "Legend Julia Software Tutorial",
    pages = [
        "Tutorial" => tut_basename*".md",
        "LICENSE" => "LICENSE.md",
    ],
    format = Documenter.HTML(canonical = "https://legend-exp.github.io/legend-julia-tutorial/stable/", prettyurls = !("local" in ARGS)),
    linkcheck = ("linkcheck" in ARGS),
    strict = !("local" in ARGS),
)

deploydocs(
    repo = "github.com/legend-exp/legend-julia-tutorial.git",
    devbranch = "main",
    devurl = "main",
    forcepush = true,
    push_preview = true,
)
