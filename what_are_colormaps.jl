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

# ╔═╡ 9bc349e8-efb0-11ea-1392-cd735828af33
# packaged loads, etc
begin
	using DelimitedFiles
	using NIfTI
	using Images
	using StatsBase
	using Plots
	using PlutoUI
	md"""loading packages..."""
end

# ╔═╡ 67655b27-30c9-40d2-98dd-3138ddef0321
begin
	import Pkg
	Pkg.activate(".")
	md"Load packages, but using the environment that is provided in folder..."
end

# ╔═╡ 47a60d48-058e-11eb-3140-03a5c22a27ee
html"<button onclick=present()>Present</button>"

# ╔═╡ ab3afe3a-0684-11eb-090d-ffeea5fcadec
html"""
<br>
"""

# ╔═╡ 730d087c-067b-11eb-0427-e9425b7c1ed6
md"""# Images and colourmaps"""

# ╔═╡ 8029070e-efb0-11ea-1d0a-7f402f2e9989
md"""## What are images and colourmaps?

- a brief explanations of RGB colours
- what are **intensity images**
- how can be superimpose two images by using different colour maps?

"""

# ╔═╡ 06433d72-058b-11eb-0565-c3e0f393ef5d
md"""## How do colours work on a computer?"""

# ╔═╡ 38bf1198-049f-11eb-0b21-334cd2fe39d3
md"""Colours used on computer displays are often defined in terms of the proportion of **red**, **green**, and **blue** the contain """

# ╔═╡ 542b0706-058b-11eb-0ae3-d57aa9ead256
[ RGB(1, 0, 0), RGB(0, 1, 0), RGB(0, 0, 1)]

# ╔═╡ bfb16300-058e-11eb-38d2-3572d8db913f
md"""## Controlling strength of each colour"""

# ╔═╡ ec3816c4-058b-11eb-2d8b-a1ed496f153d
md"""we can change the amount of each by multiplying by a number between 0 and 1

multiplying each color by a number varies the **amount**: $(@bind colorMult Slider(0:0.1:1, default = 1.0, show_value=true)) """ 

# ╔═╡ 0e5ddcca-058c-11eb-3068-73441b317478
[ RGB(colorMult, 0, 0), RGB(0, colorMult, 0), RGB(0, 0, colorMult)]

# ╔═╡ cb5f17f4-067b-11eb-3f8b-3ff5d0aa088c
md"""
- sometimes the colour values are displays as fractions $[0..1]$
- on the computer, those values are often stored between $[0..255]$ (**8 bits**)
"""

# ╔═╡ 62d614fc-058f-11eb-1fc0-09e86807181e
md"""## Mixing RGB creates unique colours """

# ╔═╡ 8baff8a4-058f-11eb-0882-9f305cf65b7c
md"""We can create many different colors by independently changing values and then adding:

The following proportions of 

`red` $(@bind redM Slider(0:0.1:1, default = 0.5, show_value=true)) 

`green` $(@bind greenM Slider(0:0.1:1, default = 0, show_value=true)) 

`blue` $(@bind blueM Slider(0:0.1:1, default = 0, show_value=true)) 

lead the following colour:
""" 

# ╔═╡ cc6e657e-058f-11eb-2314-5b6df2f908e9
begin
	cPatch =  [RGB(redM,greenM, blueM) for i=range(0,1, length=2), j= range(0,1, length=2)]
	heatmap(cPatch, 
		xticks=:none,
		yticks=:none, title="RGB = $([redM, greenM, blueM])", showaxis=false)
	
end

# ╔═╡ 70e80930-04a1-11eb-055b-152d2006d067
md"""## Example: mixing red with... 

number of steps in color map $(@bind nSteps Slider(5:5:15, show_value=true)) """ # number of steps in ramp"""

# ╔═╡ 1b79dd34-041d-11eb-037a-93335f4b4116
r = [RGB(i, 0, 0) for i=range(0,1, length=nSteps), j= range(0,1, length=nSteps)];

# ╔═╡ 50856a72-05ba-11eb-0f1f-7dc909270ad5
heatmap(r, xticks=:none, yticks=:none, showaxis=false)

# ╔═╡ 82d57e14-04a1-11eb-2190-9daace12efa8
md"""## ... more green/blue

results in a grid of colours that have more red $\downarrow$ and  

1. more green towards $\rightarrow$ right
2. more blue towards $\rightarrow$ right"""

