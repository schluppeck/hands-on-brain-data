### A Pluto.jl notebook ###
# v0.12.4

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
# packageloads, etc
begin
	using DelimitedFiles
	using NIfTI
	using Images
	using ImageView
	using FileIO
	using StatsBase
	using Plots
	using PlutoUI
	using Printf
	using LinearAlgebra
	md"""[some setup / package includes...] """
end

# ╔═╡ 4df55a88-f98a-11ea-1c9f-cd52a4b5062f

md"""

# What happens in an fMRI experiment

## General idea

- some images are being displayed to a participant
- the visual part of their brain works harder (trying to process information)
- neural $\rightarrow$ haemodynamic changes

"""

# ╔═╡ f151a60e-016f-11eb-3ab4-bd2c5adbd801
md"""set up some image loading..."""

# ╔═╡ a1a5f0ee-016f-11eb-22bc-d965805be7f0
face_dir = "./stims/multiracial/frontal/";

# ╔═╡ b36f1e5c-016f-11eb-3f9e-f39becc598c6
faceImages = readdir(face_dir);

# ╔═╡ 80dc039a-0191-11eb-1792-352eabf32591
object_dir = "./stims/objects/";

# ╔═╡ 940859e4-0191-11eb-0a64-bfc069e803d8
objectImages = readdir(object_dir);

# ╔═╡ 9af0d01c-1488-11eb-159d-c72e4cffaa22
md"""Some parameters that define the timing of the block design experiment"""

# ╔═╡ af8bd0d4-0190-11eb-1f8f-7368cd387053
nA = 8

# ╔═╡ b6cc5c4c-0190-11eb-00fc-1ddd56445030
nGray = 8

# ╔═╡ b951cf10-0190-11eb-31fe-0beb75cc6f3e
nRepeats = 5

# ╔═╡ bddcdeac-0191-11eb-061e-b75875bc5b7a
nDynamics = 2*(nA+nGray)*nRepeats

# ╔═╡ 3488c298-0190-11eb-03ef-cf178151e777
begin
	timing = repeat([[repeat(["gray"], nGray, 1); repeat(["face"], nA, 1)];
					  repeat(["gray"], nGray, 1); repeat(["object"], nA, 1)], 							nRepeats, 1);
	md"""
	Define a timing vector with $( nDynamics ) dynamics.
	
	This is done by repeating `["gray"]` $nGray times, then `["face"]` $nA times, the same for `["object"]` and repeating those $nRepeats times.
	
	"""
end

# ╔═╡ ae0fe97e-0194-11eb-2c80-41c90b26ee5c
md"""
## Run a sped-up version of the experiment

We can bind a value that changes every "tick" using a `Clock` function... to make sure we don't keep going beyond the length of the dataset ($nDynamics), we wrap around using the `mod`ulo.

"""

# ╔═╡ 19252aa4-0105-11eb-0b5c-5f3769240354
md"""Step through time: each **tick** is a **volume** in the fMRI experiment"""

# ╔═╡ e4c0f9f6-01cb-11eb-111f-b774df6174bb
md"""Show stimulus timing w/ data? $(@bind showStimTiming CheckBox())

If this checkbox is ticked, then display an image from the corresponding block"""

# ╔═╡ a54017da-0194-11eb-309c-415dd99b4db1
@bind t Clock(0.5)

# ╔═╡ 28ec2008-0193-11eb-1ca6-afde7ea782a1
theVolume = mod(t-1, nDynamics) + 1;

# ╔═╡ 778800f8-f98a-11ea-1b87-1108f500ad5f
begin
	# this does image loading from disk - not that fast, but good enough for here.
	if showStimTiming
		# might be one off? think through this bit more.
		if timing[theVolume] == "face"
			ex = load(string(face_dir, rand(faceImages)))
		elseif timing[theVolume] == "object"
			ex = load(string(object_dir, rand(objectImages)))
		else
			ex = Gray.(repeat([0.5], 250, 250))
		end
	end
end

# ╔═╡ c4c00586-01ce-11eb-0625-17b9ab6bfa8f
md"""Show face response w/ data? $(@bind showResponseTimingF CheckBox())

Show object response w/ data? $(@bind showResponseTimingO CheckBox())
"""

# ╔═╡ cefe27e4-03e0-11eb-0478-674a7e1ae6e9
#md"""logical indeces of "face" and "object" events"""

# ╔═╡ d27ceec0-01ca-11eb-3152-7d7603d6546a
fStim = timing .== "face" ;

