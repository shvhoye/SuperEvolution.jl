### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 79f21734-4164-421a-a887-c78f3ea1d054
using PlutoUI, Plots, Images, Distributions, Random, Test

# ╔═╡ 46d05db8-f79e-45d9-92eb-874f7153cd5e
md"""

# Super Evolution

*STMO*

*2021-2022*

**Shauny Van Hoye**

"""

# ╔═╡ 06fe0d51-26b1-4ea7-b789-985964f7b110
imresize(Images.load(Images.download("https://github.com/shvhoye/SuperEvolution.jl/blob/master/figures/Clover.png?raw=true")), ratio = 1/2.5)

# ╔═╡ e2357883-94f7-42c9-8bef-6644af323c7b
md""" 
## Overview

In this notebook, we will explore the Superformula, how it can be used to visualize and explain evolution, and how Superformula shapes can be fitted to real images using optimization algorithms such as simulated annealing or the MAP-Elites algorithm.

1. The Superformula

2. Exploring what the Superformula can do

3. Evolving Supershapes using subjective optimization

4. Fitting Supershapes to images of diatoms, flowers and starfish using simulated annealing and MAP-Elites

"""

# ╔═╡ cead5325-a013-4151-8cb2-486147e9066f
md"""
## 1. The Superformula

The Superformula is a generalization of the superellipse. It is a simple geometrical equation that can be used to describe many complex shapes and curves found in nature such as starfish, flowers, diatoms..., but also many abstract and man-made geometrical shapes and forms. The shapes obtained using the Superformula are called Supershapes (Gielis, 2003). 

With $r$ the radius and $ϕ$ the angle in polar coordinates, different shapes can be generated using the following formula:


$$\\[2pt]$$

$$r\left(\varphi\right) = \left(\left|\frac{\cos\left(\frac{m\varphi}{4}\right)}{a}\right| ^{n_2}+ \left|\frac{\sin\left(\frac{m\varphi}{4}\right)}{b}\right| ^{n_3}\right) ^{-\frac{1}{n_{1}}}$$

$$\\[2pt]$$

The parameters of the Superformula: $a$, $b$, $m$, $n_1$, $n_2$ and $n_3$ can also be seen as the "genes" of the Supershapes. If you change the parameters and thus the genes of the Supershape you will obtain a different form.

The implementation of the Superformula can be found just below. Other functions can be found in the appendix.

"""

# ╔═╡ b31cb3af-1c9b-4698-a8c7-be692b31207c
"""

	superformula(phi; a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17)

	An implementation of the Superformula as described by Gielis in 2003.

	Input:
		- phi: the angle in a polar coordinate system
		- a, b, m, n1, n2 and n3: parameters of the Superformula

	Output:
		- r: the radius in a polar coordinate system

"""
function superformula(phi; a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17)
	
	raux = abs.(1 / a .* abs.(cos.(m * phi / 4))) .^ n2 + abs.(1 / b .* abs.(sin.(m * phi / 4))) .^ n3
  
	r = abs.(raux) .^ (- 1 / n1)
  
	return r

end

# ╔═╡ 4524e200-ae4e-41c8-b06b-a41b7e39f899
md"""Below you can see one of the many possible forms that can be described using the superformula."""

# ╔═╡ 69f12062-cf39-4f57-b2ea-24e25b41ddd5
md"""
## 2. Exploring what the Superformula can do

The parameters/genes of the Supershape can be changed using the sliders below. You can play with the sliders and observe the rich diversity of resulting Supershapes you are able to form.

"""

# ╔═╡ 93880c6b-a27e-4f7d-a5d9-74b5e5d363fc
@bind a Slider(1:50, show_value=true, default=21)

# ╔═╡ bb587364-5a3a-41f1-9e57-87facbc21181
@bind b Slider(1:50, show_value=true, default=35)

# ╔═╡ 4b0cfe82-aa8f-4f67-bb44-b3486ef8a5cf
@bind m Slider(0:50, show_value=true, default=31)

# ╔═╡ df17e490-9da5-4686-a5c5-3c7de897b2b4
@bind n1 Slider(-5:5, show_value=true, default=2)

# ╔═╡ 4314b935-1b31-4a03-9eba-4e70bca8a1b4
@bind n2 Slider(0:0.1:5, show_value=true, default=1)

# ╔═╡ 04261bb7-0ab6-466b-9448-67d54bbe8b35
@bind n3 Slider(0:50, show_value=true, default=1)

# ╔═╡ fe9d41d3-f253-4480-b95e-4c92316227ca
md"""
## 3. Evolving Supershapes using subjective optimization

"""

# ╔═╡ d9159850-9f56-4c6d-bd2c-c984bb72b9b8
md"""

In an attempt to explain and visualize the concept of evolution, the user can evolve a Supershape. This can be achieved by starting with a parent Supershape and next creating each time eight mutants and selecting one each time to become the parent in the next generation. A mutant is created by changing the genes/parameters $m$, $n1$, $n2$ and $n3$ randomly. This is achieved by adding a random number from a normal distribution around 0 with a specific variation to the parent's parameters. Since it is you, the user, that is selecting the parent for the next generation, this evolutionary process can be seen as some sort of subjective optimization of the Supershape towards a shape the user likes. This is because there is no given objective function that is able to tell the algorithm which mutant has a higher or lower objective value, but the user selects a mutant based on the user's subjective choice.

The small applet below that allows the user to evolve a Supershape is inspired by the book "The Blind Watchmaker: Why the Evidence of Evolution Reveals a Universe without Design" by Richard Dawkins in 1986.

In the implementation below, 9 Supershapes can be seen: 1 parent in the centre and its 8 mutants/offspring surrounding it. The mutant's genes are identical to its parent's genes except for some slight mutations.

By pressing on one of the buttons for a certain mutant, you can select which mutant you want to become the parent in the next generation. This process can be repeated to see how the Supershape evolves over time. In the figure, P stands for parent and M for mutant, followed by its number.

The slider below the figure allows you to modify how different the next generation will be compared to the parent.

One fun experiment to do would be to guide your Supershape towards some goal. You can imagine the contour of a flower, starfish, diatom... and try to come as close as possible to that shape by choosing the mutant that most closely resembles that objective. 

The genes for the current parent are also visible below.

The gradual change in the Supershape's appearance in each generation serves as a simple model of biological evolution. Each Supershape is nearly identical to its parent, but after many generations, the appearance of the Supershape can diverge wildly from the original Supershape. Even though biological evolution works on a much longer time scale, it does work in a similar way. As an example, your dog probably closely resembles his parents, his parents probably closely resemble their parents and so on, but if you were to go back tens of thousands of generations your dog's distant ancestors would only bear a slight resemblance to your dog (Dawkins, 1986).

Since you select which mutant you want to survive, the evolution of Supershapes in this case is an example of artificial selection. Similar to how humans influenced the evolution of dogs over the past 15,000 – 30,000 years. In nature, however, evolution is based on natural selection: organisms that are best suited for their environment are the ones most likely to survive and pass on their genes (Dawkins, 1986).

In his book, Dawkins uses a similar applet as seen below to argue that natural selection can explain the complex adaptations of organisms. An important aspect that can be illustrated, is the difference between the potential for the development of complexity as a result of pure randomness, as opposed to that of randomness coupled with cumulative selection. The accumulation of random events is crucial for evolution and the emergence of complex features in life (Dawkins, 1986).

Besides evolution, Supershapes are not only useful for modelling shapes found in nature but also allow insight into why certain forms grow the way they do (Gielis, 2003).

"""

# ╔═╡ b39841bc-91da-4a37-96bb-abfa6e2b0245
md"""
	
By changing the slider below, you can allow for more or less variation between the parent and its mutants. 
	
"""

# ╔═╡ e3a7b0dd-482f-4618-a5bb-3eb03a0ae7c1
md"""Press the button below if you would like to start over."""

# ╔═╡ 39154389-5fa6-4071-a923-315035e17e98
@bind start_over Button("Start over")

# ╔═╡ 59cc8d61-38d4-435d-a9c7-5213607091c0
begin

	start_over # Allows to run this block of code to reset the counters of the buttons when the user wants to start over.

	# m stands for mutant

	md"""
	
	$(@bind m1 CounterButton("Mutant 1"))
	$(@bind m2 CounterButton("Mutant 2"))
	$(@bind m3 CounterButton("Mutant 3")) 
	$(@bind m4 CounterButton("Mutant 4"))
	$(@bind m5 CounterButton("Mutant 5"))
	$(@bind m6 CounterButton("Mutant 6"))
	$(@bind m7 CounterButton("Mutant 7"))
	$(@bind m8 CounterButton("Mutant 8"))
	
	"""

end

# ╔═╡ a96772bc-3726-4869-9bcf-189c2cd1b834
begin 
	
	start_over # Allows to run this block of code to reset the counters of the buttons when the user wants to start over.

	# A slider that allows the user to change how different the mutants are from the parents.
	
	md"""
	
	$(@bind variation Slider(0.0:0.01:5.0, show_value=true, default = 0.7))
	
	"""