# ╔═╡ 6f3591f2-049f-11eb-2a97-ad43e34fb000
begin
	g = [RGB(0,j, 0) for i=range(0,1, length=nSteps), j= range(0,1, length=nSteps)]
	b = [RGB(0,0, j) for i=range(0,1, length=nSteps), j= range(0,1, length=nSteps)]
	rg = [RGB(i,j, 0) for i=range(0,1, length=nSteps), j= range(0,1, length=nSteps)]
	rb = [RGB(i,0, j) for i=range(0,1, length=nSteps), j= range(0,1, length=nSteps)]
	heatmap(g, xticks=:none, yticks=:none, layout=(2,2), subplot=1,
		title="green", showaxis=false)
	heatmap!(b, xticks=:none, yticks=:none, layout=(2,2), subplot=2,
		title="blue", showaxis=false)
	heatmap!(rg, xticks=:none, yticks=:none, layout=(2,2), subplot=3,
		title="red + green", showaxis=false)
	heatmap!(rb, xticks=:none, yticks=:none, layout=(2,2), subplot=4,
		title="red + blue", showaxis=false)

end


# ╔═╡ 79e91b4e-0654-11eb-2fac-777bdb7c41f5
rgbTable = [RGB(i,j, k) for i=range(0,1, length=nSteps), 
		j=range(0,1, length=nSteps),
		k= range(0,1, length=nSteps)];

# ╔═╡ 0d3ab51c-0590-11eb-1d21-1f6fde64b56f
md""" ## So $\rightarrow$ 3 numbers to specify a colour 

### Question

What if we only want have 1 number for each pixel (or voxel in three dimensions)?

For example, the signal **intensity** from magnetic resonance imaging (MRI) is a single number at each point.

### Answer

Change `r`, `g`, and `b` values by same amount... this results in 

[black ... grey ... white]
"""

# ╔═╡ 3c37796e-058c-11eb-330f-c9f07956d74e
md""" ## grey """

# ╔═╡ 2a2a7d84-058f-11eb-27bb-db743f9910d5
md"""
$(@bind greyMult Slider(0:0.1:1, default = 0.7, show_value=true)) 
"""

# ╔═╡ 69bc09c0-058c-11eb-36a6-bd6e942b5e08
md"""... if we mix `R` , `G` and `B` together in equal amounts, we get GREY"""

# ╔═╡ 81adabb0-058c-11eb-3ee6-959bbf5f0c5d
 begin
	rgb = [RGB(greyMult,greyMult, greyMult) for i=range(0,1, length=2), j= range(0,1, length=2)]
	heatmap(rgb, xticks=:none, yticks=:none, 
			title="RGB = $(repeat([greyMult],1,3))", showaxis=false)
end

# ╔═╡ 266fa81e-067e-11eb-19f6-37bcc6c623e3
md"""## Colourmaps?!

The rule for which colour goes with which value...

$\begin{matrix}
0 & 1 & \dots & 254 & 255 \\
\text{black} & \text{dark grey} & \dots & \text{light grey} & \text{white}
\end{matrix}$

"""

# ╔═╡ 1c814864-0686-11eb-1c6f-2f0fa3d874cf
md"""or **reds**"""

# ╔═╡ c8c8b590-0685-11eb-037a-d17f5e4c3ba4
reverse(cgrad(:reds))

# ╔═╡ 26100fbe-0686-11eb-10eb-6752e71e2481
md"""or **jet** """

# ╔═╡ 3a80a800-0686-11eb-2da5-49c8cb23254d
cgrad(:jet1)

# ╔═╡ 8b8056b0-0686-11eb-15ae-c32b9e0034a2
md"""or **hsv**, **viridis**, ..."""

# ╔═╡ c00be5ca-0686-11eb-1a62-c75bb04147df
cgrad(:hsv)

# ╔═╡ c4cd3778-0686-11eb-169e-57ca0d655f5b
cgrad(:viridis)

# ╔═╡ 46874f50-0686-11eb-0e2b-8f54c14e5e8a
md"""[a whole list of them](http://docs.juliaplots.org/latest/generated/colorschemes/#scientific) online
"""

# ╔═╡ 7f61ac58-0684-11eb-182a-ad7903933dd5
md"""## Displaying a slice w/ different colourmaps """

# ╔═╡ 49141f5e-06fa-11eb-1cb0-7ffc29a11b48
md"""## Superimposing anatomy + statistical result

in practice, we often want to merge two images with different color maps, say *gray* (for anatomical imformation) and *inferno* (for statistical results)

"""


