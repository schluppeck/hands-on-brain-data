### A Pluto.jl notebook ###
# v0.12.7

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
	using ImageView
	using StatsBase
	using Plots
	using PlutoUI
	using Printf
	using LinearAlgebra
	using CSV
end

# ╔═╡ df5232e0-04e2-11eb-0c26-f19b9d9c7b14
begin
	using GLM
	using DataFrames
end


# ╔═╡ 8029070e-efb0-11ea-1d0a-7f402f2e9989
md"""# Images for moodle quiz """

# ╔═╡ 4df55a88-f98a-11ea-1c9f-cd52a4b5062f
md"""## General idea

Set of N different plots with voxel timecourses that look
"""

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Load in data """

# ╔═╡ 368e2640-f8e0-11ea-1ddf-b37069ba7588
d, h= readdlm("data/stimulus_timing.csv", ',', Float64, header = true )

# ╔═╡ 51594b8e-0741-11eb-0c03-338b971e945f
df = DataFrame(d,[h...]) # read as dataframe

# ╔═╡ bf362532-0741-11eb-137e-67c2924f4f92
fmri_data = niread("data/filtered_func_data.nii");


# ╔═╡ db903b82-0741-11eb-2df7-0dcebbb93c01
# this is how you get the header info!
fmri_data.header

# ╔═╡ 19bc9784-0742-11eb-18a4-edca29549ab4


# ╔═╡ cac0339a-f8e4-11ea-0876-f91dc7db1454
md"""## Have a quick look through data"""

# ╔═╡ 1058934e-f8e1-11ea-1896-35d75c4b6a8e
begin
md"""
*Make a slider that controls which column to plot*
	
**column:** $(@bind whichCol Slider(2:size(d,2), default=2, show_value=true))
"""
end

# ╔═╡ c6cab78c-f836-11ea-2b5b-23f0006f8e93
begin
	plot(d[:,1], d[:,whichCol], xlabel="Time (volumes)",
		ylabel="fMRI response", label="$(h[whichCol])", xlims=(0,160), ylims=(-5,5))
end

# ╔═╡ da4ac85c-f8e4-11ea-192e-03d5b6862d5a
md"""## Scaling = multiplying"""

# ╔═╡ 39d465a6-f8e2-11ea-2d71-75cbe586428c
function plotAtCoords(theData, theX, theY, theZ)
	p = plot(
		plot(1:160, view(theData,theX, theY, theZ, :),
		xlim=(0,160),
			c=:black,
			lw=2,
			grid_lw = 1,
		xlabel="Time (volumes)",
		ylabel="fMRI response (%signal change)", 
			xticks=0:16:160,
			xminorticks=2,
			label=string("data at [$theX, $theY, $theZ]"))
		)
	p
end

# ╔═╡ a233a2e4-07c7-11eb-07d1-5561b4cc64b2
function plotWithStimuli(fmri_data, xs, ys, zs)
	p = plotAtCoords(fmri_data, xs, ys, zs)
	plot(p)
	xdiff = 16
	
	xtloc1 = xdiff.+(0:32:144)
	xtloc2 = xdiff.+(16:32:160)
	
	yl = ylims()
	ydiff = (yl[2]-yl[1])./40 
	ann = [ (xtloc1, yl[1]+ydiff, Plots.text("face", 10, :red, :right, :bottom )),
			(xtloc2, yl[1]+ydiff, Plots.text("obj", 10, :blue, :right, :bottom ))]
		
	plot!(; annotation=ann)
	#annotate!([(0, 20, Plots.text("this is #5", 16, :red, :center))])
	#annotate!(0, 20, "bla") #GR.annotate!(0, 20, "my text", :color)
end