end

# ╔═╡ 94071fd6-9ad8-47f6-9600-40f5b4ba8f94
md"""*If an error occurs when starting over, please just click in the block of code above and it will be resolved."""

# ╔═╡ bc364f47-1d39-4307-bcda-583922c9464c


# ╔═╡ fe6179e8-088c-4481-8110-acc832f83bca
md"""

### The "genes" of the current parent

"""

# ╔═╡ 2fda126a-9dd8-437a-8905-cce39bc996b7


# ╔═╡ c2e4a65c-efaa-4c3a-97a3-639e08846e36
md"""

### Chosing a new parent

"""

# ╔═╡ b3c2a892-2dba-419d-8d4a-f573aec3720d
md"""
The Superformula can describe many complex shapes and curves that are found in nature, such as starfish, diatoms, flowers... as can be seen below. You can try to select mutants to obtain the shapes below.

Alternatively, you can push one of the buttons for the supershapes so it becomes the first parent in the evolution simulation above. (S in the figures stands for Supershape, followed by the number of the shape.)

"""

# ╔═╡ 48f0fd88-ad2c-410c-b2c1-a03e5f885368
begin

	start_over # Allows to run this block of code to reset the counters of the buttons when the user wants to start over.

	# f stands for figure

	md"""
	
	$(@bind f1 CounterButton("Supershape 1"))
	$(@bind f2 CounterButton("Supershape 2"))
	$(@bind f3 CounterButton("Supershape 3")) 
	$(@bind f4 CounterButton("Supershape 4"))
	
	"""

end

# ╔═╡ 20fc0cb2-c466-4638-babd-9b4d24f21e5b


# ╔═╡ 9664adef-5be1-45e3-a5ba-75f2baada277
md"""### Animation of the evolutionary path"""

# ╔═╡ 006ec0f4-dde9-4dfa-8845-b43eff6ccfd1
md"""Once you have selected multiple mutants above, you can push the "Animate" button to view an animation of the evolutionary path you chose."""

# ╔═╡ c280da39-9c4d-4aac-a081-3feaa55fe1cb
@bind Animate Button("Animate")

# ╔═╡ 72cb67a5-93c9-4913-8739-9527d10cd690


# ╔═╡ 2702a17a-c26d-4939-b9ab-1b1bf2da4f44
md"""
## 4. Fitting Supershapes to images of diatoms, flowers and starfish using simulated annealing and MAP-Elites

Since the Superformula has the ability to describe so many naturally occurring shapes, it could be interesting to see if Supershapes can be fit to images of diatoms, flowers and starfish.

The objective is to obtain a Supershape that resembles the original/natural shape as close as possible. An example of this can be seen below, but in these two examples, I tweaked the parameters by hand.

"""

# ╔═╡ cf1245c4-4298-41cf-a368-124b38982a68
md"""

A figure of a diatom with an overlapping Supershape with parameters $a$ = 1, $b$ = 1, $m$ = 3, $n_1$ = 5, $n_2$ = 8 and $n_3$ = 8


"""

# ╔═╡ f4444d7d-f283-42b5-a6c6-579a0564c354
md"""

A figure of a flower with an overlapping Supershape with parameters $a$ = 1, $b$ = 1, $m$ = 40, $n_1$ = 13, $n_2$ = -4 and  $n_3$ = 17.


"""

# ╔═╡ 7c19a13d-16a7-43e2-89f7-987690e60269
md"""
In order to fit the Supershapes to the figures, the simulated annealing algorithms and the MAP-Elites algorithms will be used and the solutions of both will be compared. For simplicity, we will start by trying to recreate a specific Supershape using SA and ME. Next, it can be tried on real images, but some image processing has to be done first. This can be viewed in the appendix.

"""

# ╔═╡ d615309c-0f5a-4d6f-aab3-fb7c1fd1c92c
md"""

**4.1 Simulated annealing (SA)**

The parameters for the SA algorithm: 


"""

# ╔═╡ 419d5824-c7c8-43a9-8107-8b04b0ed093a
@bind logTmin Slider(-10:1.0, show_value=true, default=-2.0)

# ╔═╡ a47999e1-9415-492d-8784-4ced249a1b79
@bind logTmax Slider(1:5.0, show_value=true, default=4.0)

# ╔═╡ 36b88a3b-b8d9-452d-b5c4-bb30aced0b4b
@bind r Slider(0.01:0.01:0.99, show_value=true, default=0.85)

# ╔═╡ 85a9b84f-a9d1-4532-ba58-ac0eaa978af0
@bind kT Slider(1:20:1000, show_value=true, default=100.0)

# ╔═╡ 368f2043-6505-4c48-801e-aad1537e7b30
md"""Because running SA takes a couple of minutes, it doesn't run automatically. You can push the "Run SA" button to start."""

# ╔═╡ 4938804e-3f04-4821-847d-4bdb9c24d78b
@bind SA CounterButton("Run SA")

# ╔═╡ ebb3daa8-e41f-4ea1-8798-8840f1954c7c
md"""*If an error occurs involving the range() function it might be best to update julia to the current stable version, which is v1.7.1 at this particular moment (31/01/2022). (Same goes for 4.2 MAP-Elites (ME))"""

# ╔═╡ eab12a20-28a1-47c4-9d46-0a8b2ed6d870


# ╔═╡ 24159b9c-d157-40cd-9539-3855101c2b73
md"""

**4.2 MAP-Elites (ME)**


"""

# ╔═╡ 219b169c-6b41-4981-b5bc-7fa7241326c7
md"""Because running MAP-Elites takes ~ half a minute, it doesn't run automatically. You can push the "Run MAP-Elites" button to start."""

# ╔═╡ 28c31d86-816b-48c3-bf67-1734a8002d57
@bind ME CounterButton("Run MAP-Elites")

# ╔═╡ f88a733a-6bb2-4d0d-8c52-cef4498a5754
md"""In the next part, the ME algorithm tries to approximate the contour extracted from a real image using a Supershape."""

# ╔═╡ ebf8ad58-30fa-4a2d-b3d1-a008cca30d22
@bind ME2 CounterButton("Run MAP-Elites 2")

# ╔═╡ 36b314bf-e3d6-4f73-be03-81d140723f86


# ╔═╡ 81e5f62c-e7f5-4782-b555-19ec870ab2ef
md"""The results vary depending on the shape we are trying to approximate. I suspect that either (or both) the neighbour and objective function would need refinement for better results. I did try to use the MSE of a Fast Fourier transforms (on the radii in polar coordinates) as the objective function, but it lead to worse results than those above. Adjusting only one (random) parameter at a time when creating a new neighbour also did not improve the results."""

# ╔═╡ 99a9bc93-2942-4e32-96b8-369649c0148b
md"""## Super Evolution unit tests


Unit tests to ensure that the Superformula function and the mutant function meet their design and behave as intended.


"""

# ╔═╡ 194351eb-bf39-428f-aae1-d2501bf4384b
md""" ## References

- Dawkins, R., & Pyle, L. (1986). The blind watchmaker.

- Gielis, J. (2003). A generic geometric transformation that unifies a wide range of natural and abstract shapes. American journal of botany, 90(3), 333-338.

"""

# ╔═╡ 8d8f3a18-c4ed-444a-b947-773e7f6384ef
md"""## Appendix

Table of contents for the appendix
	
	a. Superformula related functions and variables
	
	b. Simulated annealing related functions
	
	c. MAP-Elites related functions
	
	d. Figures used in section 4
	
	e. Segmentation and contours of images for section 4

"""

# ╔═╡ 99fd40ba-933c-4653-b14b-46d2dd05274f


# ╔═╡ 14120ff1-56e8-41d2-b3eb-8fb95a6b3290
md"""

**a. Superformula related functions and variables**

"""

# ╔═╡ 0034ac1f-9e7f-4ee1-b894-edf8c22ab1db
superformula(x...; kwargs...) = superformula(x; kwargs...)

# ╔═╡ bc4c4e75-e7a9-4da4-82b3-3ca74a72df4a
"""
	plotsuperformula(phi; a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17, label = "", colour = 1)

	A function that takes in the parameters for the Superformula, converts them to an x and a y in a Cartesian coordinate system and plots the resulting curve.

	Input:
		- phi: the angle in a polar coordinate system
		- a, b, m, n1, n2 and n3: parameters of the Superformula
		- label: the label of the figure
		- colour: the colour of the Supershape
		

	Output:
		- a plot of the Supershape

"""
function plotsuperformula(phi; a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17, label = "", colour = 1)

	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(superformula(i;a, b, m, n1, n2, n3), digits=8)

		x[num] = rnew[num] .* cos(i)
  
		y[num] = rnew[num] .* sin(i)

	end
	
	return plot(x, y, axis = nothing, label= "$label", border=:none, fg_legend = :transparent, colour = colour, aspect_ratio = :equal)

end

# ╔═╡ ab23b27d-2ece-4e90-b560-863be9610a57
plotsuperformula(x...; kwargs...) = plotsuperformula(x; kwargs...)

