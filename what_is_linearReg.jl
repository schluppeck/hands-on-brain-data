### A Pluto.jl notebook ###
# v0.12.6

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

# ╔═╡ 9bc349e8-efb0-11ea-1392-cd735828af33
# packaged loads, etc
begin
	using DelimitedFiles
	using NIfTI
	using Images
	using StatsBase
	using Plots
	using PlutoUI
	using Printf
	using LinearAlgebra
end

# ╔═╡ df5232e0-04e2-11eb-0c26-f19b9d9c7b14
begin
	using GLM
	using DataFrames
end


# ╔═╡ 8029070e-efb0-11ea-1d0a-7f402f2e9989


# ╔═╡ 4df55a88-f98a-11ea-1c9f-cd52a4b5062f
md"""
# How do we analyze data here? 

## General idea

What happens if I multiply each point in a timeseries by a number (or "weight", "multiplier", ...) ?
"""

# ╔═╡ c14bf31e-f98c-11ea-33d1-f5de8f2ad0c1
md"""
**weight:** $(@bind weight Slider(range(0.25, 3.0, step=0.25), default=0.75, show_value=true))
"""

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Load in that CSV file """

# ╔═╡ 368e2640-f8e0-11ea-1ddf-b37069ba7588
d, h = readdlm("data/stimulus_timing.csv", ',', Float64, header=true);

# ╔═╡ cac0339a-f8e4-11ea-0876-f91dc7db1454
md"""## Stimulus timing $\rightarrow$ fMRI response timing?

"""

# ╔═╡ 1058934e-f8e1-11ea-1896-35d75c4b6a8e
begin
    md"""
*Make a slider that controls the plot*
	
**row:** $(@bind whichRow Slider(1:2:size(d,1), default=1, show_value=true))
"""

	
end

# ╔═╡ c6cab78c-f836-11ea-2b5b-23f0006f8e93
begin
	plot(view(d, 1:whichRow,1), view(d,1:whichRow,2), xlabel="Time (volumes)",
		ylabel="fMRI response", label="$(h[2])", xlims=(0, 160), ylims=(-5, 5), lw=2)
	plot!(view(d, 1:whichRow,1), view(d,1:whichRow,3), 
		label="$(h[3])", xlims=(0, 160), ylims=(-5, 5), lw=3, color=:red)
	
	
end

# ╔═╡ da4ac85c-f8e4-11ea-192e-03d5b6862d5a
md"""## Scaling = multiplying"""

# ╔═╡ 1c3b6c56-f8e2-11ea-3969-f59871025c5e
begin
    md"""
How can we *scale* the idealised prediction to fit the data better? 
	
**multiplier:** $(@bind multiplier Slider(-10:0.5:10, default=1, show_value=true))
"""
end

# ╔═╡ ddf6018c-f921-11ea-0d74-c16f4f0b7426
md"""here I am plotting the data (blue line) and the prediction for what an "ideal" face-selective response would look like... and we can scale it"""

# ╔═╡ 39d465a6-f8e2-11ea-2d71-75cbe586428c
begin
	plot(d[:,1], d[:,5],
		xlim=(0, 160), ylim=(-5, 5), 
		xlabel="Time (volumes)",
	ylabel="fMRI response (%signal change)", label="data")
	plot!(d[:,1], d[:,3] * multiplier, lw=2, label="model * $(@sprintf "%.1f" multiplier )")
	
end

# ╔═╡ a1b031a4-fc08-11ea-2314-13e2e79c2ca3
md"""### Now: more than one component to fit"""

# ╔═╡ e6309486-fc08-11ea-3ade-c93a24b6866b
begin
	plot(d[:,1], d[:,3],
		xlim=(0, 160), ylim=(-1, 1), 
		xlabel="Time (volumes)",
		ylabel="fMRI response (%signal change)", 
		label="response (FACES)",
		color=:red, lw=2, layout=(2, 1), subplot=1)
	plot!(d[:,1], d[:,4], 
		color=:blue, lw=2,
		label="response (OBJECTS)", subplot=2,xlim=(0, 160), ylim=(-1, 1))
	
end

# ╔═╡ 9c3b0258-fc08-11ea-1922-fd1bec66b4ff
begin
    md"""
How can we *scale* the idealised prediction to fit the data better? 
	
**multiplier (faces):** $(@bind mf Slider(-10:0.5:10, default=1, show_value=true))

**multiplier (objects):** $(@bind mo Slider(-10:0.5:10, default=1, show_value=true))

"""
end