# ╔═╡ b2df1378-01cb-11eb-01fd-4d9da6872e9b
oStim = timing .== "object" ;

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Load in that CSV file """

# ╔═╡ 368e2640-f8e0-11ea-1ddf-b37069ba7588
d, h= readdlm("data/stimulus_timing.csv", ',', Float64, header = true )

# ╔═╡ 5bb7ed88-0106-11eb-2181-d123e1a1cc31
begin
	data_x = view(d, 1:theVolume, 1)
	data_y = view(d, 1:theVolume, 5)
	
	face_offset = 3.2 # shift down to see!
	object_offset = 4.5
	
	face_pred = view(d, 1:theVolume, 3) .- face_offset
	object_pred = view(d, 1:theVolume, 4) .- object_offset
	

	plot(data_x, data_y,
		lw=2, c=:black,
		xlim=(0,160), ylim=(-5, 5), 
		xlabel="Time (volumes)",
		ylabel="fMRI response (%signal change)", 
		label="data")	
	
	if showResponseTimingF
		plot!(data_x, face_pred,
		lw=2,
		c=:red,
		label="face timing")	
	end
	
	if showResponseTimingO
		plot!(data_x, object_pred,
			c=:blue,
			lw=2,		
			label="object timing")	
	end
	
	plot!([d[theVolume,1]], [d[theVolume,5]], seriescolor=:black, 
		m=:circle, ms=7, label="")

end

# ╔═╡ d5c0b236-f98b-11ea-0444-6fe340642707
md"""

## Some settings and helper functions

"""

# ╔═╡ bfdd7d56-f98a-11ea-3064-a9033ba994a5
# choose which plotting backend to use.
# plotly() is dynamic / webbased
# gr() make nice static plots

#plotly()
gr()

# ╔═╡ eda9e2dc-f98b-11ea-3eca-539ac938107c
nPoints = 20; # number of points in plot above (not used)

# ╔═╡ f6e4754c-f98b-11ea-2a42-034d82f52ca1
addNoise = 0.5 .* randn(nPoints);

# ╔═╡ Cell order:
# ╠═9bc349e8-efb0-11ea-1392-cd735828af33
# ╟─4df55a88-f98a-11ea-1c9f-cd52a4b5062f
# ╟─f151a60e-016f-11eb-3ab4-bd2c5adbd801
# ╠═a1a5f0ee-016f-11eb-22bc-d965805be7f0
# ╠═b36f1e5c-016f-11eb-3f9e-f39becc598c6
# ╠═80dc039a-0191-11eb-1792-352eabf32591
# ╠═940859e4-0191-11eb-0a64-bfc069e803d8
# ╟─9af0d01c-1488-11eb-159d-c72e4cffaa22
# ╟─af8bd0d4-0190-11eb-1f8f-7368cd387053
# ╟─b6cc5c4c-0190-11eb-00fc-1ddd56445030
# ╟─b951cf10-0190-11eb-31fe-0beb75cc6f3e
# ╟─bddcdeac-0191-11eb-061e-b75875bc5b7a
# ╟─3488c298-0190-11eb-03ef-cf178151e777
# ╟─ae0fe97e-0194-11eb-2c80-41c90b26ee5c
# ╠═28ec2008-0193-11eb-1ca6-afde7ea782a1
# ╟─19252aa4-0105-11eb-0b5c-5f3769240354
# ╟─e4c0f9f6-01cb-11eb-111f-b774df6174bb
# ╟─778800f8-f98a-11ea-1b87-1108f500ad5f
# ╠═a54017da-0194-11eb-309c-415dd99b4db1
# ╟─c4c00586-01ce-11eb-0625-17b9ab6bfa8f
# ╠═5bb7ed88-0106-11eb-2181-d123e1a1cc31
# ╟─cefe27e4-03e0-11eb-0478-674a7e1ae6e9
# ╟─d27ceec0-01ca-11eb-3152-7d7603d6546a
# ╠═b2df1378-01cb-11eb-01fd-4d9da6872e9b
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╠═368e2640-f8e0-11ea-1ddf-b37069ba7588
# ╟─d5c0b236-f98b-11ea-0444-6fe340642707
# ╠═bfdd7d56-f98a-11ea-3064-a9033ba994a5
# ╠═eda9e2dc-f98b-11ea-3eca-539ac938107c
# ╟─f6e4754c-f98b-11ea-2a42-034d82f52ca1