# ╔═╡ cbdff552-ca0d-4b89-918c-bb926a03a975
"""

	mutant(;a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17)

	A function for creating mutants/offspring by changing the genes/parameters of the parents via random variation.

	Input:
		- a, b, m, n1, n2 and n3: the original parameters
	
	Output:
		- a_new, b_new, m_new, n1_new, n2_new and n3_new: the new parameters

	

"""
function mutant(;a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17)

	d = Normal(0.0, variation)
		
	a_new = 1 
	
	b_new = 1 
	
	m_new = m + rand(d)
	
	n1_new = n1 + rand(d)
	
	n2_new = n2 + rand(d)
	
	n3_new = n3 + rand(d)
	    
	return a_new, b_new, m_new, n1_new, n2_new, n3_new

end

# ╔═╡ 070fa6ac-91dd-48a1-b905-27aa6f2c272e
@testset "Super Evolution" begin
	
    # test some cases
    
	@test superformula(1; a = 1, b = 1, m = 1, n1 = 1, n2 = 1, n3 = 1) ≈ 0.8221545114820233

    @test round.(superformula([0, 0.1, 0.2, 0.3, 0.4]; a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17), digits = 3) ≈ [1.0, 1.021, 1.087, 1.213, 1.429]

	# test for type
        
	@test superformula(pi; a = 1, b = 1, m = 7, n1 = 3, n2= 4, n3 = 17) isa Number

	@test mutant(;a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17) isa Tuple

	@test sum(mutant(;a = 1, b = 1, m = 7, n1 = 3, n2 = 4, n3 = 17)) isa Number

end

# ╔═╡ 71d54c27-eddc-4638-b5c8-dfa7698d4856
begin

	start_over # Allows to run this block of code to reset the counters of the buttons when the user wants to start over.

	# Initialising some variables for the evolution of the Supershapes
	
	a_figures = [1 3 1 0.8] 
	
	b_figures = [1 3 1 1] 
	
	m_figures = [5 6 16 4] 
	
	n1_figures = [2 -14 12.8734 1.5]
	
	n2_figures = [7 29 -3.58012 3]
	
	n3_figures = [7 6 16.599 10] 

	figures_list = [0 0 0 0]	

	a_parents = [1.0]
	
	b_parents = [1.0]
		
	m_parents = [7.0]
	
	n1_parents = [3.0]
		
	n2_parents = [4.0]
		
	n3_parents = [17.0]

	mutants_list = [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
	
	a_mutant, b_mutant, m_mutant, n1_mutant, n2_mutant, n3_mutant = fill(1.0, 8), fill(1.0, 8), fill(7.0, 8), fill(3.0, 8), fill(4.0, 8), fill(17.0, 8)
		
	parents = []
	
	md"""Initialising some variables for the evolution of the Supershapes"""

end

# ╔═╡ 432bac03-8a76-481a-a053-b4599e9bb57f
ϕ = 0:.001:2 .* pi

# ╔═╡ 1e12714b-1860-47d4-a098-946ccb38a526
plotsuperformula(ϕ)

# ╔═╡ b35f0400-009e-4ea7-b380-f516e6499ac7
plotsuperformula(ϕ; a = a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3)

# ╔═╡ 07aef886-ed96-4419-b8cf-270ac96a944a
let 


	
	### JUST CLICK ON THIS TEXT TO RESOLVE THE ERROR AND START OVER :)
	


	
	## Code that allows you to evolve the supershapes

	# Outside of this block of code, some variables are initialised variables. This can be looked at at in the appendix.

	# outside_mutants is an array that keeps track of how many times a button for a certain mutant has been pushed. mutants_list does the same, but is not automatically updated. We can use this difference to find out which button the user pressed, so we can make that mutant the parent in the next generation.

	outside_mutants = [m1 m2 m3 m4 m5 m6 m7 m8]

	# Test to see which mutant the user has selected to be the parent in the next generation.
	
	test = outside_mutants .== mutants_list

	# Use the genes/parameters of the mutant that was selected for the parent of the next generation.

	for (num, i) in enumerate(test)

		if i == 0

			push!(parents, num)
			mutants_list[num] = outside_mutants[num]

		end

	end

	
	figures = [f1 f2 f3 f4]

	test2 = figures .!= figures_list 

	if length(parents) == 0

		# Start with a given shape

		global a_parent_1 = 1
		global b_parent_1 = 1
		global m_parent_1 = 7
		global n1_parent_1 = 3
		global n2_parent_1 = 4
		global n3_parent_1 = 17

		
		#=

		# Start with a random shape

		global a_parent_1 = 1
		global b_parent_1 = 1
		global m_parent_1 = rand(0:50)
		global n1_parent_1 = rand(0:50)
		global n2_parent_1 = rand(0:50)
		global n3_parent_1 = rand(0:50)

		=#

	elseif any(test2)

		for (num, i) in enumerate(test2)

			if i == 1
	
				a_parent_1, b_parent_1,	m_parent_1,	n1_parent_1, n2_parent_1, n3_parent_1 = a_figures[num], b_figures[num], m_figures[num], n1_figures[num], n2_figures[num], n3_figures[num] 

				figures_list[num] = figures[num]
	
	
			end

	end

		
	else


	# Update the genes/parameters of the parent
		
	i = parents[end] # Which mutant becomes the parent?
			
	a_parent_1, b_parent_1,	m_parent_1,	n1_parent_1, n2_parent_1, n3_parent_1 = a_mutant[i], b_mutant[i], m_mutant[i], n1_mutant[i], n2_mutant[i], n3_mutant[i] 


	# Keep track of all the parents for the animation
		
	push!(a_parents, a_parent_1)
	
	push!(b_parents, b_parent_1)
	
	push!(m_parents, m_parent_1)
	
	push!(n1_parents, n1_parent_1)
	
	push!(n2_parents, n2_parent_1)
	
	push!(n3_parents, n3_parent_1)

	end
	
	# Plot the parent
	
	p9 = plotsuperformula(ϕ; a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1, label = "P")

	# Muntant 1

	# a new mutant based of the current parent
	
	a_mutant[1], b_mutant[1], m_mutant[1], n1_mutant[1], n2_mutant[1], n3_mutant[1] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)

	# Plot the new mutant 

	p1 = plotsuperformula(ϕ; a = a_mutant[1], b = b_mutant[1], m = m_mutant[1], n1 = n1_mutant[1], n2 = n2_mutant[1], n3 = n3_mutant[1], label = "M1")

	# Muntant 2
		
	a_mutant[2], b_mutant[2], m_mutant[2], n1_mutant[2], n2_mutant[2], n3_mutant[2] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)

	p2 = plotsuperformula(ϕ; a = a_mutant[2], b = b_mutant[2], m = m_mutant[2], n1 = n1_mutant[2], n2 = n2_mutant[2], n3 = n3_mutant[2], label = "M2")

	# Muntant 3
	
	a_mutant[3], b_mutant[3], m_mutant[3], n1_mutant[3], n2_mutant[3], n3_mutant[3] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)

	p3 = plotsuperformula(ϕ; a = a_mutant[3], b = b_mutant[3], m = m_mutant[3], n1 = n1_mutant[3], n2 = n2_mutant[3], n3 = n3_mutant[3], label = "M3")

	# Muntant 4
	
	a_mutant[4], b_mutant[4], m_mutant[4], n1_mutant[4], n2_mutant[4], n3_mutant[4] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)

	p4 = plotsuperformula(ϕ; a = a_mutant[4], b = b_mutant[4], m = m_mutant[4], n1 = n1_mutant[4], n2 = n2_mutant[4], n3 = n3_mutant[4], label = "M4")

	# Muntant 5
	
	a_mutant[5], b_mutant[5], m_mutant[5], n1_mutant[5], n2_mutant[5], n3_mutant[5] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)

	p5 = plotsuperformula(ϕ; a = a_mutant[5], b = b_mutant[5], m = m_mutant[5], n1 = n1_mutant[5], n2 = n2_mutant[5], n3 = n3_mutant[5], label = "M5")

	# Muntant 6

	a_mutant[6], b_mutant[6], m_mutant[6], n1_mutant[6], n2_mutant[6], n3_mutant[6] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)
	
	p6 = plotsuperformula(ϕ; a = a_mutant[6], b = b_mutant[6], m = m_mutant[6], n1 = n1_mutant[6], n2 = n2_mutant[6], n3 = n3_mutant[6], label = "M6")

	# Muntant 7
	
	a_mutant[7], b_mutant[7], m_mutant[7], n1_mutant[7], n2_mutant[7], n3_mutant[7] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)
	
	p7 = plotsuperformula(ϕ; a = a_mutant[7], b = b_mutant[7], m = m_mutant[7], n1 = n1_mutant[7], n2 = n2_mutant[7], n3 = n3_mutant[7], label = "M7")

	# Muntant 8
	
	a_mutant[8], b_mutant[8], m_mutant[8], n1_mutant[8], n2_mutant[8], n3_mutant[8] = mutant(a = a_parent_1, b = b_parent_1, m = m_parent_1, n1 = n1_parent_1, n2 = n2_parent_1, n3 = n3_parent_1)
	
	p8 = plotsuperformula(ϕ; a = a_mutant[8], b = b_mutant[8], m = m_mutant[8], n1 = n1_mutant[8], n2 = n2_mutant[8], n3 = n3_mutant[8], label = "M8")

	# Plot all the supershapes in one figure.

	plot(p1, p2, p3, p4, p9, p5, p6, p7, p8, layout = (3, 3), legend = true)

