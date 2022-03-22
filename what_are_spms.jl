### A Pluto.jl notebook ###
# v0.12.10

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
	using LinearAlgebra
	using StatsBase
	using GLM
	using DataFrames
	using Plots
	using Distributions
	using StatsPlots
	using PlutoUI
	using Pipe
	using Printf
	md"""## loading packages...
	
	The notebook makes use of some existing functionality from other code which is stored in "packages" that you can install and use.
	
	"""
end

# ╔═╡ a04710a0-281b-11eb-3c11-5b53a085e59e
html"<button onclick=present()>Present</button>"

# ╔═╡ 8029070e-efb0-11ea-1d0a-7f402f2e9989
md"""# What are `spm`s

Statistical parametric maps... are maps / images that contain statistical values in the same x,y,z as the original image data...

They can be images of the β weights, or other statistics that are derived from them, such as 

- the coefficient of determintation, $r^{2}$ 
- a t-statistic,  $t$, (like from a $t$-test you already know
- statistical significance, $p$-values, etc.


"""

# ╔═╡ 44032c62-2522-11eb-32d2-af427f6ce946
md"""## Doing linear regression 

The linear regression analysis can be done very neatly using *linear algebra*. The details of this are beyond this 2nd year lab class, but just to give you an idea of what things look like:

$$\large \text{{\color{teal} \textbf{data}}} = \text{\bf \color{magenta} explanatory variables} \cdot \mathbf{w} $$

$$\large \mathbf{\color{teal} y} = \mathbf{\color{magenta} X}  \cdot w$$

In this equation $\mathbf{w}$, the weights, are what the want to determine. We have measured data -- and by designing the experiment in a particular way (what stimuli when, etc), we have determined the explanatory variables.

To find the weights we need to solve this equation for $\mathbf{w}$:

$$\begin{align}
y &= X \color{green}\mathbf{w}
\end{align}$$





"""

# ╔═╡ cf9fbcc4-2534-11eb-1a82-ad480057d2b0
d, h= readdlm("data/stimulus_timing.csv", ',', Float64, header = true );

# ╔═╡ 3df12514-2535-11eb-2cf3-fdfc727a993b
X = hcat(d[:,3:4], ones(size(d,1),1)) ;

# ╔═╡ b7f96162-25af-11eb-274a-7d368d09906b
md"""
## Using the `lm()` linear model function

*linear models* and regression are some of the most fundamental techniques used in stats, so they are implemented in many software tools, including `SPSS`, and packages for `R`, `Matlab`, `python`, `julia` and many others (as we have seen even in `Excel`)

Across all those tools, the models are often presented in terms of **formulas**, e.g.

  `y ~ face_response + object_response`

which stands for a model that tries to predict the data `y` as a linear combination of two explanatory variables, `face_response` and `object_response`

$$\begin{align}
\color{green}\mathbf{w} \color{black} &= X \backslash y 
\end{align}$$

or in code
```julia
w = \(X,ȳ)
# or 
w = pinv(X)*ȳ
```
"""

# ╔═╡ a66ed758-25bc-11eb-29ad-01f9ba1bd5be


# ╔═╡ dcb3ad64-281b-11eb-2a9c-5d9cfce9e2e2
md"""## Model:

The measured eesponse is combination of `F` and `O` response"""

# ╔═╡ ba55a268-281b-11eb-3bcd-5b948d03fdbf
md"""## Data, model, residuals..."""

# ╔═╡ dfb188e0-2836-11eb-0081-514c967cace5
md"""## How significant is the response

Turn the beta weight into a $t$ statistic and from there into a $p$ value

$$\begin{align}
t  &= \frac{\text{mean}}{\text{standard error}}
\end{align}$$

Then we need to figure out whether that  $t$-value we calculated is far enough away from 0 to be "significant".

"""

# ╔═╡ 1a0bfe62-2837-11eb-02e3-45eff0ed23f6
t_value = 5.29832/0.229458

# ╔═╡ 39ad1ca2-284a-11eb-3c64-e5e1317eb3d4
md"""$(@bind deg_freedom Slider(2:1:20; default=5, show_value=true)) """

