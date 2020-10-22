# hands-on-brain-data

Denis Schluppeck, Sept/Oct 2020.

This material provides some details for those of you wanting to reproduce the animations / interactive examples I have used to for teaching. 

You could also used this as a starting point for learning a bit of scripting / programming for your  own data analysis with #julialang with sample MRI data shown in class.

## Getting set up

@todo: create a minimal video explaining how to get off the ground with this (for new starters)

- install `julia` and `pluto.jl` as per excellent instructions [in this youtube clip](https://www.youtube.com/watch?v=OOjKEgbt8AI&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=21&t=204s)

- clone this repository

- make sure you have the dependencies (packages installed). In the `julia` interpreter run:

```julia
p = ["DelimitedFiles","NIfTI","Images","ImageView","Plots","PlutoUI"]
import Pkg
Pkg.add(p)
```