end

# ╔═╡ 5d5d1465-b37e-4a74-b528-00a4e6841c99
md"""

Gene $a$ = $(round(a_parent_1, digits = 3))

Gene $b$ = $(round(b_parent_1, digits = 3))

Gene $m$ = $(round(m_parent_1, digits = 3))

Gene $n_1$ = $(round(n1_parent_1, digits = 3))

Gene $n_2$ = $(round(n2_parent_1, digits = 3))

Gene $n_3$ = $(round(n3_parent_1, digits = 3))

"""

# ╔═╡ 9c8289b7-e5f8-4902-a160-c921e0dd3981
let
	
	p1 = plotsuperformula(ϕ; a = 1, b = 1, m = 5, n1 = 2, n2 = 7 , n3 = 7, label = "S1")

	p2 = plotsuperformula(ϕ; a = 3, b = 3, m = 6, n1 = -14 , n2 = 29, n3 = 6, label = "S2")

	p3 = plotsuperformula(ϕ; a = 1, b = 1, m = 16, n1 =12.8734, n2 = -3.58012, n3 = 16.599, label = "S3")

	p4 = plotsuperformula(ϕ; a = 0.8, b = 1, m = 4, n1 = 1.5, n2 = 3, n3 = 10, label = "S4")

	# Plot

	plot(p1, p2, p3, p4, layout = (2, 2), legend = true)

end

# ╔═╡ a64106b2-e70c-4eb5-967f-ab0e9994b2c3
let
	
	supershape_solution = [1 1 3 5 8 8 0.5 0.5 120 120 220 155]  

	#supershape_solution = [1 1 40 13 -4 17 0.5 0.5 120 120 220 155]  

	phi = ϕ

	a = supershape_solution[1]
	b =  supershape_solution[2]
	m =  supershape_solution[3]
	n1 =  supershape_solution[4]
	n2 =  supershape_solution[5]
	n3 =  supershape_solution[6]
	parameter1 =  supershape_solution[7]
	parameter2 =  supershape_solution[8]
	parameter3 =  supershape_solution[9]
	parameter4 =  supershape_solution[10]
	parameter5 =  supershape_solution[11]
	parameter6 =  supershape_solution[12]

	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)

		x[num] = rnew[num] .* cos(i+parameter1)*parameter3 + parameter5
  
		y[num] = rnew[num] .* sin(i+parameter2)*parameter4 + parameter6


	end

	global image = rnew

	md""" The shape we want to recreate is hidden here. """

end

# ╔═╡ 3f823e11-d5e8-4850-945b-c7d23de6b769
animation = @animate for i in 1:length(a_parents)

	Animate
	
		a = a_parents[i]
		
		b = b_parents[i]
			
		m = m_parents[i]
		
		n1 = n1_parents[i]
			
		n2 = n2_parents[i]
			
		n3 = n3_parents[i]

		plotsuperformula(ϕ; a = a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3)
	
end

# ╔═╡ 4e8037a5-524a-4307-809e-3c9f833d9027
gif(animation, fps = 2)

# ╔═╡ bf7f0593-79f7-4161-b128-c199ae4cb5c2


# ╔═╡ a0de21e2-84ea-4d49-92f8-825853fb7a08
md"""

**b. Simulated annealing related functions and variables**


"""

# ╔═╡ 1063bb90-2818-4174-a003-c17160e71fd5
initial_supershape = [1 1 2 2 2 2 1 1 10 10 10 10] 

# ╔═╡ 9cfdaff3-5abf-4784-815f-4530b71a60e5
"""
	random_neighbor(supershape)

	Creates a random neighbor for a specific Supershape

	Inputs:
		- Supershape: all the parameters needed to make a Supershape + rotation and translation parameters

	Output:
		- neighbor: all the parameters needed to make the new Supershape + rotation and translation parameters


"""
function random_neighbor(supershape)

	a  =  copy(supershape[1])
	
	b =  copy(supershape[2])
	
	m =  copy(supershape[3])
	
	n1 =  copy(supershape[4])
	
	n2 =  copy(supershape[5])
	
	n3 =  copy(supershape[6])

	parameter1 =  copy(supershape[7])
	
	parameter2 =  copy(supershape[8])
	
	parameter3 =  copy(supershape[9])
	
	parameter4 =  copy(supershape[10])
	
	parameter5 =  copy(supershape[11])
	
	parameter6 =  copy(supershape[12])

	d = Normal(0.0, 0.05)
	
	d2 = Normal(0.0, 0.005)	

	d3 = Normal(0.0, 5)	
	
	a_new = 1 #a + rand(d)
	
	b_new = 1 #b + rand(d)
	
	m_new = m + rand(d)
	
	n1_new = n1 + rand(d)
	
	n2_new = n2 + rand(d)
	
	n3_new = n3 + rand(d)
	
	parameter1_new =  parameter1 + rand(d2)
	
	parameter2_new = parameter2 + rand(d2)
	
	parameter3_new =  parameter3 + rand(d3)
	
	parameter4_new = parameter4 + rand(d3)
	
	parameter5_new = parameter5 + rand(d3)
	
	parameter6_new = parameter6 + rand(d3)

	neighbor = [a_new b_new m_new n1_new n2_new n3_new parameter1_new parameter2_new parameter3_new	parameter4_new parameter5_new parameter6_new]

	return neighbor

end

# ╔═╡ d789ad4e-eb5f-486c-bd88-967601b5afdb
"""
	simulated_annealing(f, s₀, image; kT=100,  r=0.95, Tmax=1_000, Tmin=1) 

	SA implementation

	Inputs:
		- f: objective function
		- s₀: initial solution
		- image: x and y coordinates for the contour of the image
		- kT: looping parameter
		- r: decaying rate
		- Tmax: maximum temperature
		- Tmin: minimum temperature

	Output:
		- s: a solution obtained by SA

"""
function simulated_annealing(f, s₀, image;
				kT=100,  		# repetitions per temperature
				r=0.95,  		# cooling rate
				Tmax=1_000,     # maximal temperature to start
				Tmin=1)         # minimal temperature to end
	@assert 0 < Tmin < Tmax "Temperatures should be positive"
	@assert 0 < r < 1 "cooling rate is between 0 and 1"
	s = s₀
	obj = f(s, image)
	# current temperature
	T = Tmax
	while T > Tmin
		# repeat kT times
		for _ in 1:kT
			sn =  random_neighbor(s) # random neighbor
			obj_sn = f(sn, image)
			# if the neighbor improves the solution, keep it
			# otherwise accept with a probability determined by the
			if obj_sn > obj || rand() < exp(-(obj-obj_sn)/T)
				s = sn
				obj = obj_sn
			end
		end
		# decay temperature
		T *= r
	end
	return s, f(s, image)
end
	

# ╔═╡ ba135607-b5e3-45ea-8ebe-b445c160f327
"""
	supershapes_objective(supershape_solution, image)

	Objective function to steer the Supershape towards a form that is similar to the contour of a given image

	Inputs:
		- Supershape: all the parameters needed to make a Supershape + rotation and translation parameters
		- image: x and y coordinates for the contour of the image

	Output:
		- obj: an objective value

"""
function supershapes_objective(supershape_solution, image)

	p = range(start = 0, stop = 2, length = length(image))

	phi = p.* pi

	a = supershape_solution[1]
	b =  supershape_solution[2]
	m =  supershape_solution[3]
	n1 =  supershape_solution[4]
	n2 =  supershape_solution[5]
	n3 =  supershape_solution[6]

	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)

	end
	
	MSE = sum((image .- rnew).^2)/length(rnew)

	obj = -MSE 
	
	return obj

end

# ╔═╡ cf2ae45e-be02-44ae-9b20-57107bf9ed16
if SA > 0
	
	s_sa, obj_sa = simulated_annealing(supershapes_objective,  initial_supershape, image, Tmin=10^logTmin, Tmax=10^logTmax; r, kT)
	
end

# ╔═╡ 280a3ca4-a519-4e8b-90bc-69c636f8f012
if SA > 0
	let
	
		p = range(start = 0, stop = 2, length = length(image))
		phi = p.* pi
		
		a = s_sa[1]
		b = s_sa[2]
		m = s_sa[3]
		n1 = s_sa[4]
		n2 = s_sa[5]
		n3 = s_sa[6]
		parameter1 =  s_sa[7]
		parameter2 =  s_sa[8]
		parameter3 =  s_sa[9]
		parameter4 =  s_sa[10]
		parameter5 =  s_sa[11]
		parameter6 =  s_sa[12]
	
		rnew = fill(0.0, length(phi))
		x = fill(0.0, length(phi))
		y = fill(0.0, length(phi))
		
		for (num, i) in enumerate(phi)
			
			rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)
	
			x[num] = rnew[num] .* cos(i+parameter1)*parameter3 + parameter5
	  
			y[num] = rnew[num] .* sin(i+parameter2)*parameter4 + parameter6
	
		end
		

	plot(phi, image, proj=:polar, label="Original shape",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)

	plot!(phi, rnew, proj=:polar, label="Approximation with SA",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)
	
	end
