### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ cbffc46e-9824-4c06-ab70-9b47bbcc7828
begin
	import Pkg
	Pkg.activate(".")
end

# ╔═╡ 9bc349e8-efb0-11ea-1392-cd735828af33
# packaged loads, etc
begin
	using DelimitedFiles
	using StatsBase
	using Plots
	using PlutoUI
	using Printf
	using LinearAlgebra
	using DataFrames
	using GLM
end

# ╔═╡ 4df55a88-f98a-11ea-1c9f-cd52a4b5062f
md"""
# How does the error change...

## General idea

In linear regression, we are trying to find the *best* weights that go along with te explantory variable. What happens to the (sum of squared) errors for different values of the weights?
"""

# ╔═╡ da4ac85c-f8e4-11ea-192e-03d5b6862d5a
md"""## Scaling = multiplying

Example for one parameter and a single parameter for e.g. fitting a line

"""

# ╔═╡ b0d721f4-8fdd-4fa2-a5ff-a97cd869e1a4
begin
	minx, maxx = 0,10
	noiseScaleFac = 3
	linex = rand(range(minx, maxx; length=20), 20)
	liney = 3.2 .* linex + noiseScaleFac .* randn(size(linex))
end

# ╔═╡ 2be2e67c-a499-460c-a9b0-93c6c6aae924
md""" setting the weight W $(@bind W  Slider(0:0.1:8; default=0.5, show_value = true)) """

# ╔═╡ 4009530d-2ed3-406e-b8cc-6f027fa925c4
	begin
		thex = range(minx, maxx; length = 50)
		they = W .* thex
		thew = collect(range(-5, 5; length=100))
	end

# ╔═╡ 9f7ad275-0c07-4d33-af81-00a0aa323ca5
begin
	themodel = W.* linex
	res = liney - themodel
	SSE = sum(res.^2)

	theModel = linex * thew'
	#theResiduals = theModel .- they
	
	p1 = plot(linex, liney;  seriestype = :scatter, ms = 8, 
		color="red", size=(300,300), xlims= (minx, maxx), ylims = (0,40),
		xlabel="x", ylabel="some y", label=:none)
	#yaxis!(p1, limits = (0, 5))
	plot!(p1, thex, they; color=:magenta, lw=2, label=:none)
	p2 = plot(0:.1:8, [sum( (liney .- b.*linex).^2 ) for b in 0:.1:8 ], color="black", label=:none)
	plot!([W], [SSE];  seriestype = :scatter, ms = 8, 
		color="red", label="", size=(300,300), xlims = (-3, 8), ylims = (-200, 3000),
		xlabel = "weight", ylabel = "Sum of (error)^2")
	vline!([W]; color=:magenta, lw=2, ls=:dash, label=:none)
	
	
	plot(p1, p2, size=(700,300))

end

# ╔═╡ f374882f-de84-4291-8918-b12a563a9931
md"""## now with fMRI data """

# ╔═╡ ddf6018c-f921-11ea-0d74-c16f4f0b7426
md"""here I am plotting the data (blue line) and the prediction for what an "ideal" face-selective response would look like... and we can scale it"""

# ╔═╡ a1b031a4-fc08-11ea-2314-13e2e79c2ca3
md"""### Now: more than one component to fit"""

# ╔═╡ 9c3b0258-fc08-11ea-1922-fd1bec66b4ff
begin
    md"""
How can we *scale* the idealised prediction to fit the data better? 
	
**multiplier (faces):** $(@bind mf Slider(-10:0.5:10, default=1, show_value=true))

**multiplier (objects):** $(@bind mo Slider(-10:0.5:10, default=1, show_value=true))

"""
end

# ╔═╡ e7fb832e-04e0-11eb-388d-f7520b672a6e
md"""

## Calculating the weights for the best fit

*Linear regression* can be used to find/calculate the weights that will give the **best** fit of the mixture of the two curves.


**Best** here means the settings that will result in the *least squares fit*, the fit that makes the *sum of squared errors* between each measurement in the timeseries ($\text{data}_i$) and the corresponding model description ($\text{model}_i$) smallest.

$\sum_i (\text{data}_i - \text{model}_i)^2$

"""

# ╔═╡ 8fdb1797-0430-421c-97f8-53aca23fc9e1
d, h = readdlm("data/stimulus_timing.csv", ',', Float64, header=true);