# ╔═╡ 1c3b6c56-f8e2-11ea-3969-f59871025c5e
begin
	sz = convert.(Int64,size(fmri_data).//2)
md"""
How can we *scale* the idealised prediction to fit the data better? 
	
**x:** $(@bind xs Slider(1:size(fmri_data,1), default=sz[1], show_value=true))

**y:** $(@bind ys Slider(1:size(fmri_data,2), default=sz[2], show_value=true))
	
**z:** $(@bind zs Slider(1:size(fmri_data,3), default=1, show_value=true))
	
	"""
end

# ╔═╡ 45e986f0-074c-11eb-0d49-dbce692ade1a
begin
	heatmap(view(fmri_data, :, :, zs, 1), 
		aspect_ratio=1,
		c=:greys, colorbar=:none)
	xaxis!(showaxis=:no)
	plot!([xs], [ys], m=:square,
		msw=4, msc=:red, ms=4, c=:red)
end

# ╔═╡ 665f1302-07b8-11eb-0848-8fb424cae65c
p = plotAtCoords(fmri_data, xs, ys, zs)

# ╔═╡ 2522ee1a-07ca-11eb-1d15-5f6b9e8f3aa6
illustration = plotWithStimuli(fmri_data, xs, ys, zs)

# ╔═╡ bae1b4e6-07ae-11eb-1fb9-c56c0cf7298a
md""" 
$(@bind fileroot TextField(;default="testfile"))

$(@bind test Button("clicked"))
"""

# ╔═╡ e8716624-07b8-11eb-0219-81e10bd83100
filename = @sprintf("%s%+02d%+02d%+02d.pdf", fileroot, xs, ys, zs)

# ╔═╡ fe67814c-2299-11eb-2080-79f06d510355
save(filename, illustration)

# ╔═╡ 5176ef4e-07ba-11eb-09e7-9b6894fcc592
begin
	test
	allFilenames = [];
	for (xx,yy,zz) in [(18,14,4), (17,13,4), (19,9,4), (22,23,2), (20,21,2), (40,17,2), (36,1,5),(46,11,1),(19,11,2)] 
		sfilename = @sprintf("%s%+02d%+02d%+02d.pdf", fileroot, xx+1, yy+1, zz+1)
		#q = plotAtCoords(fmri_data, xx+1, yy+1, zz+1)
		q = plotWithStimuli(fmri_data, xx+1, yy+1, zz+1)
		save(sfilename, q)
		append!(allFilenames, [sfilename])
	end
	with_terminal(print, allFilenames)
	
end

# ╔═╡ 63820b34-07af-11eb-21c3-75356e38ec43
begin
	test
	save(filename, p)
	md""" because `test` hooked up to `Button` this is reactive, **$(filename)**"""
end

# ╔═╡ 417c2dba-07b1-11eb-18cc-61d23caecbc6
rand(1:9999, 1,1)

# ╔═╡ 7e11e66e-07b3-11eb-1186-fba413764c97
with_terminal(dump, [1,2,[3,4]])

# ╔═╡ 7c2633f6-2297-11eb-16f1-7b4f1b1a283c
# 4 each for now F, O, Both / NB coords here in FSL 0-indexed form!, filenames will be 1-indexd!
begin
quizVoxels = [
	(17,13,4), 
	(18,14,5), 
	(18,8,4), 
	(18,14,4),
	
	(40,20,3),
	(40,19,2),
	(22,23,2),
	(40,17,1),
	
	(36,10,1),
	(37,9,1),
	(37,9,2),
	(25,7,2)];

	quizVoxels3 = quizVoxels[[12,1,6]]
end



# ╔═╡ 6a1c2364-2297-11eb-36b5-7f100ff97687
# for the 2020/21 lab report:
begin
	allFilenamesAssess = [];
	for (xx,yy,zz) in quizVoxels 
		sfilename = @sprintf("%s%+02d%+02d%+02d.pdf", fileroot, xx+1, yy+1, zz+1)
		#q = plotAtCoords(fmri_data, xx+1, yy+1, zz+1)
		q = plotWithStimuli(fmri_data, xx+1, yy+1, zz+1)
		save(sfilename, q)
		append!(allFilenamesAssess, [sfilename])
	end
	with_terminal(print, allFilenamesAssess)
	
end


# ╔═╡ 7d28a38a-229a-11eb-2cec-2153fbbe4e63
# for the 2020/21 lab report:
begin
	if true
	allFilenamesCSV = [];
	for (xx,yy,zz) in quizVoxels3 show
		with_terminal(print, (xx,yy,zz))
		sfilename = @sprintf("%s%+02d%+02d%+02d.csv", "lab-report" , xx+1, yy+1, zz+1)
		# writeVoxelDataToFile(fmri_data, xx+1, yy+1, zz+1, sfilename)
		append!(allFilenamesCSV, [sfilename])
	end
	with_terminal(print, allFilenamesCSV)
	end
	
end


# ╔═╡ 946112fc-229b-11eb-3027-bd10d12cb59b
normalizeTimecourse = function(tc)
	tc = 100.0 .* (tc./mean(tc) .- 1)
end


# ╔═╡ 32372d56-22c7-11eb-0923-4db4ed166e26
@bind quizPlot Slider(1:12, show_value=true)

# ╔═╡ 47b7c70c-229b-11eb-303a-41674232ea90
begin
	tm = normalizeTimecourse(fmri_data[1 .+ quizVoxels[quizPlot]...,:])
	plot(tm, label="quiz: $quizPlot, $(1 .+ quizVoxels[quizPlot])")
end

# ╔═╡ da7f81ca-229a-11eb-138f-43dd54c21ad5
writeVoxelDataToFile = function(fmri_data, xx, yy, zz, sfilename)

	t = [collect(0.0:159.0).*1., normalizeTimecourse( fmri_data[xx+1, yy+1, zz+1,:] ) ]
	df = DataFrame(t, [:Time_seconds, :fMRI_response])
	CSV.write(sfilename, df)
end
	

# ╔═╡ fc1de00a-229b-11eb-22f3-13b7f379ed7d
writeVoxelDataToFile(fmri_data, quizVoxels[1]..., "bla")

# ╔═╡ 2315ce8c-fb57-11ea-31a4-eb68d1d096d3
md""" ### Determining what fits best

Plot data, fit and errors together to understand what number `m` gives the best fit"""

# ╔═╡ d9f6c1e8-fa89-11ea-05b3-07daaa06326f
begin
md"""
How can we *scale* the idealised prediction to fit the data better? 
	
**multiplier:** $(@bind m Slider(-10:0.5:10, default=1, show_value=true))
"""
end

# ╔═╡ a1b031a4-fc08-11ea-2314-13e2e79c2ca3
md"""### Now: more than one component to fit"""

# ╔═╡ e6309486-fc08-11ea-3ade-c93a24b6866b
begin
	plot(d[:,1], d[:,3],
		xlim=(0,160), ylim=(-1, 1), 
		xlabel="Time (volumes)",
		ylabel="fMRI response (%signal change)", 
		label="response (FACES)",
		color=:red, lw = 2, layout = (2, 1), subplot=1)
	plot!(d[:,1], d[:,4], 
		color=:blue, lw = 2,
		label="response (OBJECTS)", subplot=2,xlim=(0,160), ylim=(-1, 1))
	
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
		xlim=(0,160), ylim=(-5, 5), 
		xlabel="Time (volumes)",
	ylabel="fMRI response (%signal change)", label="data")
	plot!(d[:,1], d[:,[3,4]]*[mf; mo], lw=2, 
		label="model * [w_1; w_2]")
	
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