end

# ╔═╡ da39722f-4691-4166-8f5c-5df999f2e797
"""
	supershapes_objective2(supershape_solution, image)
	
	Objective function to steer the Supershape towards a form that is similar to the contour of a given image

	Inputs:
		- Supershape: all the parameters needed to make a Supershape + rotation and translation parameters
		- image: x and y coordinates for the contour of the image

	Output:
		- obj: an objective value
"""
function supershapes_objective2(supershape_solution, image)

	p = range(start = 0, stop = 2, length = length(image[1]))
	phi = p.* pi

	a = supershape_solution[1]
	b =  supershape_solution[2]
	m =  supershape_solution[3]
	n1 =  supershape_solution[4]
	n2 =  supershape_solution[5]
	n3 =  supershape_solution[6]
	parameter1 =  supershape_solution[7]
	parameter2 =  supershape_solution[8]
	parameter3 =  supershape_solution[9]
	parameter4 =  supershape_solution[10]
	parameter5 =  supershape_solution[11]
	parameter6 =  supershape_solution[12]

	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)

		x[num] = rnew[num] .* cos(i+parameter1)*parameter3 + parameter5
  
		y[num] = rnew[num] .* sin(i+parameter2)*parameter4 + parameter6

	end

	x_image = image[1]
	y_image = image[2]
	x_image_sorted = sort(copy(x_image))
	y_image_sorted = sort(copy(y_image))
	x2 = sort(copy(x))
	y2 = sort(copy(y))
	
	MSE = sum((x_image_sorted .- x2).^2 + (y_image_sorted .- y2).^2)/length(x_image_sorted)

	obj = -MSE 

	return obj

end

# ╔═╡ 32cfb418-4c52-47ae-a720-cbfea2f30c18


# ╔═╡ e2b34380-c4f0-45f4-a5eb-a305b49247c8
md"""

**c. MAP-Elites related functions**


"""

# ╔═╡ b6d736e6-c0db-4807-9f76-44a5d7e8990d
"""
	random_selection(X)

	Selects a random elite from the map/archive

	Inputs:
		- X: archive/map containing the elites
	
	Output:
	 	- selection: a random elite form the map/archive

"""
function random_selection(X)
	
	selection = [1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0]

	map = copy(X)
	
	while selection == [1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0]
		
			selection = rand(map)
	
	end

    return selection		

end

# ╔═╡ b672c45f-c389-4e4a-992f-1840e9da367e
"""
	niche_supershapes(x)

	Find the niche a specific Supershape belongs to

	Inputs:
		- x: a possible solution containing all the parameters of a Supershape
	
	Output:
		- i, j: the place niche the Supershape holds in the archive


"""
function niche_supershapes(x)

	#niches = a b m n1 n2 n3

	if x[3] <= 0

		i = 1
		
	elseif 2 >= x[3] > 0
		
		i = 2

	elseif 2 < x[3] 
		
		i = 3
	end
	
	if x[4] <= 0

		j = 1
		
	elseif 2 >= x[4] > 0
		
		j = 2

	elseif 2 < x[4] 
		
		j = 3
	end

	if x[5] <= 0

		i = 4
		
	elseif 2 >= x[5] > 0
		
		i = 5

	elseif 2 < x[5] 
		
		i = 6
	end
	
	if x[6] <= 0

		j = 4
		
	elseif 2 >= x[6] > 0
		
		j = 5

	elseif 2 < x[6] 
		
		j = 6
	end
	
	return i, j
	
end

# ╔═╡ 5ac91331-b4bf-4597-976b-83d22c7c29c0
"""

	MAP_Elites(initial_solution, random_selection, random_variation, performance, niche, N, image; max_iteration = 10, a = [1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0], b = -Inf)

	Own MAP Elites implementation

	Inputs:
		- initial_solution: an initial solution 
		- random_selection: selects a random solution from the archive
		- random_variation: creates a random neighbor
		- performance: gives an objective value
		- niche: finds out what niche the solution belongs to
		- N: size of the archive
		- image: x and y coordinates for the contour of the image
		- max_iteration: maximum number of iterations
		- a: parameter to initialize the archive
		- b: parameter to initialize the archive

	Output:
		- MAP_solutions: N-dimensional map of elites containing the solutions
		- MAP_performances: N-dimensional map of elites containing the performances

"""
function MAP_Elites(initial_solution, random_selection, random_variation, performance, niche, N, image; max_iteration = 10, a = [1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0 1000.0], b = -Inf)
	
	# 0. Create an empty, N-dimensional map of elites: {solutions X and their performances P}
	
	MAP_solutions = fill(a, N, N) # = X
	MAP_performances = fill(b, N, N) # = P

	#  Repeat for I iterations 

	iterations = 0
		
	while iterations < max_iteration
		
		if iterations < 1 

			# 0. Initial solution
			
			x′ = initial_solution 
		
		else
			
			# All subsequent solutions are generated from elites in the map

			# 1. Randomly select an elite x from the map X (MAP_solutions)
			
			x = random_selection(MAP_solutions) 

			# 2. Create x′, a randomly modified copy of x (via mutation and/or crossover)
			x′ = random_variation(x)
			
		end

		# 3. Score + define niche of new individual
		
		# NICHE
		
		i_current, j_current = niche(x′)

		# Record the performance p′ of x′
		
		p′ = performance(x′, image)
		

		# 4. Check if the new individual is better than the current elite in its specific niche. If the appropriate cell is empty or its occupants’s performance is ≤ p′, then:

		if MAP_performances[i_current, j_current] == 100.0 || MAP_performances[i_current, j_current] < p′ 

			# store the performance of x′ in the map of elites according to its feature descriptor b′
			
			MAP_performances[i_current, j_current] = p′

			# store the solution x′ in the map of elites according to its feature descriptor b′

			MAP_solutions[i_current, j_current] = x′

		end


		# 5. Update iterations
	
			iterations += 1

	end

	
	return MAP_solutions, MAP_performances # feature-performance map (P and X)

end

# ╔═╡ 82be1c86-69c8-4a64-aa34-3fbf2bf0033f
if ME > 0
	begin
	
		N = 6
		
		MAP_solutions_supershapes, MAP_performances_supershapes = 
		MAP_Elites(initial_supershape, random_selection, random_neighbor, supershapes_objective, niche_supershapes, N, image; max_iteration = 10000)
	
	
	end
end

# ╔═╡ 44266510-8c64-429b-925b-901293e3c033
if ME > 0
	let
	
		p = range(start = 0, stop = 2, length = length(image))
		phi = p.* pi
	
		s_me = MAP_solutions_supershapes[argmax(MAP_performances_supershapes)]
		
		a = s_me[1]
		b = s_me[2]
		m = s_me[3]
		n1 = s_me[4]
		n2 = s_me[5]
		n3 = s_me[6]
		parameter1 =  s_me[7]
		parameter2 =  s_me[8]
		parameter3 =  s_me[9]
		parameter4 =  s_me[10]
		parameter5 =  s_me[11]
		parameter6 =  s_me[12]
	
	
		rnew = fill(0.0, length(phi))
		x = fill(0.0, length(phi))
		y = fill(0.0, length(phi))
		
		for (num, i) in enumerate(phi)
			
			rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)
	
			x[num] = rnew[num] .* cos(i+parameter1)*parameter3 + parameter5
	  
			y[num] = rnew[num] .* sin(i+parameter2)*parameter4 + parameter6
	
		end
		

	plot(phi, image, proj=:polar, label="Original shape",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)

	plot!(phi, rnew, proj=:polar, label="Approximation with ME",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)
	
	end
end

# ╔═╡ 84404fa1-7b80-418b-b401-b8c959c52fee


# ╔═╡ 93bb040b-9cab-4fe6-947d-f084609ef0a6
md"""

**d. Figures used in section 4**


"""

# ╔═╡ 72ec6f6c-9855-4522-9d44-b040d3ad5989
Diatom3 = Images.load(Images.download("https://github.com/shvhoye/SuperEvolution.jl/blob/master/figures/Diatom3.jpeg?raw=true"))

# ╔═╡ 52aaa3a3-b1b0-42a4-b768-b02a6bb99fbd
let

	p = 0:.001:2
	phi = p.* pi

	a = 1
	b = 1
	m = 3
	n1 = 5
	n2 = 8
	n3 = 8

	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)

		x[num] = rnew[num] .* cos(i+0.5)*120 + 220
  
		y[num] = rnew[num] .* sin(i+0.5)*120 + 155

	end
	

	plot(Diatom3)
	plot!(x, y, w = 5,  color = "blue", label = false, border=:none, fg_legend = :transparent)