# ╔═╡ 975860d2-fc08-11ea-2def-ad1c45826911
begin
	plot(d[:,1], d[:,5],
		xlim=(0, 160), ylim=(-5, 5), 
		xlabel="Time (volumes)",
	ylabel="fMRI response (%signal change)", label="data")
	plot!(d[:,1], d[:,[3,4]] * [mf; mo], lw=2, label="model * $(@sprintf "%.1f, %.1f" mf mo )")
	
end

# ╔═╡ 2b070720-04e2-11eb-3101-cbc40b17682b
# X, the design matrix
designMatrix = d[:,3:4]

# ╔═╡ 4b968440-04e2-11eb-35ce-5f050dcd4b6b
y_1 = d[:,5] #

# ╔═╡ 6464f806-04e2-11eb-37cc-7363fa76c80e
β_1 = designMatrix \ y_1

# ╔═╡ 111aea9a-04e5-11eb-066d-4d245b04dc5e
md"""
##

turn data into a `dataframe` and use `GLM` module to get a linear model fit

"""

# ╔═╡ 1e370abc-04e3-11eb-064a-21fbb9fafc7c
theData = DataFrame(d[:, 3:6], [:face_response, :object_response, :Voxel1, :Voxel2 ])

# ╔═╡ 1d60545a-04e4-11eb-1720-b5f04c5da239
ols1 = lm(@formula(Voxel1 ~ face_response + object_response), theData)

# ╔═╡ 86d10676-04e4-11eb-2121-2f0c8945cc1a
coefnames(ols1)

# ╔═╡ 979732dc-04e4-11eb-3803-7302dc91e777
coef(ols1)

# ╔═╡ a33a18f2-04e4-11eb-0587-6117c036c641
GLM.confint(ols1)

# ╔═╡ c60d9136-1d5f-11eb-0839-d760afb98985


# ╔═╡ c47f840a-1d5f-11eb-1e88-d3835fa021e3


# ╔═╡ aa954778-1d5f-11eb-00bf-034690d40e94
md"""## Plot using the `calculated` weights"""

# ╔═╡ 5d60ed36-1d5f-11eb-3e90-9315dd9bc07a
begin
	plot(d[:,1], d[:,5],
		xlim=(0, 160), ylim=(-5, 5), 
		xlabel="Time (volumes)",
	ylabel="fMRI response (%signal change)", label="data")
	plot!(d[:,1], d[:,[3,4]] * coef(ols1)[2:3], lw=2, label="model * [$(@sprintf "%.2f; %.2f" coef(ols1)[2] coef(ols1)[3] )]")
	
end

# ╔═╡ ca5b1768-1d5f-11eb-0459-13e4d2de80c7
md"""


"""

# ╔═╡ d5c0b236-f98b-11ea-0444-6fe340642707
md"""

## Some settings and helper functions

"""

# ╔═╡ 79d08b08-fa8b-11ea-0b4b-01ceef03660a
# calculate sum of squared errors for different betas
begin
	
	betaVals = -10:0.5:10 ;# range(-10, 10, length=nPoints)
	e = zeros(size(betaVals))
	X = Vector(d[:,3])
	theY = Vector(d[:,5])
	for (i, theB) in enumerate(betaVals)
		evec = X * theB .- theY 
		e[i] = transpose(evec) * evec
	end
	# e
	md"""calculate squared errors"""
end

# ╔═╡ 58c63ca8-fa8b-11ea-296d-0b7f613e8976
begin
	# plot error curve and current choice of M
    function plotError(betas, es, currentM, subplotNum)
	plot!(betas, es, lw=2, color=:black, 
		label="error", subplot=subplotNum,)
	idx = betas .== currentM
	if es[idx]... ≈ minimum(es)
		theColor = :green
		theLabel = "min SSE"
	else
		theColor = :red
		theLabel = "SSE"

	end
	plot!(betas[idx], es[idx], 
		marker=:circle, 
		ms=10, 
		color=theColor,
		subplot=subplotNum,
		xlabel="β value",
		ylabel="SSE",
		label=theLabel)
    end
	md"""a function that plots error for a given choice of m `plotError` """
end