# ╔═╡ 30b5258c-04e5-11eb-3cdc-11d36a2f35bc
html"""<br>"""

# ╔═╡ 111aea9a-04e5-11eb-066d-4d245b04dc5e
md"""
##

turn data into a `dataframe` and use `GLM` module to get a linear model fit

"""

# ╔═╡ 1e370abc-04e3-11eb-064a-21fbb9fafc7c
theData = DataFrame(d[:, 3:6], [:face_response, :object_response, :Voxel1, :Voxel2 ])

# ╔═╡ 1d60545a-04e4-11eb-1720-b5f04c5da239
ols1 = lm(@formula(Voxel1 ~ face_response + object_response), theData)

# ╔═╡ 67b724d0-04e4-11eb-1254-f59bf78b1345
ols2 = lm(@formula(Voxel2 ~ face_response + object_response), theData)

# ╔═╡ 86d10676-04e4-11eb-2121-2f0c8945cc1a
coefnames(ols1)

# ╔═╡ 979732dc-04e4-11eb-3803-7302dc91e777
coef(ols1)

# ╔═╡ a33a18f2-04e4-11eb-0587-6117c036c641
GLM.confint(ols1)

# ╔═╡ 31071f6a-081a-11eb-2eda-f99e2073028c


# ╔═╡ c3899100-04e4-11eb-37aa-394d3f60bd53
import Pkg; Pkg.add("StatsPlots") 