end

# ╔═╡ 7de6279b-0149-4817-985e-fe653bb593d9
triangle = plotsuperformula(ϕ; a = 1, b = 1, m = 3, n1 = 4.5, n2 = 10, n3 = 10)

# ╔═╡ 770ecee0-c0cc-4aaf-80bb-b976faa2de96
Flower1 = Images.load(Images.download("https://github.com/shvhoye/SuperEvolution.jl/blob/master/figures/Flower1.jpeg?raw=true"))

# ╔═╡ 9fdfb04a-fcec-41cf-a9a2-289c29cebfdd
let

	p = 0:.001:2
	phi = p.* pi

	a = 1
	b = 1
	m = 40
	n1 = 13
	n2 = -4
	n3 = 17


	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)

		x[num] = rnew[num] .* cos(i+0.5)*150 + 205
  
		y[num] = rnew[num] .* sin(i+0.5)*150 + 195

	end
	
	

	plot(Flower1)
	
	plot!(x, y, w = 5,  color = "blue", label = false, border=:none, fg_legend = :transparent)

end

# ╔═╡ dc92872c-24e6-48f3-8d64-5ae124334858


# ╔═╡ 62635ead-576e-448a-bf03-9095488bf70c
md"""**e. Segmentation and contours of images**"""

# ╔═╡ 3b6a8b5f-a309-4c7c-a93c-cee4b08c43ae
md"""

First, we segment the images into two colours and then we search for the contour of the images. These contours will then be used to fit Supershape to the images

"""

# ╔═╡ be95ece1-bdf8-45bb-ae4a-7b41843ba94c
md"""The flower"""

# ╔═╡ 4e22f5fb-7331-4b00-887a-e18f05d1878c
seeds_flower = [(CartesianIndex(1,1),1), (CartesianIndex(100,200),2)]

# ╔═╡ 4e24e028-e7cf-443a-96d7-af7eab4790a9
segmented_flower = seeded_region_growing(Flower1, seeds_flower)

# ╔═╡ bc66e120-c12d-4915-84ab-ddb093da4330
plot(map(i->segment_mean(segmented_flower,i), labels_map(segmented_flower)),  border=:none, fg_legend = :transparent)

# ╔═╡ 7f4e7d1a-6bf6-43c6-84fc-419fd89ac4c8
SF1 = Images.load(Images.download("https://github.com/shvhoye/SuperEvolution.jl/blob/master/figures/SF1.jpeg?raw=true"));

# ╔═╡ 4a3d0e1d-94cd-4628-8bd1-d48714470bf7
md"""The Diatom"""

# ╔═╡ 6484b6ca-759e-4e76-a29d-edaf4c9ea6a8
seeds_diatom = [(CartesianIndex(1,1),1), (CartesianIndex(60,50),2)]

# ╔═╡ f19728de-0d4c-400e-996d-3c71195a42c6
segmented_diatom = seeded_region_growing(Diatom3, seeds_diatom)

# ╔═╡ b67bf184-29ac-46ea-b423-549b6d9bac91
plot(map(i->segment_mean(segmented_diatom,i), labels_map(segmented_diatom)),axis = nothing)

# ╔═╡ 473e5515-823a-404a-a06c-ddea91c39e7c
SD1 = Images.load(Images.download("https://github.com/shvhoye/SuperEvolution.jl/blob/master/figures/SD3.jpeg?raw=true"));

# ╔═╡ e43b4647-1a48-4583-8529-80dcf25d5604
md"""

Below are functions I found on the internet and used to obtain the contours

"""

# ╔═╡ c5c8fcd7-d75a-4e1c-b754-e290db634986
# finds direction between two given pixels
function from_to(from, to, dir_delta)
    delta = to-from
    return findall(x->x == delta, dir_delta)[1]
end

# ╔═╡ 932f4de4-72f5-4ddf-bffc-332f4aa60067
# rotate direction clocwise
function clockwise(dir)
    return (dir)%8 + 1
end

# ╔═╡ 00af2b81-dc74-4823-91f0-ad6f19313adc
# rotate direction counterclocwise
function counterclockwise(dir)
    return (dir+6)%8 + 1
end

# ╔═╡ a213e302-e720-4cc2-b223-d63ac94407ab
# move from current pixel to next in given direction
function move(pixel, image, dir, dir_delta)
    newp = pixel + dir_delta[dir]
    height, width = size(image)
    if (0 < newp[1] <= height) &&  (0 < newp[2] <= width)
        if image[newp]!=0
            return newp
        end
    end
    return CartesianIndex(0, 0)
end

# ╔═╡ a6f44fc1-3dc8-4190-b597-b7117371e5c1
function detect_move(image, p0, p2, nbd, border, done, dir_delta)
    dir = from_to(p0, p2, dir_delta)
    moved = clockwise(dir)
    p1 = CartesianIndex(0, 0)
    while moved != dir ## 3.1
        newp = move(p0, image, moved, dir_delta)
        if newp[1]!=0
            p1 = newp
            break
        end
        moved = clockwise(moved)
    end

    if p1 == CartesianIndex(0, 0)
        return
    end

    p2 = p1 ## 3.2
    p3 = p0 ## 3.2
    done .= false
    while true
        dir = from_to(p3, p2, dir_delta)
        moved = counterclockwise(dir)
        p4 = CartesianIndex(0, 0)
        done .= false
        while true ## 3.3
            p4 = move(p3, image, moved, dir_delta)
            if p4[1] != 0
                break
            end
            done[moved] = true
            moved = counterclockwise(moved)
        end
        push!(border, p3) ## 3.4
        if p3[1] == size(image, 1) || done[3]
            image[p3] = -nbd
        elseif image[p3] == 1
            image[p3] = nbd
        end

        if (p4 == p0 && p3 == p1) ## 3.5
            break
        end
        p2 = p3
        p3 = p4
    end
end


# ╔═╡ 18c4c2bd-e86a-4ed8-a0d6-cf159603fae6
function find_contours(image)
    nbd = 1
    lnbd = 1
    image = Float64.(image)
    contour_list =  Vector{typeof(CartesianIndex[])}()
    done = [false, false, false, false, false, false, false, false]

    # Clockwise Moore neighborhood.
    dir_delta = [CartesianIndex(-1, 0) , CartesianIndex(-1, 1), CartesianIndex(0, 1), CartesianIndex(1, 1), CartesianIndex(1, 0), CartesianIndex(1, -1), CartesianIndex(0, -1), CartesianIndex(-1,-1)]

    height, width = size(image)

    for i=1:height
        lnbd = 1
        for j=1:width
            fji = image[i, j]
            is_outer = (image[i, j] == 1 && (j == 1 || image[i, j-1] == 0)) ## 1 (a)
            is_hole = (image[i, j] >= 1 && (j == width || image[i, j+1] == 0))

            if is_outer || is_hole
                # 2
                border = CartesianIndex[]

                from = CartesianIndex(i, j)

                if is_outer
                    nbd += 1
                    from -= CartesianIndex(0, 1)

                else
                    nbd += 1
                    if fji > 1
                        lnbd = fji
                    end
                    from += CartesianIndex(0, 1)
                end

                p0 = CartesianIndex(i,j)
                detect_move(image, p0, from, nbd, border, done, dir_delta) ## 3
                if isempty(border) ##TODO
                    push!(border, p0)
                    image[p0] = -nbd
                end
                push!(contour_list, border)
            end
            if fji != 0 && fji != 1
                lnbd = abs(fji)
            end

        end
    end

    return contour_list


end

# ╔═╡ fb4bedfa-3f69-4c54-bd89-cab740ee65cf
# a contour is a vector of 2 int arrays
function draw_contour(image, color, contour)
    for ind in contour
        image[ind] = color
    end
end

# ╔═╡ e751b359-b102-4b96-9926-a7139bc0b0d1
function draw_contours(image, color, contours)
    for cnt in contours
        draw_contour(image, color, cnt)
    end
end

# ╔═╡ 339ef2bf-f006-42e2-8f68-59d9529eb79c
begin
	## Getting the contour
	
	# Convert to grayscale
	
	imgg1 = Gray.(SF1)
	
	# Threshold
	
	imgg1 = imgg1 .> 0.45
	
	# Calling find_contours
	
	cnts1 = find_contours(imgg1)

	img1 = copy(SF1)

	draw_contours(img1, RGB(1,0,0), cnts1)

end

# ╔═╡ 82b92e8e-4374-466e-a72f-ffcf016e3ba5
img1

# ╔═╡ 458cd5bc-1394-4a9f-93ec-596a62339be4
begin
	
	x_flower1 = []
	y_flower1 = []
	
	for j in 1:length(cnts1[1])
	
		push!(x_flower1, cnts1[1][j][1])
	
		push!(y_flower1, cnts1[1][j][2])
	
	end

end

# ╔═╡ 42688611-ec9c-4984-b00d-8c1c513dc750
plot(x_flower1, y_flower1,  border=:none, legend = false)

