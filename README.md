# hands-on-brain-data

Denis Schluppeck, started Sept/Oct 2020.

This material provides some details for reproducing the animations / interactive examples I have used to for teaching in my 2nd year undergraduate lab in **neuroimaging**. 

You could also used this as a starting point for learning a bit of scripting / programming for your  own data analysis with #julialang with sample MRI data shown in class.

<img src="julia-gif.gif" alt="example animation"> 

## Getting set up

- install `julia` and `pluto.jl` as per excellent instructions [in this youtube clip](https://www.youtube.com/watch?v=OOjKEgbt8AI&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=21&t=204s)

- clone or download this repository:
```bash
cd ~
git clone https://github.com/schluppeck/hands-on-brain-data.git
```

- make sure you have the dependencies (packages installed). In the `julia` interpreter run:

```julia
p = ["DelimitedFiles","NIfTI","Images","ImageView","Plots","PlutoUI"]
import Pkg
Pkg.add(p)
```

Then run the Pluto notebook you want to explore. The first time you run it, you will have to be a bit patient, as some additional packages may need to be installed)

```julia
using Pluto
Pluto.run()
# and open specific notebook in browser
```

or - if you know which notebook you want to have a look at:

```julia
using Pluto
Pluto.run(notebook="what_are_images.jl")
```

Enjoy!