### A Pluto.jl notebook ###
# v0.11.12

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ a5c9d9ce-eedf-11ea-16b6-25a3f3ed0d94
begin 
	using PlutoUI
	using Plots
	using DelimitedFiles
end

# ╔═╡ 0a106c7c-eee0-11ea-08fb-2bdd107a2b37
md"""
# Linear regression example
"""

# ╔═╡ e1e78d16-eedf-11ea-2487-27200df8c37b
md"""
## Load in data and design matrix
Load in some files with `data`
"""

# ╔═╡ ac24ef98-eedf-11ea-350f-c7ba57933f4f
timecourse = readdlm("timecourse.txt", ',', Float64);

# ╔═╡ 62b69d12-eebb-11ea-0e95-f76fc676df26
design = readdlm("design-3.txt", ',', Float64);

# ╔═╡ 40766870-eee0-11ea-10aa-e5a1af2fab86
t = (0:167) * 1.5;

# ╔═╡ 558e2676-eee0-11ea-1266-d3f6512935bc
begin
	plot(t, timecourse, 
		line=(:black, 3, 0.8),
		xlabel="Time (s)",
		ylabel="fMRI response (au)",
		title="Timecourse from a visually responsive voxel");
end

# ╔═╡ 8b48bf96-efae-11ea-3297-71d8c256a4d2
δ = 16 # comment

# ╔═╡ 9b68a280-efac-11ea-2987-8f846be29e5d
md""" a $(@bind a Slider(-δ:1:δ))"""

# ╔═╡ 41334188-efae-11ea-1b02-fd31db5501fc
md""" b $(@bind b Slider(150:300))"""

# ╔═╡ 507dfe44-efae-11ea-1c67-89574aa0f00f
md""" c $(@bind c Slider(-δ:1:δ))"""

# ╔═╡ e2ddc8b0-efad-11ea-2aa2-0df6e084435d
[a,b,c]

# ╔═╡ 2a26b2ac-efb0-11ea-30eb-1f1ef0d44b45
md"""## Model and data"""

# ╔═╡ 4838ebe4-efaf-11ea-119c-2d37ff78893c
begin
    sse = sum((timecourse - design * [a;b;c]).^2)
	plot(t, timecourse, line=(:red, 2),
			axis=[0, 250, 100, 300],
				xlabel="Time (s)",
				ylabel="fMRI reponse (image intensity)",
			        title="sse $(round(sse))")
	plot!(t, design * [a;b;c], line=(:black, 2));

end

# ╔═╡ Cell order:
# ╟─0a106c7c-eee0-11ea-08fb-2bdd107a2b37
# ╠═a5c9d9ce-eedf-11ea-16b6-25a3f3ed0d94
# ╟─e1e78d16-eedf-11ea-2487-27200df8c37b
# ╠═ac24ef98-eedf-11ea-350f-c7ba57933f4f
# ╠═62b69d12-eebb-11ea-0e95-f76fc676df26
# ╠═40766870-eee0-11ea-10aa-e5a1af2fab86
# ╠═558e2676-eee0-11ea-1266-d3f6512935bc
# ╟─8b48bf96-efae-11ea-3297-71d8c256a4d2
# ╟─9b68a280-efac-11ea-2987-8f846be29e5d
# ╟─41334188-efae-11ea-1b02-fd31db5501fc
# ╟─507dfe44-efae-11ea-1c67-89574aa0f00f
# ╟─e2ddc8b0-efad-11ea-2aa2-0df6e084435d
# ╟─2a26b2ac-efb0-11ea-30eb-1f1ef0d44b45
# ╠═4838ebe4-efaf-11ea-119c-2d37ff78893c