# ╔═╡ 96844d74-fa87-11ea-0966-89bbbc8a4353
begin
    function plotWithBeta(xData, yData, yModel, m)
	l = @layout [ grid(2, 1) a{0.30w} 
					 ]
	plot(xData, yData,
		xlim=(0, 160), ylim=(-5, 5), 
		ylabel="fMRI response (%change)", 
		label="data", 
		layout=l,
	subplot=1)
	plot!(xData, yModel * m, lw=2,
		subplot=1,
		label="model * $(@sprintf "%.1f" m )")
	sticks!(xData, yData .- yModel * m,
			color=:gray,
			label="data-model",
				xlabel="Time (volumes)",
		subplot=2, 
	xlim=(0, 160), ylim=(-5, 5))
	
	
	
	# betaVals from other cell
	# ditto for e
	plotError(betaVals, e, m, 3)
    end
	md"""a function that plots data + model with a 
	particular choice of m `plotWithBeta` """
end

# ╔═╡ bfdd7d56-f98a-11ea-3064-a9033ba994a5
# plotly()
gr()

# ╔═╡ eda9e2dc-f98b-11ea-3eca-539ac938107c
nPoints = 20; # number of points in plot above (not used)

# ╔═╡ f6e4754c-f98b-11ea-2a42-034d82f52ca1
addNoise = 0.5 .* randn(nPoints);

# ╔═╡ Cell order:
# ╟─cbffc46e-9824-4c06-ab70-9b47bbcc7828
# ╟─9bc349e8-efb0-11ea-1392-cd735828af33
# ╟─4df55a88-f98a-11ea-1c9f-cd52a4b5062f
# ╟─da4ac85c-f8e4-11ea-192e-03d5b6862d5a
# ╟─4009530d-2ed3-406e-b8cc-6f027fa925c4
# ╟─9f7ad275-0c07-4d33-af81-00a0aa323ca5
# ╟─b0d721f4-8fdd-4fa2-a5ff-a97cd869e1a4
# ╟─2be2e67c-a499-460c-a9b0-93c6c6aae924
# ╟─f374882f-de84-4291-8918-b12a563a9931
# ╟─ddf6018c-f921-11ea-0d74-c16f4f0b7426
# ╟─a1b031a4-fc08-11ea-2314-13e2e79c2ca3
# ╟─9c3b0258-fc08-11ea-1922-fd1bec66b4ff
# ╟─975860d2-fc08-11ea-2def-ad1c45826911
# ╟─e7fb832e-04e0-11eb-388d-f7520b672a6e
# ╠═2b070720-04e2-11eb-3101-cbc40b17682b
# ╟─4b968440-04e2-11eb-35ce-5f050dcd4b6b
# ╟─6464f806-04e2-11eb-37cc-7363fa76c80e
# ╠═8fdb1797-0430-421c-97f8-53aca23fc9e1
# ╟─111aea9a-04e5-11eb-066d-4d245b04dc5e
# ╟─1e370abc-04e3-11eb-064a-21fbb9fafc7c
# ╠═1d60545a-04e4-11eb-1720-b5f04c5da239
# ╠═86d10676-04e4-11eb-2121-2f0c8945cc1a
# ╠═979732dc-04e4-11eb-3803-7302dc91e777
# ╟─a33a18f2-04e4-11eb-0587-6117c036c641
# ╟─c60d9136-1d5f-11eb-0839-d760afb98985
# ╟─c47f840a-1d5f-11eb-1e88-d3835fa021e3
# ╟─aa954778-1d5f-11eb-00bf-034690d40e94
# ╟─5d60ed36-1d5f-11eb-3e90-9315dd9bc07a
# ╟─ca5b1768-1d5f-11eb-0459-13e4d2de80c7
# ╟─d5c0b236-f98b-11ea-0444-6fe340642707
# ╟─79d08b08-fa8b-11ea-0b4b-01ceef03660a
# ╟─58c63ca8-fa8b-11ea-296d-0b7f613e8976
# ╟─96844d74-fa87-11ea-0966-89bbbc8a4353
# ╟─bfdd7d56-f98a-11ea-3064-a9033ba994a5
# ╠═eda9e2dc-f98b-11ea-3eca-539ac938107c
# ╠═f6e4754c-f98b-11ea-2a42-034d82f52ca1