# ╔═╡ e86ecc6e-2849-11eb-34da-0189163c776d
begin
	xx = -5.0:0.2:5.0
	plot(Distributions.TDist(deg_freedom), fill=(0, .5,:teal), 
	size=(600,200), title="t Distribution (ν=$(deg_freedom))", label=false)
end


# ╔═╡ 148b4e22-25ba-11eb-28ac-4f90284e7e41
md""" ## Visualising many weights """

# ╔═╡ 6b22738e-281f-11eb-0be4-3195a4953529
md"""## And the `t` values

"""

# ╔═╡ c886d94e-25bc-11eb-0b39-8144659ec58f
md"""## Other versions of the model"""

# ╔═╡ f543c9da-281c-11eb-05bd-ad64b4005507
md"""## Only modelling the `F` response"""

# ╔═╡ 0a4f3af8-281d-11eb-3337-8fbb9998237c
md"""## Only modelling the `O` response"""

# ╔═╡ 41d2d3cc-281d-11eb-176a-c9230c75163c
md"""## Some timing / performance measurements"""

# ╔═╡ 2b2f6be4-f07f-11ea-1459-775749ca949f
md"""## Some helper functions """

# ╔═╡ 46fbc1de-13d1-11eb-2553-71dfd823a5a0
md"""...loading in the contents of a file into a **variable** called `data` works as follows:"""

# ╔═╡ cdf28f06-1449-11eb-34b1-65a1fb83f330
md"""
## Displaying images

To look at the images, we can stich them together into one big *mosaic* and turn them into *grayscale* image that the browswer can display. To do this, we need to find out what the largest (brightest pixel value) and smallest number in the data we want to display are. Because the `max` value might be an outlier, we'll use the 1st and 99th *percentile* instead -- this is often called a **robust range**.

The function `scaleFunc` then squeezes the numbers into a range $[0..1]$ which works well for displaying.
"""

# ╔═╡ 5aed662e-2525-11eb-12a3-c9c9118f6fec
demean = function(y)
	100 .* (y./mean(y) .- 1.0)
end

# ╔═╡ 88253376-1484-11eb-0967-27875c6da199
md"""because this is something we might want to do again and again, you can turn it into a **function**, which is something that takes an  *input*, changes it and spits it out again as an *output*
"""

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
view(data, 1:10:64, 1:10:64, 12, 3);

# ╔═╡ 14f85bc0-2533-11eb-065b-93a0cccb036a
begin
	theSz = [ size(data)[1:3]... ; 3];
	β̂ = zeros(theSz...);
	tmap = zeros(theSz...);

	@time for ix = 1:theSz[1], iy = 1:theSz[2], iz = 1:theSz[3] 
		# if mod(ii, 1000) == 1
		# 	println("tada")
		# end
		ols = lm(X, Float64.(demean(data[ix,iy,iz,:])))
		β̂[ix,iy,iz,:] = coef(ols)
		tmap[ix, iy, iz, :] = 	coeftable(ols).cols[3] # t values
	end
	
end

# ╔═╡ a8ab8ee6-f083-11ea-1316-7fbe4e125914
begin
md""" 
	
### Calculate the beta **weights** at a voxel
	
We can pick the timeseries data at one particular location and see how long it takes to do that....
	
[plot residuals] $(@bind plotResiduals CheckBox()) – [plot model] $(@bind plotModel CheckBox())
	
	
x coord $(@bind xLoc Slider(1:size(data,1), default = 18, show_value=true))
	
y coord $(@bind yLoc Slider(1:size(data,2), default = 14, show_value=true))
	
z coord $(@bind zLoc Slider(1:size(data,3), default = 4, show_value=true))

	
"""
end

# ╔═╡ 04256b16-2525-11eb-30b3-eb750b5af1a2
y = data[xLoc,yLoc,zLoc,:];

# ╔═╡ 3c5138dc-25b9-11eb-058d-71a10f974857
ȳ = demean(y);

# ╔═╡ 42ace0ae-2538-11eb-3143-31d86905a747
md"""

slice: $(@bind whichSlice Slider( 1:size(data,3) ; default=1, show_value=true))

threshold: $(@bind whichThreshold Slider( 0:0.5:15 ; default=2.0, show_value=true))


"""

