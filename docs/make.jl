# Use
#
# DOCUMENTER_DEBUG=true GKSwstype=100 julia --color=yes make.jl local [linkcheck]
#
# for local builds.

using Pkg
using Documenter
using Literate
using SolidStateDetectors

function fix_literate_output(content)
    content = replace(content, "EditURL = \"@__REPO_ROOT_URL__/\"" => "")
    return content
end

gen_content_dir = joinpath(@__DIR__, "src")
tut_out_fn = joinpath(@__DIR__, "..", "legend-julia-software-tutorial.jl")

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
    warnonly = ("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/legend-exp/legend-julia-tutorial.git",
    devbranch = "main",
    devurl = "main",
    forcepush = true,
    push_preview = true,
)