# ╔═╡ d5c0b236-f98b-11ea-0444-6fe340642707
md"""

## Some settings and helper functions

"""

# ╔═╡ 28cb2832-0748-11eb-0c14-832f1df303ca


# ╔═╡ 79d08b08-fa8b-11ea-0b4b-01ceef03660a
# calculate sum of squared errors for different betas
begin
	
	betaVals = -10:0.5:10 ;#range(-10, 10, length=nPoints)
	e = zeros(size(betaVals))
	X = Vector(d[:,3])
	theY = Vector(d[:,5])
	for (i, theB) in enumerate(betaVals)
		evec = X * theB .- theY 
		e[i] = transpose(evec)* evec
	end
	#e
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
		color= theColor,
		subplot=subplotNum,
		xlabel= "β value",
		ylabel = "SSE",
		label = theLabel)
end
	md"""a function that plots error for a given choice of m `plotError` """
end


# ╔═╡ 96844d74-fa87-11ea-0966-89bbbc8a4353
begin
function plotWithBeta(xData,yData,yModel, m)
	l = @layout [ grid(2,1) a{0.30w} 
					 ]
	plot(xData, yData,
		xlim=(0,160), ylim=(-5, 5), 
		ylabel="fMRI response (%change)", 
		label="data", 
		layout = l,
	subplot=1)
	plot!(xData, yModel*m, lw=2,
		subplot=1,
		label="model * $(@sprintf "%.1f" m )")
	sticks!(xData, yData .- yModel*m,
			color=:gray,
			label="data-model",
				xlabel="Time (volumes)",
		subplot=2, 
	xlim=(0,160), ylim=(-5, 5))
	
	
	
	# betaVals from other cell
	# ditto for e
	plotError(betaVals, e, m, 3)
end
	md"""a function that plots data + model with a 
	particular choice of m `plotWithBeta` """
end

# ╔═╡ bfdd7d56-f98a-11ea-3064-a9033ba994a5
#plotly()
gr()

# ╔═╡ eda9e2dc-f98b-11ea-3eca-539ac938107c
nPoints = 20; # number of points in plot above (not used)

# ╔═╡ f6e4754c-f98b-11ea-2a42-034d82f52ca1
addNoise = 0.5 .* randn(nPoints);

