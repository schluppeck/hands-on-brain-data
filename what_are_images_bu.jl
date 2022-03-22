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
# packages to load etc
begin
	using DelimitedFiles
	using NIfTI
	using Images
	using ImageView
	using StatsBase
	using Plots
	using PlutoUI
	using Pipe
	md"""## loading packages...
	
	The notebook makes use of some existing functionality from other code which is stored in "packages" that you can install and use.
	
	"""
end

# ╔═╡ 8029070e-efb0-11ea-1d0a-7f402f2e9989
md"""# What are images 

A notebook with some details of how images are stored, how to display them in `Pluto,jl` using various tricks. Some of the main points here are:

- how image data is read in from a `NIfTI` file
- how we can *slice* through the data cube (3d, 4d) to get images and timeseries
- the idea of images as "grid" of numbers

"""

# ╔═╡ 46fbc1de-13d1-11eb-2553-71dfd823a5a0
md"""...loading in the contents of a file into a **variable** called `data` works as follows:"""

# ╔═╡ 141dde62-efb1-11ea-34df-cd5e838d8129
begin 
	# read data in from file
	data = NIfTI.niread("data/filtered_func_data.nii");
	# small technical point here: images are often stored in y,x,z 
	# order (rather thatn x,y,z... so could permute data here (mutable!)

	md"""
	Succesfully loaded a dataset that has **$(ndims(data)) dimensions** of size $(size(data))
	
	If we look at the table of numbers for one slice (slice #12) for one timepoint (volume = 3 in the below), it looks a bit like the following:
	"""
end

# ╔═╡ f0ef494e-f80c-11ea-1163-b954c1739162
view(data, :, :, 12, 3)

# ╔═╡ cdf28f06-1449-11eb-34b1-65a1fb83f330
md"""
## Displaying images

To look at the images, we can stich them together into one big *mosaic* and turn them into *grayscale* image that the browswer can display. To do this, we need to find out what the largest (brightest pixel value) and smallest number in the data we want to display are. Because the `max` value might be an outlier, we'll use the 1st and 99th *percentile* instead -- this is often called a **robust range**.

The function `scaleFunc` then squeezes the numbers into a range $[0..1]$ which works well for displaying.
"""

# ╔═╡ 13a8fe64-efb4-11ea-1ac6-dbd49975dddf
minMax = percentile(data[:], [1; 99])

# ╔═╡ 71606d26-efb4-11ea-12e2-75f85b9ea7d8
# helper function that knows how to scale images to a range that we can display
scaleFunc = scaleminmax(minMax[1], minMax[2])

# ╔═╡ c1d831e0-1448-11eb-0b18-a555cbcb18e1
Gray.(scaleFunc.(mosaicview(data[:,:,:,3], nrow=4; rowmajor=true)))

# ╔═╡ 88253376-1484-11eb-0967-27875c6da199
md"""because this is something we might want to do again and again, you can turn it into a **function**, which is something that takes an  *input*, changes it and spits it out again as an *output*
"""

# ╔═╡ b69a53ee-1484-11eb-0953-2b3ff81cf56c
function simpleMosaic(d, t=3, nr = 4)
	Gray.(scaleFunc.(mosaicview(d[:,:,:,t], nrow=nr; rowmajor=true)))
end

# ╔═╡ e2bea646-1484-11eb-3a26-ffc655b139c6
simpleMosaic(data) # now we can use the code this way

# ╔═╡ 25d9fd54-f450-11ea-3b2a-2f872e88a372
md"""
## An interactive 3d viewer

By combining the `displaySlice` function with an interactive slider
we can create a simple image viewer in the browser. Every time the slider position changes, the value in the variable `zSlider` gets updated

z coord $(@bind zSlider Slider(1:size(data,3), show_value=true))"""

# ╔═╡ 049e0688-1487-11eb-0362-edfd5f2d8241
md"""
## Looking in the 4th dimension - time

To look at the data at a particular voxel location, we can use the same idea of "coordinates" - we specify 3 spatial coordinates $[x,y,z]$ and take all the value in the time dimension:
"""