# ╔═╡ d0b91c60-2537-11eb-2ff2-eda55e302239
begin
	b1 = β̂[:,:,whichSlice,1] 
	b2 = β̂[:,:,whichSlice,2]
	
	
	b1[abs.(b1) .<= whichThreshold] .= NaN
	b2[abs.(b2) .<= whichThreshold] .= NaN
	
	b3 = b1 .- b2

	heatmap(b1, color=:reds, clim = (0,5), layout = (1,2), 
			title = "weights map 1",
			subplot=1, 
			aspect_ratio=1, showaxis=false)
	heatmap!(b2, color=:blues, clim = (0,5), layout = (1,2), 
			title = "weights map 2",
			subplot=2, 
			aspect_ratio=1, showaxis=false)
	
		# heatmap!(b3, clim = (-15,15), layout = (1,3), 
		# 	title = "w1 - w2 (f > o)",
		# 	subplot=3, 
		# 	aspect_ratio=1, showaxis=false)
end


# ╔═╡ 86dbd432-281f-11eb-1aab-b53d4a226dd0
md"""

slice (t): $(@bind whichSliceT Slider( 1:size(data,3) ; default=1, show_value=true))

threshold (for t): $(@bind whichThresholdT Slider( 0:0.5:15 ; default=2.0, show_value=true))


"""

# ╔═╡ 757b4a0e-281f-11eb-32ad-cfff43e2ebe3
begin 
	t1 = tmap[:,:,whichSliceT,1] 
	t2 = tmap[:,:,whichSliceT,2]

	
	t1[abs.(t1) .<= whichThresholdT] .= NaN
	t2[abs.(t2) .<= whichThresholdT] .= NaN
	
	t3 = t1 .- t2
	t4 = t2 .- t1
	

	# heatmap(t1, color=:reds, clim = (0,5), layout = (1,1), 
	# 		title = "t map 1",
	# 		subplot=1, 
	# 		aspect_ratio=1, showaxis=false)
	# heatmap!(t2, color=:blues, clim = (0,5), layout = (1,1), 
	# 		title = "t map 2",
	# 		subplot=2, 
	# 		aspect_ratio=1, showaxis=false)
	heatmap(t3, color=cgrad([:blue, :white, :red]), clim = (-5,5), layout = (1,1), 
			title = "t map (F - O)",
			subplot=1, 
			aspect_ratio=1, showaxis=false)
	
	
end

# ╔═╡ 55f99666-25ba-11eb-1fd4-a15c6751527e
df = DataFrame(y = Float64.(demean(data[xLoc,yLoc, zLoc,:])),
				face_r = X[:,1], object_r = X[:,2]);

# ╔═╡ 3bf4e998-25a4-11eb-252b-6fdb6a29a92e
ols = lm(@formula(y ~ face_r + object_r), df)

# ╔═╡ 9af3adba-25ba-11eb-34a7-59079afd5231
md"""## How well does the model fit the data?

The coefficient of determination, $r^2$, tells us how much of the variance in the data is accounted for by our model. $r^2$ = $(round( r2(ols); digits=2)) means $( round( 100*r2(ols); digits=0)) % of the variance.

It can be calculated as

$$r^{2}= 1 - \frac{\text{var(residuals)}}{\text{var(data)}}$$



A value of $r^{2} = 1.0$  means that our model is perfect.

A value of $r^{2} \approx 0$ means that our model can't explain our data at all.


"""

# ╔═╡ ab4cc236-25b1-11eb-3f63-233af5cfea96
r² = r2(ols) 

# ╔═╡ 10a0bd36-2837-11eb-2fe7-69a17334a3d9
ols

# ╔═╡ 821ffcee-2849-11eb-340d-2dc707fd0a8f
md""" ## But what about a $p$-value

The p-value corresponds to the area under the curve beyond the calculated t-value... i our example for `face_r` it was t = $(round(coeftable(ols).cols[3][2]; digits=2)) and a p-value of $(@sprintf "%.2g" coeftable(ols).cols[4][2])


"""