# ╔═╡ 1386a3c6-06fb-11eb-2abe-29cfbf505e0e
stat_image = niread("data/thresh_zstat3.nii");

# ╔═╡ f30741d0-06fa-11eb-290b-375c807e13c6
bg_image = niread("data/tmean.nii");

# ╔═╡ 3ebec912-06fc-11eb-23de-cdb28471c46d
md"""slice: $(@bind someSlice Slider(1:size(bg_image,3), default = 12, show_value=true))
"""

# ╔═╡ 9c1b27d4-0684-11eb-235b-eb019285d84d
html"""
<br>
"""

# ╔═╡ 27115482-0682-11eb-19d8-c344581ec8af
colormap_names = ["greys","reds", "jet", "viridis", "hsv", "inferno"];

# ╔═╡ 7d531b12-0682-11eb-3417-4f641024d076
@bind sliceColor Select(colormap_names)

# ╔═╡ 4aa28d70-067c-11eb-1bfc-179c255fcdd0
md"""## Some fun notes... 

somet things you can do with `Colors.jl` in a Pluto notebook.

"""

# ╔═╡ 6381fc42-0654-11eb-3d50-9fd2b4d241b7
md"""## the whole table of r, g, b...


mixing $(nSteps) red by $(nSteps) green by $(nSteps) blue results in $(nSteps.^3) colour tiles """

# ╔═╡ 9d530386-0654-11eb-13ea-4dbc0c7d9f03
begin
	allColors2d = reshape(rgbTable, nSteps, nSteps*nSteps )
	heatmap(allColors2d, xticks=:none, yticks=:none, size=(600,200), showaxis=false)
end

# ╔═╡ d12a8c42-0680-11eb-225d-f9d14982eef4
md"""## Showing colors and fMRI response

two different views of the same timecourse data:

- time (in volumes) runs from top $\downarrow$
- left view: fMRI response in colors (dark: low, bright: high)
- right view: a plot (just rotated by 90$^\circ$)

"""

# ╔═╡ 8fa5f8da-04a1-11eb-2941-65dd79fdba84
md"""### Colour picking in notebook """

# ╔═╡ 9d485144-0588-11eb-3996-0fc8abf6ed9d
 @bind someColor html"""<input type="color" id="favcolor" name="favcolor" value="#ff0000">"""

# ╔═╡ bd6e4a08-0588-11eb-0a97-d1d98b30d894
md"""the colour is stored a variable in **hexadecimal format**: $(someColor)"""

# ╔═╡ c35d782a-04a0-11eb-2d29-296d9f33ecd9
md"""### Named colors in the `Colors.jl` package """

# ╔═╡ 0b4e44d4-04a1-11eb-3e57-53f8cdb029a7
# get the color names out of the dictionary
color_names = sort([keys(Colors.color_names)...]);

# ╔═╡ 409aa96c-04a0-11eb-377a-2732f7fecbaa
[keys(Colors.color_names)...]

# ╔═╡ 2c6ad37c-04a0-11eb-28b7-8b55c2f60cb3
md"Pick a colour! $(@bind the_color Select(color_names))"

# ╔═╡ f3661c44-049f-11eb-1ff7-6f0d6d96d8fe
RGB(Colors.color_names[the_color]./255...)

# ╔═╡ 9f76bc18-0421-11eb-2d94-f7aa0f2e0998
md"""## math typsetting etc 

an equation 

```
\begin{equation}

	\sum_{i=0}^{\infty}\frac{1}{x^i}

\end{equation}
```

$\begin{equation}
	\sum_{i=0}^{\infty}\frac{1}{x^i}
\end{equation}$


"""

# ╔═╡ 44de79f0-f450-11ea-0f93-15cb49d19311
md"""## An interactive 3d viewer"""

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Some helper functions """

# ╔═╡ 141dde62-efb1-11ea-34df-cd5e838d8129
begin 
	# read data in from file
	data = NIfTI.niread("data/filtered_func_data.nii");
	md"""loading in `data` """
end

# ╔═╡ a8ab8ee6-f083-11ea-1316-7fbe4e125914
begin
md""" 
Try e.g. [42, 9, 8]
	