# ╔═╡ 5ee4b116-8e4b-4d1d-b870-8fe3a068df50
begin
	## Getting the contour
	
	# Convert to grayscale
	
	imgg2 = Gray.(SD1)
	
	# Threshold
	
	imgg2 = imgg2 .> 0.3 #0.45
	
	# Calling find_contours
	
	cnts2 = find_contours(imgg2)

	img2 = copy(SD1)

	draw_contours(img2, RGB(0,1,0), cnts2)

end

# ╔═╡ 9f3f7cfd-cea9-49ac-8a7a-0cadb588f7d3
img2

# ╔═╡ 7f359853-1c99-43f3-a16e-472238cd63a4
begin

	# Extracting the x y coordinates of the contour
	
	x_diatom3 = []
	y_diatom3 = []
	
	for j in 1:length(cnts2[1])
	
		push!(x_diatom3, cnts2[1][j][1])
	
		push!(y_diatom3, cnts2[1][j][2])
	
	end

end

# ╔═╡ 69457c79-b895-424d-aebb-3e54c9e5f04c
if ME2 > 0
	begin

		image2 = [copy(x_diatom3), copy(y_diatom3)]

		N2 = 6
		
		MAP_solutions_supershapes2, MAP_performances_supershapes2 = 
		MAP_Elites(initial_supershape, random_selection, random_neighbor, supershapes_objective2, niche_supershapes, N2, image2; max_iteration = 10000)
	
	
	end
end

# ╔═╡ 69ebef0f-bb9d-4f28-b20a-824e341117d1
if ME2 > 0
	let
	
		p = range(start = 0, stop = 2, length = 1999)
		phi = p.* pi
	
		s_me = MAP_solutions_supershapes2[argmax(MAP_performances_supershapes2)]
		
		a = s_me[1]
		b = s_me[2]
		m = s_me[3]
		n1 = s_me[4]
		n2 = s_me[5]
		n3 = s_me[6]
		parameter1 =  s_me[7]
		parameter2 =  s_me[8]
		parameter3 =  s_me[9]
		parameter4 =  s_me[10]
		parameter5 =  s_me[11]
		parameter6 =  s_me[12]
	
	
		rnew = fill(0.0, length(phi))
		x = fill(0.0, length(phi))
		y = fill(0.0, length(phi))
		
		for (num, i) in enumerate(phi)
			
			rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)
	
			x[num] = rnew[num] .* cos(i+parameter1)*parameter3 + parameter5
	  
			y[num] = rnew[num] .* sin(i+parameter2)*parameter4 + parameter6
	
		end
		

	plot(image2[1], image2[2], label="Extracted contour of the diatom image",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)

	plot!(x, y, label="Approximation with ME",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)
	
	
	end
end

# ╔═╡ 3e86b5e3-690d-4a9b-b42d-d68f43a264cc
if ME2 > 0
	begin

		image3 = [copy(x_flower1), copy(y_flower1)]
		
		MAP_solutions_supershapes3, MAP_performances_supershapes3 = 
		MAP_Elites(initial_supershape, random_selection, random_neighbor, supershapes_objective2, niche_supershapes, N2, image2; max_iteration = 10000)
	
	
	end
end

# ╔═╡ 76013394-1595-47bb-b41b-5414f1975fbb
if ME2 > 0
	let
	
		p = range(start = 0, stop = 2, length = 1999)
		phi = p.* pi
	
		s_me = MAP_solutions_supershapes3[argmax(MAP_performances_supershapes3)]
		
		a = s_me[1]
		b = s_me[2]
		m = s_me[3]
		n1 = s_me[4]
		n2 = s_me[5]
		n3 = s_me[6]
		parameter1 =  s_me[7]
		parameter2 =  s_me[8]
		parameter3 =  s_me[9]
		parameter4 =  s_me[10]
		parameter5 =  s_me[11]
		parameter6 =  s_me[12]
	
	
		rnew = fill(0.0, length(phi))
		x = fill(0.0, length(phi))
		y = fill(0.0, length(phi))
		
		for (num, i) in enumerate(phi)
			
			rnew[num] =  round(superformula(a= a, b = b, m = m, n1 = n1, n2 = n2, n3 = n3, i), digits=8)
	
			x[num] = rnew[num] .* cos(i+parameter1)*parameter3 + parameter5
	  
			y[num] = rnew[num] .* sin(i+parameter2)*parameter4 + parameter6
	
		end
		

	plot(image3[1], image3[2], label="Extracted contour of the flower image",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)

	plot!(x, y, label="Approximation with ME",  border=:none, fg_legend = :transparent, aspect_ratio = :equal,  axis=nothing)
	
	
	end
end

# ╔═╡ 696b1296-9f5d-4390-b30f-40900e6e22bc
plot(x_diatom3, y_diatom3,  border=:none, legend = false)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
Distributions = "~0.25.37"
Images = "~0.25.0"
Plots = "~1.25.4"
PlutoUI = "~0.7.27"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9faf218ea18c51fcccaf956c8d39614c9d30fe8b"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.2"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "1ee88c4c76caa995a885dc2f22a5d548dfbbc0ba"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.2.2"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d711603452231bad418bd5e0c91f1abd650cba71"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.3"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "6a8dc9f82e5ce28279b6e3e2cea9421154f5bd0d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.37"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "84f04fe68a3176a583b864e492578b9466d87f1e"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "3fe985505b4b667e1ae303c9ca64d181f09d5c05"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.3"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "67551df041955cc6ee2ed098718c8fcd7fc7aebe"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.12.0"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b9a93bcdf34618031891ee56aad94cfff0843753"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78e2c69783c9753a91cdae88a8d432be85a2ab5e"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Graphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "92243c07e786ea3458532e199eb3feee0e7e08eb"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.4.1"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "c54b581a83008dc7f292e205f4c409ab5caa0f04"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.10"

