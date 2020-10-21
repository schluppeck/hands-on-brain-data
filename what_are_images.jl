### A Pluto.jl notebook ###
# v0.11.14

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
	md"""loading packages..."""
end

# ╔═╡ 8029070e-efb0-11ea-1d0a-7f402f2e9989
md"""# What are images """

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Some helper functions """

# ╔═╡ 141dde62-efb1-11ea-34df-cd5e838d8129
begin 
	# read data in from file
	data = NIfTI.niread("filtered_func_data.nii");
	md"""loading in `data` """
end

# ╔═╡ f0ef494e-f80c-11ea-1163-b954c1739162
view(data, :, :, 12, 1)

# ╔═╡ a8ab8ee6-f083-11ea-1316-7fbe4e125914
begin
md""" 
x coord $(@bind xLoc Slider(1:size(data,1)))
	
y coord $(@bind yLoc Slider(1:size(data,2)))
	
z coord $(@bind zLoc Slider(1:size(data,3)))
"""
end

# ╔═╡ b247bd76-f07e-11ea-1e07-577643ff20af
begin
	#x,y,z = [32,32,12];
	plot(data[xLoc,yLoc,zLoc,:],line = (:red,3,1),
	title = "timecourse at [$(xLoc), $(yLoc), $(zLoc)]")
end

# ╔═╡ 13a8fe64-efb4-11ea-1ac6-dbd49975dddf
minMax = percentile(data[:], [1; 99])

# ╔═╡ 8df7fcb6-f602-11ea-3f15-ff7c241ce9d4
plotSlice = function(xl,yl,zl) 
	plot(heatmap(view(data, :,:, zl, 1)), aspect_ratio=:equal, axis=:off, clim=tuple(minMax...))
	#scatter!(xl,yl, mc=:red, ms=100 )
end

# ╔═╡ c7a7ee46-f60a-11ea-1da3-1b41d3510e0d
plotSlice(xLoc, yLoc, zLoc)

# ╔═╡ 71606d26-efb4-11ea-12e2-75f85b9ea7d8
scaleFunc = scaleminmax(minMax[1], minMax[2])

# ╔═╡ 072ce484-efb2-11ea-36ee-29a0147cfc04
"""
displaySlice

	return and display a slice in a particular orientation.

"""
displaySlice = function(e, s = 1, orientation = 1, scaling = scaleFunc)
	# - can index in +1st dimension of dataset
	# so even if dims = 3, indexing into 1 of dim=4 will work.
	#if (ndims(e) == 4)
	#	e = mean(e; dims = 4)
	#	println("console message - averaging across time")
	#end
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

# ╔═╡ 17ab42dc-f050-11ea-0d4a-e1c1ff54a1d9
[displaySlice(data, i, 3, scaleFunc) for i in convert.(Integer, round.(range(1, size(data, 3), length=5)))]

# ╔═╡ bb15657a-f5f4-11ea-2555-65b86fec3444
[displaySlice(data, i, 2, scaleFunc) for i in 1:10:size(data, 2)]

# ╔═╡ c6f20f76-f5f4-11ea-05d2-aba2612911f4
[displaySlice(data, i, 1, scaleFunc) for i in 1:10:size(data, 1)]

# ╔═╡ 44de79f0-f450-11ea-0f93-15cb49d19311
md"""## An interactive 3d viewer"""

# ╔═╡ 25d9fd54-f450-11ea-3b2a-2f872e88a372
md"""z coord $(@bind zSlider Slider(1:size(data,3)))"""

# ╔═╡ 1fed409a-f450-11ea-21be-8d44768dea80
displaySlice(data, zSlider, 3, scaleFunc) 

# ╔═╡ 265e6308-f835-11ea-1791-bd95b40046d8
X = readdlm("design-3.txt",',',Float64) 

# ╔═╡ c6cab78c-f836-11ea-2b5b-23f0006f8e93
begin
	plot(X[:,1])
	plot!(X[:,1], linetype=:scatter)

end

# ╔═╡ 9e102a1a-f835-11ea-2501-f5d4a8647607
begin
md""" 
β1 $(@bind b1 Slider(-10:10, default=1, show_value=true))
	
β2 $(@bind b2 Slider(-10:10, default=0, show_value=true))
	
β3 $(@bind b3 Slider(-10:10, default=0, show_value=true))
"""
end

# ╔═╡ 359ba3e4-f835-11ea-13ec-29d0a2a8a4ca
plot(X*[b1;b2;b3], xlim=(0,160), ylim=(-10, 10))

# ╔═╡ 880fcee6-ff28-11ea-1b6a-bd6f5a33504a
heatmap(X, c=:grays, yflip=true, 
	xlabel = "Design matrix column",
	yaxis = "Time (volumes)",
	xticks = [1,2,3])

# ╔═╡ Cell order:
# ╟─8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╠═f0ef494e-f80c-11ea-1163-b954c1739162
# ╠═17ab42dc-f050-11ea-0d4a-e1c1ff54a1d9
# ╠═bb15657a-f5f4-11ea-2555-65b86fec3444
# ╠═c6f20f76-f5f4-11ea-05d2-aba2612911f4
# ╟─b247bd76-f07e-11ea-1e07-577643ff20af
# ╟─a8ab8ee6-f083-11ea-1316-7fbe4e125914
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╠═8df7fcb6-f602-11ea-3f15-ff7c241ce9d4
# ╠═9bc349e8-efb0-11ea-1392-cd735828af33
# ╠═141dde62-efb1-11ea-34df-cd5e838d8129
# ╟─13a8fe64-efb4-11ea-1ac6-dbd49975dddf
# ╠═c7a7ee46-f60a-11ea-1da3-1b41d3510e0d
# ╠═71606d26-efb4-11ea-12e2-75f85b9ea7d8
# ╠═072ce484-efb2-11ea-36ee-29a0147cfc04
# ╟─44de79f0-f450-11ea-0f93-15cb49d19311
# ╟─25d9fd54-f450-11ea-3b2a-2f872e88a372
# ╟─1fed409a-f450-11ea-21be-8d44768dea80
# ╠═265e6308-f835-11ea-1791-bd95b40046d8
# ╠═c6cab78c-f836-11ea-2b5b-23f0006f8e93
# ╠═359ba3e4-f835-11ea-13ec-29d0a2a8a4ca
# ╟─9e102a1a-f835-11ea-2501-f5d4a8647607
# ╠═880fcee6-ff28-11ea-1b6a-bd6f5a33504a
