---
title: "Design of a Novel Particle-Based Zonotopic Hybrid Filter and its Application"
collection: "publications"
category: "manuscripts"
permalink: "/publication/particle-hybrid-filter/"
date: "2026-01-01"
date_precision: "year"
authors: [{"name": "Ziyun Wang", "corresponding": true}, {"name": "Liping Liao"}, {"name": "Qianyi Shen", "self": true}, {"name": "Yan Wang"}, {"name": "Zhenhua Wang"}]
excerpt: "Zonotopic filtering and particle swarm optimization work together to estimate states in nonlinear systems with time delay and bounded noise. The filter narrows the search region before particle refinement, yielding tighter state bounds in battery state-of-charge estimation across multiple driving cycles."
venue: "IEEE Transactions on Industrial Informatics"
paperurl: "https://ieeexplore.ieee.org/abstract/document/11417933"
paper_label: "Publisher"
bibliography: "pp. 1–11"
bibtexurl: "/files/particle-hybrid-filter.bib"
---

Nonlinearity and time delay can make state estimation bounds overly wide, while particle methods can spend substantial computation searching a large region. We combine the two approaches by first using a zonotopic filter to construct a feasible state region that accounts for bounded noise and linearization errors. Particle swarm optimization then refines the estimate within that region. A boundary reflection rule keeps particles inside the search region, and an ellipsoidal representation summarizes the refined result as a point estimate and surrounding bounds.

We test the method on battery state-of-charge estimation using experimental data from four driving cycles. It produces tighter estimation bounds than the comparison methods across these conditions. The additional particle refinement increases computation, so the main benefit is a more precise description of the possible battery state.