[[ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[ImageContrastAdjustment]]
deps = ["ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "0d75cafa80cf22026cea21a8e6cf965295003edc"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.10"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "7a20463713d239a19cbad3f6991e404aca876bda"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.15"

[[ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "15bd05c1c0d5dbb32a9a3d7e0ad2d50dd6167189"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.1"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "a2951c93684551467265e0e32b577914f69532be"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.9"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f025b79883f361fa1bd80ad132773161d231fd9f"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+2"

[[ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "5581e18a74a5838bd919294a7138c2663d065238"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.0"

[[ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1d2d73b14198d10f7f12bf7f8481fd4b3ff5cd61"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.0"

[[ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "36832067ea220818d105d718527d6ed02385bf22"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.7.0"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "d0ac64c9bee0aed6fdbb2bc0e5dfa9a3a78e3acc"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.3"

[[ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "b4b161abc8252d68b13c5cc4a5f2ba711b61fec5"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.3"

[[Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "35dc1cd115c57ad705c7db9f6ef5cc14412e8f00"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.0"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "00019244715621f473d399e4e1842e479a69a42e"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.2"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "09ef0c32a26f80b465d808a1ba1e85775a282c97"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.17"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "2af69ff3c024d13bde52b34a2a7d6887d4e7b438"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "6d105d40e30b635cfed9d52ec29cf456e27d38f8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.12"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "71d65e9242935132e71c4fbf084451579491166a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.4"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[Quaternions]]
deps = ["DualNumbers", "LinearAlgebra"]
git-tree-sha1 = "adf644ef95a5e26c8774890a509a55b7791a139f"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "dbf5f991130238f10abbf4f2d255fb2837943c43"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a6f404cc44d3d3b28c793ec0eb59af709d827e4e"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.1"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e08890d19787ec25029113e88c34ec20cac1c91e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.0.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "7f5a513baec6f122401abfc8e9c074fdac54f6c1"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "de9e88179b584ba9cf3cc5edbb7a41f26ce42cda"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "bedb3e17cc1d94ce0e6e66d3afa47157978ba404"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.14"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "991d34bbff0d9125d93ba15887d6594e8e84b305"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.3"

[[TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╠═79f21734-4164-421a-a887-c78f3ea1d054
# ╟─46d05db8-f79e-45d9-92eb-874f7153cd5e
# ╟─06fe0d51-26b1-4ea7-b789-985964f7b110
# ╟─e2357883-94f7-42c9-8bef-6644af323c7b
# ╟─cead5325-a013-4151-8cb2-486147e9066f
# ╠═b31cb3af-1c9b-4698-a8c7-be692b31207c
# ╠═bc4c4e75-e7a9-4da4-82b3-3ca74a72df4a
# ╟─4524e200-ae4e-41c8-b06b-a41b7e39f899
# ╟─1e12714b-1860-47d4-a098-946ccb38a526
# ╟─69f12062-cf39-4f57-b2ea-24e25b41ddd5
# ╟─93880c6b-a27e-4f7d-a5d9-74b5e5d363fc
# ╟─bb587364-5a3a-41f1-9e57-87facbc21181
# ╟─4b0cfe82-aa8f-4f67-bb44-b3486ef8a5cf
# ╟─df17e490-9da5-4686-a5c5-3c7de897b2b4
# ╟─4314b935-1b31-4a03-9eba-4e70bca8a1b4
# ╟─04261bb7-0ab6-466b-9448-67d54bbe8b35
# ╟─b35f0400-009e-4ea7-b380-f516e6499ac7
# ╟─fe9d41d3-f253-4480-b95e-4c92316227ca
# ╟─d9159850-9f56-4c6d-bd2c-c984bb72b9b8
# ╟─07aef886-ed96-4419-b8cf-270ac96a944a
# ╟─59cc8d61-38d4-435d-a9c7-5213607091c0
# ╟─b39841bc-91da-4a37-96bb-abfa6e2b0245
# ╟─a96772bc-3726-4869-9bcf-189c2cd1b834
# ╟─e3a7b0dd-482f-4618-a5bb-3eb03a0ae7c1
# ╟─39154389-5fa6-4071-a923-315035e17e98
# ╟─94071fd6-9ad8-47f6-9600-40f5b4ba8f94
# ╟─bc364f47-1d39-4307-bcda-583922c9464c
# ╟─fe6179e8-088c-4481-8110-acc832f83bca
# ╟─5d5d1465-b37e-4a74-b528-00a4e6841c99
# ╟─2fda126a-9dd8-437a-8905-cce39bc996b7
# ╟─c2e4a65c-efaa-4c3a-97a3-639e08846e36
# ╟─b3c2a892-2dba-419d-8d4a-f573aec3720d
# ╟─9c8289b7-e5f8-4902-a160-c921e0dd3981
# ╟─48f0fd88-ad2c-410c-b2c1-a03e5f885368
# ╟─20fc0cb2-c466-4638-babd-9b4d24f21e5b
# ╟─9664adef-5be1-45e3-a5ba-75f2baada277
# ╟─006ec0f4-dde9-4dfa-8845-b43eff6ccfd1
# ╟─c280da39-9c4d-4aac-a081-3feaa55fe1cb
# ╟─4e8037a5-524a-4307-809e-3c9f833d9027
# ╟─72cb67a5-93c9-4913-8739-9527d10cd690
# ╟─2702a17a-c26d-4939-b9ab-1b1bf2da4f44
# ╟─cf1245c4-4298-41cf-a368-124b38982a68
# ╟─52aaa3a3-b1b0-42a4-b768-b02a6bb99fbd
# ╟─f4444d7d-f283-42b5-a6c6-579a0564c354
# ╟─9fdfb04a-fcec-41cf-a9a2-289c29cebfdd
# ╟─7c19a13d-16a7-43e2-89f7-987690e60269
# ╟─d615309c-0f5a-4d6f-aab3-fb7c1fd1c92c
# ╠═419d5824-c7c8-43a9-8107-8b04b0ed093a
# ╠═a47999e1-9415-492d-8784-4ced249a1b79
# ╠═36b88a3b-b8d9-452d-b5c4-bb30aced0b4b
# ╠═85a9b84f-a9d1-4532-ba58-ac0eaa978af0
# ╟─a64106b2-e70c-4eb5-967f-ab0e9994b2c3
# ╟─368f2043-6505-4c48-801e-aad1537e7b30
# ╟─4938804e-3f04-4821-847d-4bdb9c24d78b
# ╟─ebb3daa8-e41f-4ea1-8798-8840f1954c7c
# ╠═cf2ae45e-be02-44ae-9b20-57107bf9ed16
# ╟─280a3ca4-a519-4e8b-90bc-69c636f8f012
# ╟─eab12a20-28a1-47c4-9d46-0a8b2ed6d870
# ╟─24159b9c-d157-40cd-9539-3855101c2b73
# ╟─219b169c-6b41-4981-b5bc-7fa7241326c7
# ╟─28c31d86-816b-48c3-bf67-1734a8002d57
# ╠═82be1c86-69c8-4a64-aa34-3fbf2bf0033f
# ╟─44266510-8c64-429b-925b-901293e3c033
# ╟─f88a733a-6bb2-4d0d-8c52-cef4498a5754
# ╟─ebf8ad58-30fa-4a2d-b3d1-a008cca30d22
# ╠═69457c79-b895-424d-aebb-3e54c9e5f04c
# ╟─69ebef0f-bb9d-4f28-b20a-824e341117d1
# ╟─36b314bf-e3d6-4f73-be03-81d140723f86
# ╠═3e86b5e3-690d-4a9b-b42d-d68f43a264cc
# ╟─76013394-1595-47bb-b41b-5414f1975fbb
# ╟─81e5f62c-e7f5-4782-b555-19ec870ab2ef
# ╟─99a9bc93-2942-4e32-96b8-369649c0148b
# ╟─070fa6ac-91dd-48a1-b905-27aa6f2c272e
# ╟─194351eb-bf39-428f-aae1-d2501bf4384b
# ╟─8d8f3a18-c4ed-444a-b947-773e7f6384ef
# ╟─99fd40ba-933c-4653-b14b-46d2dd05274f
# ╟─14120ff1-56e8-41d2-b3eb-8fb95a6b3290
# ╟─0034ac1f-9e7f-4ee1-b894-edf8c22ab1db
# ╟─ab23b27d-2ece-4e90-b560-863be9610a57
# ╟─cbdff552-ca0d-4b89-918c-bb926a03a975
# ╟─71d54c27-eddc-4638-b5c8-dfa7698d4856
# ╟─432bac03-8a76-481a-a053-b4599e9bb57f
# ╟─3f823e11-d5e8-4850-945b-c7d23de6b769
# ╟─bf7f0593-79f7-4161-b128-c199ae4cb5c2
# ╟─a0de21e2-84ea-4d49-92f8-825853fb7a08
# ╟─1063bb90-2818-4174-a003-c17160e71fd5
# ╟─d789ad4e-eb5f-486c-bd88-967601b5afdb
# ╟─9cfdaff3-5abf-4784-815f-4530b71a60e5
# ╟─ba135607-b5e3-45ea-8ebe-b445c160f327
# ╟─da39722f-4691-4166-8f5c-5df999f2e797
# ╟─32cfb418-4c52-47ae-a720-cbfea2f30c18
# ╟─e2b34380-c4f0-45f4-a5eb-a305b49247c8
# ╟─b6d736e6-c0db-4807-9f76-44a5d7e8990d
# ╟─b672c45f-c389-4e4a-992f-1840e9da367e
# ╟─5ac91331-b4bf-4597-976b-83d22c7c29c0
# ╟─84404fa1-7b80-418b-b401-b8c959c52fee
# ╟─93bb040b-9cab-4fe6-947d-f084609ef0a6
# ╟─72ec6f6c-9855-4522-9d44-b040d3ad5989
# ╟─7de6279b-0149-4817-985e-fe653bb593d9
# ╟─770ecee0-c0cc-4aaf-80bb-b976faa2de96
# ╟─dc92872c-24e6-48f3-8d64-5ae124334858
# ╟─62635ead-576e-448a-bf03-9095488bf70c
# ╟─3b6a8b5f-a309-4c7c-a93c-cee4b08c43ae
# ╟─be95ece1-bdf8-45bb-ae4a-7b41843ba94c
# ╠═4e22f5fb-7331-4b00-887a-e18f05d1878c
# ╠═4e24e028-e7cf-443a-96d7-af7eab4790a9
# ╠═bc66e120-c12d-4915-84ab-ddb093da4330
# ╠═7f4e7d1a-6bf6-43c6-84fc-419fd89ac4c8
# ╠═339ef2bf-f006-42e2-8f68-59d9529eb79c
# ╟─82b92e8e-4374-466e-a72f-ffcf016e3ba5
# ╠═458cd5bc-1394-4a9f-93ec-596a62339be4
# ╠═42688611-ec9c-4984-b00d-8c1c513dc750
# ╟─4a3d0e1d-94cd-4628-8bd1-d48714470bf7
# ╠═6484b6ca-759e-4e76-a29d-edaf4c9ea6a8
# ╠═f19728de-0d4c-400e-996d-3c71195a42c6
# ╠═b67bf184-29ac-46ea-b423-549b6d9bac91
# ╠═473e5515-823a-404a-a06c-ddea91c39e7c
# ╠═5ee4b116-8e4b-4d1d-b870-8fe3a068df50
# ╟─9f3f7cfd-cea9-49ac-8a7a-0cadb588f7d3
# ╠═7f359853-1c99-43f3-a16e-472238cd63a4
# ╠═696b1296-9f5d-4390-b30f-40900e6e22bc
# ╟─e43b4647-1a48-4583-8529-80dcf25d5604
# ╟─18c4c2bd-e86a-4ed8-a0d6-cf159603fae6
# ╟─a6f44fc1-3dc8-4190-b597-b7117371e5c1
# ╟─c5c8fcd7-d75a-4e1c-b754-e290db634986
# ╟─932f4de4-72f5-4ddf-bffc-332f4aa60067
# ╟─00af2b81-dc74-4823-91f0-ad6f19313adc
# ╟─a213e302-e720-4cc2-b223-d63ac94407ab
# ╟─fb4bedfa-3f69-4c54-bd89-cab740ee65cf
# ╟─e751b359-b102-4b96-9926-a7139bc0b0d1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