# ╔═╡ 975860d2-fc08-11ea-2def-ad1c45826911
begin
	plot(d[:,1], d[:,5],
		xlim=(0, 160), ylim=(-5, 5), 
		xlabel="Time (volumes)",
	ylabel="fMRI response (%signal change)", label="data")
	plot!(d[:,1], d[:,[3,4]] * [mf; mo], lw=2, label="model * $(@sprintf "%.1f" multiplier )")
	
end

# ╔═╡ e7fb832e-04e0-11eb-388d-f7520b672a6e
md"""

## Calculating the weights for the best fit

*Linear regression* can be used to find/calculate the weights that will give the **best** fit of the mixture of the two curves.


**Best** here means the settings that will result in the *least squares fit*, the fit that makes the *sum of squared errors* between each measurement in the timeseries ($\text{data}_i$) and the corresponding model description ($\text{model}_i$) smallest.

$\sum_i (\text{data}_i - \text{model}_i)^2$

"""

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

# ╔═╡ cc5dcb6e-1d5f-11eb-0be7-57d4795af804


# ╔═╡ cb65baa0-1d5f-11eb-346f-bdb3a85d0fe7


# ╔═╡ ca5b1768-1d5f-11eb-0459-13e4d2de80c7


# ╔═╡ c3899100-04e4-11eb-37aa-394d3f60bd53
import Pkg; Pkg.add("StatsPlots") 

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

# ╔═╡ 778800f8-f98a-11ea-1b87-1108f500ad5f
begin
	t = 0:1:(nPoints - 1);
	y = weight .* t;
	
	plot(t,y, lw=2, color=:red,
		aspect_ratio=1, 
		xlims=(0, 15), ylims=(0, 15),
		label="fit curve")
	plot!(t,1.25.*t, seriestype=:scatter, marker=:square, ms=5, color=:black, label=:"data points")

end

# ╔═╡ f6e4754c-f98b-11ea-2a42-034d82f52ca1
addNoise = 0.5 .* randn(nPoints);

# ╔═╡ Cell order:
# ╟─9bc349e8-efb0-11ea-1392-cd735828af33
# ╟─8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╟─4df55a88-f98a-11ea-1c9f-cd52a4b5062f
# ╟─778800f8-f98a-11ea-1b87-1108f500ad5f
# ╟─c14bf31e-f98c-11ea-33d1-f5de8f2ad0c1
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╠═368e2640-f8e0-11ea-1ddf-b37069ba7588
# ╟─cac0339a-f8e4-11ea-0876-f91dc7db1454
# ╟─1058934e-f8e1-11ea-1896-35d75c4b6a8e
# ╟─c6cab78c-f836-11ea-2b5b-23f0006f8e93
# ╟─da4ac85c-f8e4-11ea-192e-03d5b6862d5a
# ╟─1c3b6c56-f8e2-11ea-3969-f59871025c5e
# ╟─ddf6018c-f921-11ea-0d74-c16f4f0b7426
# ╟─39d465a6-f8e2-11ea-2d71-75cbe586428c
# ╟─a1b031a4-fc08-11ea-2314-13e2e79c2ca3
# ╟─e6309486-fc08-11ea-3ade-c93a24b6866b
# ╟─9c3b0258-fc08-11ea-1922-fd1bec66b4ff
# ╠═975860d2-fc08-11ea-2def-ad1c45826911
# ╟─e7fb832e-04e0-11eb-388d-f7520b672a6e
# ╠═2b070720-04e2-11eb-3101-cbc40b17682b
# ╟─4b968440-04e2-11eb-35ce-5f050dcd4b6b
# ╟─6464f806-04e2-11eb-37cc-7363fa76c80e
# ╟─df5232e0-04e2-11eb-0c26-f19b9d9c7b14
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
# ╟─cc5dcb6e-1d5f-11eb-0be7-57d4795af804
# ╟─cb65baa0-1d5f-11eb-346f-bdb3a85d0fe7
# ╟─ca5b1768-1d5f-11eb-0459-13e4d2de80c7
# ╟─c3899100-04e4-11eb-37aa-394d3f60bd53
# ╟─d5c0b236-f98b-11ea-0444-6fe340642707
# ╟─79d08b08-fa8b-11ea-0b4b-01ceef03660a
# ╟─58c63ca8-fa8b-11ea-296d-0b7f613e8976
# ╠═96844d74-fa87-11ea-0966-89bbbc8a4353
# ╟─bfdd7d56-f98a-11ea-3064-a9033ba994a5
# ╠═eda9e2dc-f98b-11ea-3eca-539ac938107c
# ╠═f6e4754c-f98b-11ea-2a42-034d82f52ca1