# ╔═╡ 765e7432-25a4-11eb-10b5-d3bdab410d87
olsFvO = lm(@formula(y ~ face_r - object_r), df)

# ╔═╡ 570626cc-25a5-11eb-123c-63c5b9aad411
olsF = lm(@formula(y ~ face_r), df)

# ╔═╡ 76cdcb54-25bb-11eb-0e29-9dfeae3f803d
r2(olsF)

# ╔═╡ 9fa22482-25a5-11eb-2b76-1949341e2630
olsO = lm(@formula(y ~ object_r), df)

# ╔═╡ 894cdc18-25bb-11eb-130d-93b864ddcc42
r2(olsO)

# ╔═╡ 1ef8659c-2539-11eb-184a-d95f169892a4
result = @timed @pipe data[xLoc,yLoc,zLoc,:] |> 
	 					demean( _ ) |>
	 					vec( _ ) |>
	 					X \ _ 

# ╔═╡ 3483ee2c-2525-11eb-2967-d343eb3d16f0
begin

	
	p_ = plot(ȳ, lw=2, c=:black, label="data $([xLoc, yLoc, zLoc])", size=(600,200), 
			xlabel="Time (volumes)", ylabel="fMRI response",
			title="r² = $(round(r²; digits=2))")
	
	modelFit = modelFit = X*result.value
	residuals = ȳ .- modelFit

	if plotModel	
		plot!(modelFit, c=:red, lw=2.0, label="model fit")
	end
	
	if plotResiduals
		plot!(residuals, line=:stem, c=:blue, label="redisuals")
	end
	
	p_
end

# ╔═╡ 15ad8bf8-2835-11eb-1315-f5d8ea0d2bf9
md"""The *weights* for reconstructing are: **$(@sprintf "[%.2f. %.2f, %.2f]" result.value...)**"""

# ╔═╡ a48038d4-2539-11eb-3374-dbbeaed2a3a5
result.value

# ╔═╡ b3a74a5a-2539-11eb-017a-f9b3ffe38663
r_microseconds = result.time * 1000 * 1000; # in microseconds

# ╔═╡ 3e13431a-253a-11eb-265e-f11984b2b2fb
md"""The following expression feeds the data from [$(xLoc); $(yLoc); $(zLoc)] to a function called `demean()` and then to a function called `vec()` and finally does the maths using the `\` (backslash) operator:

Time taken: ≈ $(round(r_microseconds; digits=2)) microseconds

weights: $(@sprintf("[%.2f, %.2f, %.2f]", round.(result.value; digits=2)...))



"""

# ╔═╡ 13a8fe64-efb4-11ea-1ac6-dbd49975dddf
minMax = percentile(data[:], [1; 99])

# ╔═╡ 71606d26-efb4-11ea-12e2-75f85b9ea7d8
# helper function that knows how to scale images to a range that we can display
scaleFunc = scaleminmax(minMax[1], minMax[2])

# ╔═╡ c1d831e0-1448-11eb-0b18-a555cbcb18e1
@pipe data[:,:,:,3] |>
	mosaicview( _ , nrow=4; rowmajor=true) |>
	scaleFunc.( _ ) |>
	Gray.( _ )

# ╔═╡ b69a53ee-1484-11eb-0953-2b3ff81cf56c
function simpleMosaic(d, t=3, nr = 4)
	Gray.(scaleFunc.(mosaicview(d[:,:,:,t], nrow=nr; rowmajor=true)))
end