x  $(@bind xLoc Slider(1:size(data,1), default=42, show_value=true)); 	
y  $(@bind yLoc Slider(1:size(data,2), default=10, show_value=true)); z  $(@bind zLoc Slider(1:size(data,3), default=8, show_value=true))
"""
end

# ╔═╡ b247bd76-f07e-11ea-1e07-577643ff20af
begin
	heatmap(repeat(data[xLoc,yLoc,zLoc,:],1,1), 
		c=:greys, 
		layout=(1,2), subplot=1, 
	title = "timecourse at [$(xLoc), $(yLoc), $(zLoc)]")
	xaxis!(showaxis=:y, subplot=1)
	yaxis!(flip=true, ylabel="time (volumes)")
	plot!(data[xLoc,yLoc,zLoc,:], 1:size(data,4) ,subplot=2, label=:none)

	xaxis!(xlabel="fMRI response", xflip=false, subplot=2)
	yaxis!(showaxis=:xy, yflip=true, subplot=2)	
end

# ╔═╡ f0ef494e-f80c-11ea-1163-b954c1739162
view(data, :, :, 12, 1)

# ╔═╡ 25d9fd54-f450-11ea-3b2a-2f872e88a372
md"""z coord $(@bind zSlider Slider(1:size(data,3)))"""

# ╔═╡ 13a8fe64-efb4-11ea-1ac6-dbd49975dddf
minMax = percentile(data[:], [1; 99])

# ╔═╡ 8df7fcb6-f602-11ea-3f15-ff7c241ce9d4
plotSlice = function(zl, cmap="greys") 
	heatmap(view(data, :,:, zl, 1), 
		aspect_ratio=:equal, 
		axis=:off, 
		clim=tuple(minMax...),
		c=Symbol(cmap),
	title = "Slice # $(zl) with colors: $(cmap)")
end

# ╔═╡ 9dc04240-0681-11eb-3db5-ad9e7e1ee810
plotSlice(zLoc,sliceColor)

# ╔═╡ 71606d26-efb4-11ea-12e2-75f85b9ea7d8
scaleFunc = scaleminmax(minMax[1], minMax[2])

# ╔═╡ 3ed9060c-06fb-11eb-1440-a168e684e874
begin
	bgSlice = bg_image[:,:,someSlice]
	statSlice = stat_image[:,:, someSlice]
	statSlice[statSlice .< 2.3] .= NaN
	# minAndMax = percentile(bgSlice, (5, 95))
	#Gray.(scaleFunc.(displayData)
	gImage = Gray.(scaleFunc.(bgSlice))
	statScale = scaleminmax(0, 8.0)
	sImage =  statSlice; #statScale.(statSlice)
	cImage = gImage .+ sImage
	heatmap(gImage, title="slice $(someSlice), anatomy + statistical map")
	heatmap!(sImage, aspect_ratio=1,c=:hot, clims=(2.3,8))
	xaxis!(showaxis=:no)
	
end

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

# ╔═╡ bb15657a-f5f4-11ea-2555-65b86fec3444
[displaySlice(data, i, 2, scaleFunc) for i in 1:10:size(data, 2)]

# ╔═╡ c6f20f76-f5f4-11ea-05d2-aba2612911f4
[displaySlice(data, i, 1, scaleFunc) for i in 1:10:size(data, 1)]

# ╔═╡ 1fed409a-f450-11ea-21be-8d44768dea80
displaySlice(data, zSlider, 3, scaleFunc) 

# ╔═╡ f289d412-05be-11eb-172b-316cebd67e80
gr()
#plotly()

# ╔═╡ Cell order:
# ╟─47a60d48-058e-11eb-3140-03a5c22a27ee
# ╟─ab3afe3a-0684-11eb-090d-ffeea5fcadec
# ╟─730d087c-067b-11eb-0427-e9425b7c1ed6
# ╟─8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╟─06433d72-058b-11eb-0565-c3e0f393ef5d
# ╟─38bf1198-049f-11eb-0b21-334cd2fe39d3
# ╟─542b0706-058b-11eb-0ae3-d57aa9ead256
# ╟─bfb16300-058e-11eb-38d2-3572d8db913f
# ╟─ec3816c4-058b-11eb-2d8b-a1ed496f153d
# ╟─0e5ddcca-058c-11eb-3068-73441b317478
# ╟─cb5f17f4-067b-11eb-3f8b-3ff5d0aa088c
# ╟─62d614fc-058f-11eb-1fc0-09e86807181e
# ╟─8baff8a4-058f-11eb-0882-9f305cf65b7c
# ╟─cc6e657e-058f-11eb-2314-5b6df2f908e9
# ╟─70e80930-04a1-11eb-055b-152d2006d067
# ╟─1b79dd34-041d-11eb-037a-93335f4b4116
# ╟─50856a72-05ba-11eb-0f1f-7dc909270ad5
# ╟─82d57e14-04a1-11eb-2190-9daace12efa8
# ╟─6f3591f2-049f-11eb-2a97-ad43e34fb000
# ╟─79e91b4e-0654-11eb-2fac-777bdb7c41f5
# ╟─0d3ab51c-0590-11eb-1d21-1f6fde64b56f
# ╟─3c37796e-058c-11eb-330f-c9f07956d74e
# ╟─2a2a7d84-058f-11eb-27bb-db743f9910d5
# ╟─69bc09c0-058c-11eb-36a6-bd6e942b5e08
# ╟─81adabb0-058c-11eb-3ee6-959bbf5f0c5d
# ╟─266fa81e-067e-11eb-19f6-37bcc6c623e3
# ╟─1c814864-0686-11eb-1c6f-2f0fa3d874cf
# ╟─c8c8b590-0685-11eb-037a-d17f5e4c3ba4
# ╟─26100fbe-0686-11eb-10eb-6752e71e2481
# ╟─3a80a800-0686-11eb-2da5-49c8cb23254d
# ╟─8b8056b0-0686-11eb-15ae-c32b9e0034a2
# ╟─c00be5ca-0686-11eb-1a62-c75bb04147df
# ╟─c4cd3778-0686-11eb-169e-57ca0d655f5b
# ╟─46874f50-0686-11eb-0e2b-8f54c14e5e8a
# ╟─7f61ac58-0684-11eb-182a-ad7903933dd5
# ╟─9dc04240-0681-11eb-3db5-ad9e7e1ee810
# ╟─7d531b12-0682-11eb-3417-4f641024d076
# ╟─49141f5e-06fa-11eb-1cb0-7ffc29a11b48
# ╟─3ebec912-06fc-11eb-23de-cdb28471c46d
# ╟─3ed9060c-06fb-11eb-1440-a168e684e874
# ╟─1386a3c6-06fb-11eb-2abe-29cfbf505e0e
# ╟─f30741d0-06fa-11eb-290b-375c807e13c6
# ╟─9c1b27d4-0684-11eb-235b-eb019285d84d
# ╟─27115482-0682-11eb-19d8-c344581ec8af
# ╟─4aa28d70-067c-11eb-1bfc-179c255fcdd0
# ╟─6381fc42-0654-11eb-3d50-9fd2b4d241b7
# ╟─9d530386-0654-11eb-13ea-4dbc0c7d9f03
# ╟─d12a8c42-0680-11eb-225d-f9d14982eef4
# ╟─b247bd76-f07e-11ea-1e07-577643ff20af
# ╟─a8ab8ee6-f083-11ea-1316-7fbe4e125914
# ╟─8fa5f8da-04a1-11eb-2941-65dd79fdba84
# ╟─bd6e4a08-0588-11eb-0a97-d1d98b30d894
# ╟─9d485144-0588-11eb-3996-0fc8abf6ed9d
# ╟─c35d782a-04a0-11eb-2d29-296d9f33ecd9
# ╟─0b4e44d4-04a1-11eb-3e57-53f8cdb029a7
# ╠═409aa96c-04a0-11eb-377a-2732f7fecbaa
# ╟─f3661c44-049f-11eb-1ff7-6f0d6d96d8fe
# ╟─2c6ad37c-04a0-11eb-28b7-8b55c2f60cb3
# ╟─9f76bc18-0421-11eb-2d94-f7aa0f2e0998
# ╠═f0ef494e-f80c-11ea-1163-b954c1739162
# ╠═bb15657a-f5f4-11ea-2555-65b86fec3444
# ╠═c6f20f76-f5f4-11ea-05d2-aba2612911f4
# ╟─44de79f0-f450-11ea-0f93-15cb49d19311
# ╠═1fed409a-f450-11ea-21be-8d44768dea80
# ╟─25d9fd54-f450-11ea-3b2a-2f872e88a372
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╟─8df7fcb6-f602-11ea-3f15-ff7c241ce9d4
# ╟─67655b27-30c9-40d2-98dd-3138ddef0321
# ╟─9bc349e8-efb0-11ea-1392-cd735828af33
# ╟─141dde62-efb1-11ea-34df-cd5e838d8129
# ╟─13a8fe64-efb4-11ea-1ac6-dbd49975dddf
# ╟─71606d26-efb4-11ea-12e2-75f85b9ea7d8
# ╟─072ce484-efb2-11ea-36ee-29a0147cfc04
# ╟─f289d412-05be-11eb-172b-316cebd67e80