# ╔═╡ a8ab8ee6-f083-11ea-1316-7fbe4e125914
begin
md""" 
	
To make things interactive, we can tie the values of $x$, $y$, and $z$ to the sliders as before.
	
x coord $(@bind xLoc Slider(1:size(data,1), show_value=true))
	
y coord $(@bind yLoc Slider(1:size(data,2), show_value=true))
	
z coord $(@bind zLoc Slider(1:size(data,3), show_value=true))
	
To select all of the timepoints, there is a special symbol that means "select all" which is the colon/`:` ... so `data[xLoc,yLoc,zLoc,:]` translated into English means: select all timepoints at $[xLoc, yLoc, zLoc]$
	
"""
end

# ╔═╡ b247bd76-f07e-11ea-1e07-577643ff20af
begin
	#x,y,z = [32,32,12];
	plot(data[xLoc,yLoc,zLoc,:],line = (:red,3,1),
	title = "timecourse at [$(xLoc), $(yLoc), $(zLoc)]")
end

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Some helper functions """

# ╔═╡ 072ce484-efb2-11ea-36ee-29a0147cfc04
"""
displaySlice(data, slicenum, orientation)

return and display a slice in a particular orientation. there are smarter 
ways to implement the slicing through different orientations, but the code 
using if/elseif is easy to folllow.

	displaySlice(data, 2, 1)

"""
displaySlice = function(e, s = 1, orientation = 3, scaling = scaleFunc)
	if  (orientation == 1)
		displayData = view(e, s, :,:,1)
	elseif (orientation == 2)
		displayData = view(e, :,s,:,1)
	elseif( orientation == 3)
		displayData = view(e, :, :, s, 1)
	else 
		error("uhoh!")
	end
	rotl90(Gray.(scaling.(displayData)))
end

# ╔═╡ 1fed409a-f450-11ea-21be-8d44768dea80
displaySlice(data, zSlider, 3, scaleFunc) 

# ╔═╡ 8cbe6b98-144b-11eb-3d0a-35700773e22b
"""
showMosaic - arrange 4d data (at chosen timepoint) into a mosaic

    showMosaic(data,2)  # permute the dimensions (circshift twice)
						# and then arrange into roughly nxn mosaic

"""
function showMosaic(d, dim, t=1) 
	@pipe d[:,:,:,t] |> 
		permutedims(_, circshift([1,2,3],dim)) |>
		mosaicview(_, 
			nrow=Int64(round(sqrt(size(_,3)...))), 
			rowmajor=true,
			npad = 2,
			fillvalue = maximum(_)) |>
		scaleFunc.(_) |>
		Gray.(_)
end

# ╔═╡ Cell order:
# ╟─8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╟─9bc349e8-efb0-11ea-1392-cd735828af33
# ╟─46fbc1de-13d1-11eb-2553-71dfd823a5a0
# ╟─141dde62-efb1-11ea-34df-cd5e838d8129
# ╠═f0ef494e-f80c-11ea-1163-b954c1739162
# ╟─cdf28f06-1449-11eb-34b1-65a1fb83f330
# ╟─13a8fe64-efb4-11ea-1ac6-dbd49975dddf
# ╟─71606d26-efb4-11ea-12e2-75f85b9ea7d8
# ╠═c1d831e0-1448-11eb-0b18-a555cbcb18e1
# ╟─88253376-1484-11eb-0967-27875c6da199
# ╟─b69a53ee-1484-11eb-0953-2b3ff81cf56c
# ╠═e2bea646-1484-11eb-3a26-ffc655b139c6
# ╟─25d9fd54-f450-11ea-3b2a-2f872e88a372
# ╠═1fed409a-f450-11ea-21be-8d44768dea80
# ╟─049e0688-1487-11eb-0362-edfd5f2d8241
# ╟─a8ab8ee6-f083-11ea-1316-7fbe4e125914
# ╟─b247bd76-f07e-11ea-1e07-577643ff20af
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╟─072ce484-efb2-11ea-36ee-29a0147cfc04
# ╟─8cbe6b98-144b-11eb-3d0a-35700773e22b