# ╔═╡ e2bea646-1484-11eb-3a26-ffc655b139c6
simpleMosaic(data) # now we can use the code this way

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
# ╠═a04710a0-281b-11eb-3c11-5b53a085e59e
# ╟─8029070e-efb0-11ea-1d0a-7f402f2e9989
# ╟─f0ef494e-f80c-11ea-1163-b954c1739162
# ╟─44032c62-2522-11eb-32d2-af427f6ce946
# ╟─04256b16-2525-11eb-30b3-eb750b5af1a2
# ╟─3c5138dc-25b9-11eb-058d-71a10f974857
# ╟─cf9fbcc4-2534-11eb-1a82-ad480057d2b0
# ╟─3df12514-2535-11eb-2cf3-fdfc727a993b
# ╟─14f85bc0-2533-11eb-065b-93a0cccb036a
# ╟─b7f96162-25af-11eb-274a-7d368d09906b
# ╟─a66ed758-25bc-11eb-29ad-01f9ba1bd5be
# ╟─dcb3ad64-281b-11eb-2a9c-5d9cfce9e2e2
# ╠═3bf4e998-25a4-11eb-252b-6fdb6a29a92e
# ╟─ba55a268-281b-11eb-3bcd-5b948d03fdbf
# ╟─3483ee2c-2525-11eb-2967-d343eb3d16f0
# ╟─15ad8bf8-2835-11eb-1315-f5d8ea0d2bf9
# ╟─a8ab8ee6-f083-11ea-1316-7fbe4e125914
# ╟─9af3adba-25ba-11eb-34a7-59079afd5231
# ╠═ab4cc236-25b1-11eb-3f63-233af5cfea96
# ╟─dfb188e0-2836-11eb-0081-514c967cace5
# ╠═1a0bfe62-2837-11eb-02e3-45eff0ed23f6
# ╠═10a0bd36-2837-11eb-2fe7-69a17334a3d9
# ╟─821ffcee-2849-11eb-340d-2dc707fd0a8f
# ╠═e86ecc6e-2849-11eb-34da-0189163c776d
# ╟─39ad1ca2-284a-11eb-3c64-e5e1317eb3d4
# ╟─148b4e22-25ba-11eb-28ac-4f90284e7e41
# ╟─d0b91c60-2537-11eb-2ff2-eda55e302239
# ╟─42ace0ae-2538-11eb-3143-31d86905a747
# ╟─6b22738e-281f-11eb-0be4-3195a4953529
# ╟─757b4a0e-281f-11eb-32ad-cfff43e2ebe3
# ╟─86dbd432-281f-11eb-1aab-b53d4a226dd0
# ╟─c886d94e-25bc-11eb-0b39-8144659ec58f
# ╠═765e7432-25a4-11eb-10b5-d3bdab410d87
# ╟─f543c9da-281c-11eb-05bd-ad64b4005507
# ╠═570626cc-25a5-11eb-123c-63c5b9aad411
# ╠═76cdcb54-25bb-11eb-0e29-9dfeae3f803d
# ╟─0a4f3af8-281d-11eb-3337-8fbb9998237c
# ╠═9fa22482-25a5-11eb-2b76-1949341e2630
# ╠═894cdc18-25bb-11eb-130d-93b864ddcc42
# ╟─55f99666-25ba-11eb-1fd4-a15c6751527e
# ╟─41d2d3cc-281d-11eb-176a-c9230c75163c
# ╟─3e13431a-253a-11eb-265e-f11984b2b2fb
# ╠═1ef8659c-2539-11eb-184a-d95f169892a4
# ╠═a48038d4-2539-11eb-3374-dbbeaed2a3a5
# ╠═b3a74a5a-2539-11eb-017a-f9b3ffe38663
# ╟─2b2f6be4-f07f-11ea-1459-775749ca949f
# ╟─46fbc1de-13d1-11eb-2553-71dfd823a5a0
# ╟─cdf28f06-1449-11eb-34b1-65a1fb83f330
# ╟─c1d831e0-1448-11eb-0b18-a555cbcb18e1
# ╟─e2bea646-1484-11eb-3a26-ffc655b139c6
# ╠═9bc349e8-efb0-11ea-1392-cd735828af33
# ╠═13a8fe64-efb4-11ea-1ac6-dbd49975dddf
# ╟─71606d26-efb4-11ea-12e2-75f85b9ea7d8
# ╟─b69a53ee-1484-11eb-0953-2b3ff81cf56c
# ╟─5aed662e-2525-11eb-12a3-c9c9118f6fec
# ╟─88253376-1484-11eb-0967-27875c6da199
# ╟─141dde62-efb1-11ea-34df-cd5e838d8129
# ╟─072ce484-efb2-11ea-36ee-29a0147cfc04
# ╟─8cbe6b98-144b-11eb-3d0a-35700773e22b