# ╔═╡ Cell order:
# ╠═8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╠═9bc349e8-efb0-11ea-1392-cd735828af33
# ╠═4df55a88-f98a-11ea-1c9f-cd52a4b5062f
# ╠═2b2f6be4-f07f-11ea-1459-775749ca949f
# ╠═368e2640-f8e0-11ea-1ddf-b37069ba7588
# ╠═51594b8e-0741-11eb-0c03-338b971e945f
# ╠═bf362532-0741-11eb-137e-67c2924f4f92
# ╠═db903b82-0741-11eb-2df7-0dcebbb93c01
# ╠═19bc9784-0742-11eb-18a4-edca29549ab4
# ╟─cac0339a-f8e4-11ea-0876-f91dc7db1454
# ╠═1058934e-f8e1-11ea-1896-35d75c4b6a8e
# ╟─c6cab78c-f836-11ea-2b5b-23f0006f8e93
# ╟─da4ac85c-f8e4-11ea-192e-03d5b6862d5a
# ╟─45e986f0-074c-11eb-0d49-dbce692ade1a
# ╠═665f1302-07b8-11eb-0848-8fb424cae65c
# ╠═a233a2e4-07c7-11eb-07d1-5561b4cc64b2
# ╠═39d465a6-f8e2-11ea-2d71-75cbe586428c
# ╠═2522ee1a-07ca-11eb-1d15-5f6b9e8f3aa6
# ╠═fe67814c-2299-11eb-2080-79f06d510355
# ╟─1c3b6c56-f8e2-11ea-3969-f59871025c5e
# ╟─bae1b4e6-07ae-11eb-1fb9-c56c0cf7298a
# ╠═e8716624-07b8-11eb-0219-81e10bd83100
# ╠═5176ef4e-07ba-11eb-09e7-9b6894fcc592
# ╟─63820b34-07af-11eb-21c3-75356e38ec43
# ╠═417c2dba-07b1-11eb-18cc-61d23caecbc6
# ╠═7e11e66e-07b3-11eb-1186-fba413764c97
# ╠═7c2633f6-2297-11eb-16f1-7b4f1b1a283c
# ╠═6a1c2364-2297-11eb-36b5-7f100ff97687
# ╠═7d28a38a-229a-11eb-2cec-2153fbbe4e63
# ╠═946112fc-229b-11eb-3027-bd10d12cb59b
# ╠═47b7c70c-229b-11eb-303a-41674232ea90
# ╠═32372d56-22c7-11eb-0923-4db4ed166e26
# ╠═da7f81ca-229a-11eb-138f-43dd54c21ad5
# ╠═fc1de00a-229b-11eb-22f3-13b7f379ed7d
# ╟─2315ce8c-fb57-11ea-31a4-eb68d1d096d3
# ╟─d9f6c1e8-fa89-11ea-05b3-07daaa06326f
# ╟─a1b031a4-fc08-11ea-2314-13e2e79c2ca3
# ╠═e6309486-fc08-11ea-3ade-c93a24b6866b
# ╠═9c3b0258-fc08-11ea-1922-fd1bec66b4ff
# ╠═975860d2-fc08-11ea-2def-ad1c45826911
# ╟─e7fb832e-04e0-11eb-388d-f7520b672a6e
# ╠═2b070720-04e2-11eb-3101-cbc40b17682b
# ╠═4b968440-04e2-11eb-35ce-5f050dcd4b6b
# ╠═6464f806-04e2-11eb-37cc-7363fa76c80e
# ╠═df5232e0-04e2-11eb-0c26-f19b9d9c7b14
# ╠═30b5258c-04e5-11eb-3cdc-11d36a2f35bc
# ╟─111aea9a-04e5-11eb-066d-4d245b04dc5e
# ╟─1e370abc-04e3-11eb-064a-21fbb9fafc7c
# ╠═1d60545a-04e4-11eb-1720-b5f04c5da239
# ╠═67b724d0-04e4-11eb-1254-f59bf78b1345
# ╠═86d10676-04e4-11eb-2121-2f0c8945cc1a
# ╠═979732dc-04e4-11eb-3803-7302dc91e777
# ╠═a33a18f2-04e4-11eb-0587-6117c036c641
# ╠═31071f6a-081a-11eb-2eda-f99e2073028c
# ╠═c3899100-04e4-11eb-37aa-394d3f60bd53
# ╠═d5c0b236-f98b-11ea-0444-6fe340642707
# ╠═28cb2832-0748-11eb-0c14-832f1df303ca
# ╟─79d08b08-fa8b-11ea-0b4b-01ceef03660a
# ╟─58c63ca8-fa8b-11ea-296d-0b7f613e8976
# ╟─96844d74-fa87-11ea-0966-89bbbc8a4353
# ╠═bfdd7d56-f98a-11ea-3064-a9033ba994a5
# ╠═eda9e2dc-f98b-11ea-3eca-539ac938107c
# ╠═f6e4754c-f98b-11ea-2a42-034d82f52ca1
