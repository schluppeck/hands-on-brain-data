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

# ╔═╡ cbc19359-d1e7-424c-8c02-d816dbd1a6c6
begin
	import Pkg
	Pkg.activate(".")
end

# ╔═╡ 9bc349e8-efb0-11ea-1392-cd735828af33
# packages to load etc
begin
	using DelimitedFiles
	using NIfTI
	using Images
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
Gray.(scaleFunc.(mosaicview(data[:,:,:,10], nrow=4; rowmajor=true)))

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

# ╔═╡ 2a4ce9d7-e55a-4f8f-bb93-d67104d53256
md"zoom level [display size] $(@bind zoomLevel Slider(1:10, show_value=true))"

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

# ╔═╡ ba7eef62-6a8b-465f-88da-5c2178ddfe73
md"## display numbers as images, w/ scaling 
using code I found here <https://gist.github.com/pbouffard/3d48d3c47d9bd70e7c9f52f984d14245>, define a `struct`, `function`, and a `show` method. See also this reference here: <https://github.com/fonsp/pluto-notebooks/blob/master/svd-video.jl>"

# ╔═╡ 59a179f0-1057-4270-99a9-0d1b6fcf3000
begin
	struct BWImage
		data::Array{UInt8, 2}
		zoom::Int
	end
	function BWImage(data::Array{T, 2}; zoom::Int=1) where T <: Real
		BWImage(floor.(UInt8, clamp.(((data .- minimum(data)) / (maximum(data) .- minimum(data))) * 255, 0, 255)), zoom)
	end
	
	import Base: show
	
	function show(io::IO, ::MIME"image/bmp", i::BWImage)

		orig_height, orig_width = size(i.data)
		height, width = (orig_height, orig_width) .* i.zoom
		datawidth = Integer(ceil(width / 4)) * 4

		bmp_header_size = 14
		dib_header_size = 40
		palette_size = 256 * 4
		data_size = datawidth * height * 1

		# BMP header
		write(io, 0x42, 0x4d)
		write(io, UInt32(bmp_header_size + dib_header_size + palette_size + data_size))
		write(io, 0x00, 0x00)
		write(io, 0x00, 0x00)
		write(io, UInt32(bmp_header_size + dib_header_size + palette_size))

		# DIB header
		write(io, UInt32(dib_header_size))
		write(io, Int32(width))
		write(io, Int32(-height))
		write(io, UInt16(1))
		write(io, UInt16(8))
		write(io, UInt32(0))
		write(io, UInt32(0))
		write(io, 0x12, 0x0b, 0x00, 0x00)
		write(io, 0x12, 0x0b, 0x00, 0x00)
		write(io, UInt32(0))
		write(io, UInt32(0))

		# color palette
		write(io, [[x, x, x, 0x00] for x in UInt8.(0:255)]...)

		# data
		padding = fill(0x00, datawidth - width)
		for y in 1:orig_height
			for z in 1:i.zoom
				line = vcat(fill.(i.data[y,:], (i.zoom,))...)
				write(io, line, padding)
			end
		end
	end
end

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
	# BWImage( rotl90(Gray.(scaling.(displayData))), zoom=3)
	BWImage( rotl90(scaling.(displayData)), zoom=zoomLevel)

end

# ╔═╡ 1fed409a-f450-11ea-21be-8d44768dea80
displaySlice(data, zSlider, 3, scaleFunc) 

# ╔═╡ 06883c4a-dc68-4c6f-871b-e4f4efeab0cf
# test with a random array
BWImage(randn(30,30), zoom=7)

# ╔═╡ Cell order:
# ╟─8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╟─cbc19359-d1e7-424c-8c02-d816dbd1a6c6
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
# ╟─2a4ce9d7-e55a-4f8f-bb93-d67104d53256
# ╠═1fed409a-f450-11ea-21be-8d44768dea80
# ╟─049e0688-1487-11eb-0362-edfd5f2d8241
# ╟─a8ab8ee6-f083-11ea-1316-7fbe4e125914
# ╟─b247bd76-f07e-11ea-1e07-577643ff20af
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╟─072ce484-efb2-11ea-36ee-29a0147cfc04
# ╟─8cbe6b98-144b-11eb-3d0a-35700773e22b
# ╟─ba7eef62-6a8b-465f-88da-5c2178ddfe73
# ╟─59a179f0-1057-4270-99a9-0d1b6fcf3000
# ╠═06883c4a-dc68-4c6f-871b-e4f4efeab0cf
